
###########################################################################
# Tree analysis and processing functions
###########################################################################


#' Propagate Answers and Confidence Up the Tree
#'
#' @description
#' This function performs a full, bottom-up recalculation of the decision tree's
#' state. It takes the user-provided answers and confidences at the leaf level
#' and propagates the logical outcomes (`answer`) and aggregate confidence scores
#' up to the parent nodes based on their `AND`/`OR` rules.
#'
#' @details
#' This function is one of three called by `update_tree()`, which does a full
#' recalculation of the decision tree result and optimisation indices.
#'
#' The function first resets the `answer` and `confidence` of all non-leaf nodes
#' to `NA` to ensure a clean calculation.
#'
#' It then uses a \strong{post-order traversal}, which is critical as it guarantees
#' that a parent node is only processed after all of its children have been processed.
#'
#' The logical rules are applied with short-circuiting:
#' \describe{
#'   \item{\strong{OR Nodes:}}{Become `TRUE` if any child is `TRUE`. Become
#'     `FALSE` only if all children are answered and none are `TRUE`.}
#'   \item{\strong{AND Nodes:}}{Become `FALSE` if any child is `FALSE`.
#'     Become `TRUE` only if all children are answered and none are `FALSE`.}
#' }
#'
#' The confidence calculation is based on the confidences of the children that
#' determined the outcome (e.g., only the `TRUE` children for a resolved `OR` node).
#'
#' @param tree The `data.tree` object to be calculated. The function modifies
#'   this object directly.
#'
#' @return The modified `tree` object (returned invisibly).
#' @import glue
#' @export
#' @examples
#' # Load the data
#' ethical_tree <- load_tree_df(ethical)
#'
#' # Answer some questions
#' set_answer(ethical_tree, "FIN2", TRUE, 4)
#' set_answer(ethical_tree, "ENV2", TRUE, 3)
#' set_answer(ethical_tree, "SOC2", TRUE, 4)
#' set_answer(ethical_tree, "GOV2", FALSE, 1)
#'
#' # Calculate the tree
#' ethical_tree <- calculate_tree(ethical_tree)
#'
#' # View the result
#' print_tree(ethical_tree)
#'
calculate_tree <- function(tree) {
  tree$Do(function(node) {
    if (!node$isLeaf) {
      node$answer <- NA
      node$confidence <- NA
    }
  })
  tree$Do(function(node) {
    if (node$isLeaf) return()
    if (length(node$children) == 0) return()
    children_answers <- sapply(node$children, function(ch) ch$answer)
    if (length(children_answers) > 0) {
      children_answers <- as.logical(children_answers)
    }
    rule <- node$rule
    if (is.null(rule) || is.na(rule) || rule == "") return()
    rule <- toupper(trimws(as.character(rule)))
    new_answer <- NA
    new_confidence <- NA
    children_confidences <- sapply(node$children, function(ch) ch$confidence)
    relevant_confidences <- children_confidences[!is.na(children_answers)]
    if (rule == "OR") {
      if (any(children_answers == TRUE, na.rm = TRUE)) {
        new_answer <- TRUE
        true_confidences <- children_confidences[which(children_answers == TRUE)]
        if(length(true_confidences) > 0) {
          new_confidence <- 1 - prod(1 - true_confidences, na.rm = TRUE)
        }
      } else if (all(!is.na(children_answers))) {
        new_answer <- FALSE
        if(length(relevant_confidences) > 0) {
          new_confidence <- 1 - prod(1 - relevant_confidences, na.rm = TRUE)
        }
      }
    } else if (rule == "AND") {
      if (any(children_answers == FALSE, na.rm = TRUE)) {
        new_answer <- FALSE
        false_confidences <- children_confidences[which(children_answers == FALSE)]
        if(length(false_confidences) > 0) {
          new_confidence <- prod(false_confidences, na.rm = TRUE)
        }
      } else if (all(!is.na(children_answers))) {
        new_answer <- TRUE
        if(length(relevant_confidences) > 0) {
          new_confidence <- prod(relevant_confidences, na.rm = TRUE)
        }
      }
    }
    if (!is.na(new_answer)) {
      node$answer <- new_answer
      node$confidence <- new_confidence
    }
  }, traversal = "post-order")
  invisible(tree)
}


#' @title Calculate Dynamic True/False Indices for a Parent Node
#'
#' @description
#' This function calculates a `true_index` and a `false_index` for a given parent
#' (non-leaf) node. The calculation is dynamic, depending on the node's logical
#' rule (`AND` or `OR`) and the number of its direct children that have not yet
#' been answered (i.e., their `answer` attribute is `NA`).
#'
#' @details
#' The function applies the following logic:
#' - For an **AND** node, `true_index` is `1/n` and `false_index` is `1.0`.
#' - For an **OR** node, `true_index` is `1.0` and `false_index` is `1/n`.
#'
#' Where `n` is the number of unanswered children. If all children have been
#' answered (`n = 0`), `n` is treated as 1 to avoid division by zero.
#'
#' The function modifies the node object directly by adding or updating the
#' `true_index` and `false_index` attributes. It is intended to be used with
#' `tree$Do()`.
#'
#' @param node A `data.tree` `Node` object to be processed. The function will
#'   only act on this node if it is not a leaf (`!node$isLeaf`).
#'
#' @return The function does not return a value; it modifies the input `node`
#'   by side-effect.
#'
#' @keywords internal
#'
assign_indices <- function(node) {
  if (!node$isLeaf) {
    children_answers <- sapply(node$children, function(ch) ch$answer)
    unanswered_count <- sum(is.na(children_answers))
    if (unanswered_count == 0) unanswered_count <- 1
    if (!is.na(node$rule) && node$rule == "AND") {
      node$true_index <- 1 / unanswered_count
      node$false_index <- 1.0
    } else if (!is.na(node$rule) && node$rule == "OR") {
      node$true_index <- 1.0
      node$false_index <- 1 / unanswered_count
    }
  }
}

#' @title Calculate the Influence Index for a Leaf Node
#'
#' @description
#' Determines the strategic importance (the "influence") of asking an unanswered
#' leaf question. The influence is calculated by aggregating the logical indices
#' (`true_index` and `false_index`) of all its ancestor nodes.
#'
#' @details
#' The influence index is a measure of how much a single leaf's answer can
#' contribute to the final conclusion. It is calculated as the sum of two
#' products:
#' Influence = `prod(ancestor_true_indices) + prod(ancestor_false_indices)`
#'
#' The function will set `influence_index` to `NA` under two conditions,
#' as the question is considered moot:
#' 1.  The leaf node itself has already been answered.
#' 2.  Any of the leaf's ancestors has a determined `answer` (`TRUE` or `FALSE`),
#'     meaning the branch has already been logically resolved.
#'
#' This function is intended to be used with `tree$Do(..., filterFun = isLeaf)`.
#'
#' @param node A `data.tree` `Node` object, which must be a leaf.
#'
#' @return The function has no return value; it modifies the `influence_index`
#'   attribute of the input `node` by side-effect.
#'
#' @keywords internal
#'
calculate_influence <- function(node) {

  # if any ancestor is already resolved, set values to NA (no longer have any influence)
  ancestor_answers <- unlist(node$Get("answer", traversal = "ancestor"))
  if (!is.na(node$answer) || any(!is.na(ancestor_answers))) {
    node$influence_index <- NA
    node$influence_if_true <- NA
    node$influence_if_false <- NA
    return()
  }

  # Get ancestor index vectors
  true_indices_vec <- node$Get('true_index', traversal = "ancestor")
  false_indices_vec <- node$Get('false_index', traversal = "ancestor")

  # Calculate the two components of the influence
  prod_true <- prod(true_indices_vec[-1], na.rm = TRUE)
  prod_false <- prod(false_indices_vec[-1], na.rm = TRUE)

  # Assign all three values to the node
  node$influence_if_true <- prod_true
  node$influence_if_false <- prod_false
  node$influence_index <- prod_true + prod_false
}

#' @title Update a Tree Based on Answers Provided
#'
#' @description
#' Propagate the results up to the tree nodes based on the answers provided,
#' and update the influence index to identify most important questions.
#'
#' @param tree The `data.tree` object to be modified.
#'
#' @return Returns the modified `tree` object invisibly, which allows for function chaining.
#' @importFrom data.tree isLeaf
#'
#' @export
#' @examples
#' # Load a tree
#' ethical_tree <- load_tree_df(ethical)
#'
#' # Internal indices before update
#' print(ethical_tree, "rule", "true_index", "false_index", influence = "influence_index")
#'
#' ethical_tree <- update_tree(ethical_tree)
#'
#' # Updated indices
#' print(ethical_tree, "rule", "true_index", "false_index", influence = "influence_index")
#'
#' # Answer some questions
#' set_answer(ethical_tree, "FIN2", TRUE, 4)
#' set_answer(ethical_tree, "ENV2", TRUE, 3)
#' set_answer(ethical_tree, "SOC2", TRUE, 4)
#' set_answer(ethical_tree, "GOV2", FALSE, 1)
#'
#' # Updated again
#' ethical_tree <- update_tree(ethical_tree)
#'
#' # Updated indices
#' print(ethical_tree, "rule", "true_index", "false_index", influence = "influence_index")
#'
#' # Updated results
#' print_tree(ethical_tree)
#'
update_tree <- function(tree) {
  tree <- calculate_tree(tree)
  tree$Do(assign_indices)
  tree$Do(calculate_influence, filterFun = isLeaf)
  return(tree)
}



