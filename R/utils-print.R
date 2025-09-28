#' @title Print a Styled, Formatted Summary of the Decision Tree
#' @description
#' Displays a clean, perfectly aligned, color-coded summary of the tree's
#' current state, based on pre-calculated `answer` attributes.
#'
#' @param tree The `data.tree` object (the root `Node`) to be printed.
#'
#' @return The original `tree` object (returned invisibly).
#' @importFrom cli col_green col_red col_cyan col_blue style_bold ansi_strip
#' @importFrom crayon strip_style
#' @export
#' @details
#' An alternative approach to inspect internal attributes is to use the
#' `data.tree` print() function with named attributes. See the example below.
#'
#' Available attributes include:
#' - rule : AND or OR for a node
#' - name : The name of the node or leaf
#' - question : The question for leaves
#' - answer : The response provided for leaves or the calculated status of nodes
#' - confidence : The confidence score provided for leaves (0 - 5) or the
#'     probability that the answer is correct (50% to 100%) for nodes
#' - true_index : Influence the node has on the overall conclusion,
#'      if the response is TRUE
#' - false_index : Influence the node has on the overall conclusion,
#'      if the response is FALSE
#' - influence_if_true: Influence the leaf has on the overall conclusion,
#'      if the response is TRUE. This is the product of the ancestor values of
#'      true_index
#' - influence_if_false: Influence the leaf has on the overall conclusion,
#'      if the response is FALSE. This is the product of the ancestor values of
#'      false_index
#' - influence_index : The sum of influence_if_true and influence_if_false
#'      for each unanswered leaf
#'
#' @examples
#' # Load a tree
#' ethical_tree <- load_tree_df(ethical)
#'
#' # View the tree - initially all 'plain' as no answers
#' print_tree(ethical_tree)
#'
#' # Set an answer for leaf 'FIN2' and update the tree
#' ethical_tree <- set_answer(ethical_tree, "FIN2", TRUE, 3)
#' ethical_tree <- update_tree(ethical_tree) # Crucial: update the tree to propagate answers
#' print_tree(ethical_tree)
#'
#' # Alternative approach to inspect internal attributes using `data.tree::print()
#' # First, recalculate the internal indices
#' update_tree(ethical_tree)
#'
#' # Then print the tree, renaming column headings if required
#' print(ethical_tree, "rule", "true_index", "false_index", influence = "influence_index")
print_tree <- function(tree) {

  col_starts <- c(Tree = 0, Rule = 50, Answer = 60, Confidence = 72)
  tree_col_width <- col_starts["Rule"] - 2

  # A helper to print one formatted line
  print_formatted_line <- function(node, prefix = "") {
    # Determine style based directly on node$answer
    style_func <- identity # Default to no color
    if (isTRUE(node$answer)) {
      style_func <- cli::col_green
    } else if (isFALSE(node$answer)) {
      style_func <- cli::col_red
    }

    styled_name <- style_func(node$name)

    tree_part <- paste0(prefix, styled_name)
    if (nchar(crayon::strip_style(tree_part)) > tree_col_width) {
      overflow <- nchar(crayon::strip_style(tree_part)) - tree_col_width + 3
      new_name_len <- nchar(node$name) - overflow
      if (new_name_len < 1) new_name_len <- 1
      trunc_name <- paste0(strtrim(node$name, new_name_len), "...")
      styled_name <- style_func(trunc_name)
      tree_part <- paste0(prefix, styled_name)
    }
    rule_str <- if (!is.null(node$rule) && !is.na(node$rule)) cli::col_cyan(node$rule) else ""
    answer_str <- if (!is.null(node$answer) && !is.na(node$answer)) style_func(toupper(as.character(node$answer))) else ""
    conf_str <- ""
    if (!is.na(node$confidence)) {
      if (node$isLeaf) conf_str <- cli::col_cyan(as.character(round((node$confidence - 0.5) * 10, 1)))
      else conf_str <- cli::col_blue(paste0(round(node$confidence * 100, 1), "%"))
    }

    line <- tree_part
    padding1 <- paste(rep(" ", max(1, col_starts["Rule"] - nchar(crayon::strip_style(line)))), collapse = "")
    line <- paste0(line, padding1, rule_str)
    padding2 <- paste(rep(" ", max(1, col_starts["Answer"] - nchar(crayon::strip_style(line)))), collapse = "")
    line <- paste0(line, padding2, answer_str)
    padding3 <- paste(rep(" ", max(1, col_starts["Confidence"] - nchar(crayon::strip_style(line)))), collapse = "")
    line <- paste0(line, padding3, conf_str)

    cat(line, "\n")
  }

  # The recursive helper function
  print_children_recursive <- function(parent_node, ancestors_is_last) {
    children <- parent_node$children
    n_children <- length(children)
    if (n_children == 0) return()

    for (i in 1:n_children) {
      child <- children[[i]]
      is_last <- (i == n_children)

      prefix <- ""
      if(length(ancestors_is_last) > 0) {
        for(j in 1:length(ancestors_is_last)) {
          indent_segment <- if (ancestors_is_last[[j]]) "    " else "|   "
          prefix <- paste0(prefix, indent_segment)
        }
      }

      connector <- if (is_last) "`-- " else "|-- "

      print_formatted_line(child, paste0(prefix, connector))

      print_children_recursive(child, c(ancestors_is_last, is_last))
    }
  }

  # --- Main Function Body ---

  header <- sprintf("%-*s%-*s%-*s%-*s",
                    col_starts["Rule"]-1, "Tree",
                    col_starts["Answer"]-col_starts["Rule"], "Rule",
                    col_starts["Confidence"]-col_starts["Answer"], "Answer",
                    12, "Confidence")
  cat(cli::style_bold(header), "\n")

  # Print root and start recursion
  print_formatted_line(tree, "")
  print_children_recursive(tree, c())

  invisible(tree)
}

#' @title Get a Data Frame Summary of All Leaf Questions
#' @description Traverses the tree to find all leaf nodes (questions) and
#'   compiles their key attributes into a single, tidy data frame. This is
#'   useful for getting a complete overview of the analysis state or for
#'   creating custom reports.
#'
#' @param tree The `data.tree` object to be summarised.
#'
#' @return A `data.frame` with one row for each leaf node and the following
#'   columns: `name`, `question`, `answer`, `confidence` (on a 0-5 scale),
#'   and `influence_index`.
#'
#' @importFrom data.tree Traverse isLeaf
#' @export
#' @examples
#' # Load the example 'ethical' dataset
#' data(ethical)
#'
#' # Build and initialise the tree object
#' ethical_tree <- load_tree_df(ethical)
#' ethical_tree <- update_tree(ethical_tree)
#'
#' # Get the summary data frame of all questions
#' questions_df <- get_questions(ethical_tree)
#'
#' # Display the first few rows
#' head(questions_df)

get_questions <- function(tree) {

  # Get a  list of all leaf nodes.
  leaves <- Traverse(tree, filterFun = isLeaf)

  # Build the data frame column by column from this list.
  questions_df <- data.frame(
    name = sapply(leaves, function(n) ifelse(is.null(n$name), NA_character_, n$name)),
    question = sapply(leaves, function(n) ifelse(is.null(n$question), NA_character_, n$question)),
    answer = sapply(leaves, function(n) ifelse(is.null(n$answer), NA, n$answer)),
    confidence = sapply(leaves, function(n) {
      conf_val <- n$confidence
      if (is.null(conf_val) || is.na(conf_val)) {
        return(NA_real_)
      } else {
        # Back-convert to 0-5 scale
        return((conf_val - 0.5) * 10)
      }
    }),

    influence_if_true = sapply(leaves, function(n) n$influence_if_true),
    influence_if_false = sapply(leaves, function(n) n$influence_if_false),
    influence_index = sapply(leaves, function(n) n$influence_index),

    stringsAsFactors = FALSE
  )

  # Ensure the answer column is logical
  questions_df$answer <- as.logical(questions_df$answer)

  return(questions_df)
}


