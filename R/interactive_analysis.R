#' @title Identify the Most Influential Question(s)
#' @description
#' Scans all leaf nodes in the tree to find the questions that
#' currently have the highest `influence_index`.
#'
#' @param tree The main `data.tree` object for the analysis.
#' @param top_n The number of top-ranked questions to return.
#' @param sort_by A character string indicating how the prioritised questions
#' should be sorted. Options are:
#' - "TRUE" : Sort by the product of the node true_index for all ancestors, which
#'    measures the influence of the question if it is answered TRUE
#' - "FALSE" : Sort by the product of the node false_index for all ancestors, which
#'    measures the influence of the question if it is answered FALSE
#' - "BOTH" : (Default) Sort by the sum of 'TRUE' and 'FALSE' values which measures
#'    the aggregate influence of the question before the answer is known
#'
#' @return A `data.frame` (tibble) containing the `name`, `question`, the
#'   components of the influence index (`influence_if_true`, `influence_if_false`),
#'   and the total `influence_index` for the highest-influence leaf/leaves,
#'   sorted by influence.
#'
#' @importFrom data.tree Traverse isLeaf
#' @importFrom dplyr %>% filter select arrange desc
#' @importFrom utils head
#' @export
#'
get_highest_influence <- function(tree, top_n = 5, sort_by = "BOTH") {

  # Get a stable list of all leaf nodes
  leaves <- Traverse(tree, filterFun = isLeaf)

  # Return NULL if there are no leaves
  if (length(leaves) == 0) return(invisible(NULL))

  # Build a data frame with all necessary attributes, including the new ones
  leaf_data <- data.frame(
    name = sapply(leaves, function(n) n$name),
    question = sapply(leaves, function(n) n$question),
    influence_if_true = sapply(leaves, function(n) {
      if (!is.na(n$answer)) return(NA_real_)
      vec <- n$Get('true_index', traversal = "ancestor")
      return(prod(vec[-1], na.rm = TRUE))
    }),
    influence_if_false = sapply(leaves, function(n) {
      if (!is.na(n$answer)) return(NA_real_)
      vec <- n$Get('false_index', traversal = "ancestor")
      return(prod(vec[-1], na.rm = TRUE))
    }),
    influence_index = sapply(leaves, function(n) n$influence_index)
  )

  # Filter for eligible leaves (those that have a calculated influence)
  eligible_leaves <- leaf_data %>%
    filter(!is.na(influence_index))

  if (nrow(eligible_leaves) == 0) return(invisible(NULL))

  # Arrange by influence, take the top n, and select the final columns
  if (sort_by == "TRUE") sort_index <- 'influence_if_true'
  else if (sort_by == "FALSE") sort_index <- 'influence_if_false'
  else sort_index <- 'influence_index'

  highest_influence_leaves <- eligible_leaves %>%
    arrange(desc(.data[[sort_index]])) %>%
    #arrange(desc(sort_index)) %>%
    head(top_n) %>%
    select(name, question, influence_if_true, influence_if_false, influence_index)

  return(highest_influence_leaves)
}

#' @title Find Actions to Most Effectively Boost Confidence
#' @description Performs a sensitivity analysis on the tree to find which actions
#' (answering a new question or increasing confidence in an old one) will have
#' the greatest positive impact on the root node's final confidence score.
#' @param tree The current data.tree object, typically after a conclusion is reached.
#' @param top_n The number of suggestions to return.
#' @param verbose Logical value (default TRUE) determining the level of output.
#' @return A data.frame of the top_n suggested actions, ranked by potential gain.
#' @importFrom data.tree Traverse Clone FindNode
#' @importFrom dplyr %>% filter arrange desc
#' @importFrom utils head
#' @importFrom cli cli_process_start cli_process_done symbol
#' @export
#' @examples
#' # Load a tree
#' ethical_tree <- load_tree_df(ethical)
#'
#' # Answer some questions
#' set_answer(ethical_tree, "FIN2", TRUE, 4)
#' set_answer(ethical_tree, "FIN4", TRUE, 3)
#' set_answer(ethical_tree, "FIN5", TRUE, 2)
#' set_answer(ethical_tree, "ENV5", TRUE, 3)
#' set_answer(ethical_tree, "SOC2", TRUE, 4)
#' set_answer(ethical_tree, "GOV1", TRUE, 1)
#' set_answer(ethical_tree, "GOV2", TRUE, 2)
#' set_answer(ethical_tree, "GOV3", TRUE, 1)
#' set_answer(ethical_tree, "GOV4", TRUE, 1)
#' set_answer(ethical_tree, "GOV5", TRUE, 1)
#'
#' # Updated tree
#' ethical_tree <- update_tree(ethical_tree)
#'
#' # View the tree
#' print_tree(ethical_tree)
#'
#' # Get guidance on how to improve the confidence ---
#' guidance <- get_confidence_boosters(ethical_tree, verbose = FALSE)
#' print(guidance)
#'
get_confidence_boosters <- function(tree, top_n = 5, verbose = TRUE) {

  current_root_conf <- tree$confidence
  if (is.na(current_root_conf)) {
    cat("Cannot provide guidance until an initial conclusion is reached.\n")
    return(invisible(NULL))
  }

  suggestions <- list()

  # --- Analysis 1: Find the impact of answering NEW questions ---
  unanswered_leaves <- Traverse(tree, filterFun = function(node) node$isLeaf && is.na(node$answer))

  if (length(unanswered_leaves) > 0) {
    # start the spinner
    if(verbose) id <- cli_process_start("Analysing {length(unanswered_leaves)} unanswered questions...")
    # start the loop
    for (leaf in unanswered_leaves) {
      # Simulate answering TRUE with max confidence (5)
      tree_clone_t <- data.tree::Clone(tree)
      node_in_clone_t <- FindNode(tree_clone_t, leaf$name)
      if (!is.null(node_in_clone_t)) {
        node_in_clone_t$answer <- TRUE
        node_in_clone_t$confidence <- 1.0
      }
      calculate_tree(tree_clone_t)
      conf_if_true <- tree_clone_t$root$confidence

      # Simulate answering FALSE with max confidence (5)
      tree_clone_f <- data.tree::Clone(tree)
      node_in_clone_f <- FindNode(tree_clone_f, leaf$name)
      if (!is.null(node_in_clone_f)) {
        node_in_clone_f$answer <- FALSE
        node_in_clone_f$confidence <- 1.0
      }
      calculate_tree(tree_clone_f)
      conf_if_false <- tree_clone_f$root$confidence

      # Determine which answer provides a better potential outcome
      gain_t <- ifelse(is.na(conf_if_true), 0, conf_if_true - current_root_conf)
      gain_f <- ifelse(is.na(conf_if_false), 0, conf_if_false - current_root_conf)

      if (gain_t > gain_f) {
        suggestions[[leaf$name]] <- list(action = "Answer New Question",
                                         name = leaf$name,
                                         question = leaf$question,
                                         details = "Suggest answering TRUE",
                                         potential_gain = gain_t)
      } else {
        suggestions[[leaf$name]] <- list(action = "Answer New Question",
                                         name = leaf$name,
                                         question = leaf$question,
                                         details = "Suggest answering FALSE",
                                         potential_gain = gain_f)
      }
    }
    if(verbose) cli_process_done(id, "Analysed {length(unanswered_leaves)} unanswered questions {symbol$tick}")
  }

  # --- Analysis 2: Find the impact of increasing confidence on OLD answers ---
  answered_leaves <- Traverse(tree, filterFun = function(node) node$isLeaf && !is.na(node$answer) && node$confidence < 1.0)

  if (length(answered_leaves) > 0) {
    if(verbose) id2 <- cli_process_start("Analysing {length(answered_leaves)} existing answers...")

    for (leaf in answered_leaves) {
      # Simulate re-answering with max confidence
      tree_clone <- data.tree::Clone(tree)
      node_in_clone <- FindNode(tree_clone, leaf$name)
      if (!is.null(node_in_clone)) {
        node_in_clone$confidence <- 1.0
      }
      calculate_tree(tree_clone)
      conf_if_max <- tree_clone$root$confidence

      gain <- ifelse(is.na(conf_if_max), 0, conf_if_max - current_root_conf)

      if (gain > 0 && (is.null(suggestions[[leaf$name]]) || gain > suggestions[[leaf$name]]$potential_gain)) {
        current_conf_0_5 <- (leaf$confidence - 0.5) * 10
        suggestions[[leaf$name]] <- list(action = "Increase Confidence",
                                         name = leaf$name,
                                         question = leaf$question,
                                         details = paste0("Current conf: ", round(current_conf_0_5, 1), "/5"),
                                         potential_gain = gain)
      }
    }
    if(verbose) cli_process_done(id2, "Analysed {length(answered_leaves)} existing answers {symbol$tick}")
  }

  if (length(suggestions) == 0) {
    cat("No further actions found to boost confidence.\n")
    return(data.frame())
  }

  # --- Combine, rank, and return the results ---
  results_df <- do.call(rbind.data.frame, suggestions)
  results_df <- results_df %>%
    filter(potential_gain > 0) %>%
    arrange(desc(potential_gain)) %>%
    head(top_n)

  if(nrow(results_df) > 0) {
    results_df$potential_gain <- paste0("+", round(results_df$potential_gain * 100, 2), "%")
  } else {
    cat("No further actions found to boost confidence.\n")
    return(data.frame())
  }

  return(results_df)
}


#' @title Set an Answer and Confidence for a Leaf Node
#'
#' @description
#' This is the primary function for providing evidence to the tree. It finds a
#' specific leaf node by its name and updates its `answer` and `confidence`
#' attributes based on user input.
#'
#' @details
#' The function takes a 0-5 confidence level from the user and converts it to an
#' internal score between 0.5 (uncertain) and 1.0 (certain) using the formula:
#' `score = 0.5 + (confidence_level / 10)`.
#'
#' It includes validation to ensure the target node exists, is a leaf, and that
#' the provided response is a valid logical value. A confirmation message is
#' printed to the console upon successful update.
#'
#' @param tree The `data.tree` object to be modified.
#' @param node_name A character string specifying the `name` of the leaf node to update.
#' @param response A logical value, `TRUE` or `FALSE`, representing the answer.
#' @param confidence_level A numeric value from 0 to 5 representing the user's
#'   confidence in the answer. Confidence levels are semi-quantitative and map
#'   to the following probabilities:
#'   - 0 : 50%
#'   - 1 : 60%
#'   - 2 : 70%
#'   - 3 : 80%
#'   - 4 : 90%
#'   - 5 : 100%
#' @param verbose An optional logical value controlling output. Default is TRUE.
#'
#' @return Returns the modified `tree` object invisibly, which allows for function chaining.
#'
#' @importFrom data.tree FindNode
#' @export
#' @examples
#' # Load a tree
#' ethical_tree <- load_tree_df(ethical)
#'
#' # View the tree
#' print_tree(ethical_tree)
#'
#' # Set an answer for leaf 'A1'
#' ethical_tree <- set_answer(ethical_tree, "FIN2", TRUE, 3)
#' print_tree(ethical_tree)
#'
set_answer <- function(tree, node_name, response, confidence_level, verbose = TRUE) {
  node_to_update <- FindNode(tree, node_name)
  if (is.null(node_to_update)) {
    warning(paste0("Node '", node_name, "' not found in the tree."), call. = FALSE)
    return(invisible(tree))
  }
  if (!node_to_update$isLeaf) {
    warning(paste0("Node '", node_name, "' is a parent node. Answers can only be set for leaves."), call. = FALSE)
    return(invisible(tree))
  }
  if (!is.logical(response) || is.na(response)) {
    warning("Invalid response. Please provide TRUE or FALSE.", call. = FALSE)
    return(invisible(tree))
  }
  node_to_update$answer <- response
  node_to_update$confidence <- 0.5 + (confidence_level / 10)
  if(verbose) {
    cat(paste("Answer for leaf '", node_name, "' set to: ", response,
              " with confidence ", confidence_level, "/5\n", sep = ""))
  }
  return(invisible(tree))
}




###########################################################################
# Interactive analysis loop
###########################################################################

#' @title Enter Interactive Analysis Mode
#'
#' @description
#' Iteratively prompts the user to answer questions to solve a decision tree.
#' The function first presents the most impactful unanswered questions. Once the
#' tree's root is solved, it presents questions that can increase the overall
#' confidence of the conclusion.
#'
#' @details
#' This function provides a command-line interface (CLI) for working with the
#' tree. It uses the `cli` package for formatted output and handles user input
#' for quitting, saving, printing the tree state, or providing answers to
#' specific questions (either by number or by name). All tree modifications are
#' performed by calling the package's existing API functions:
#' - `set_answer()`
#' - `update_tree()`
#' - `get_highest_influence()`
#' - `get_confidence_boosters()`
#'
#' The following key commands may be used during interactive mode:
#' - **h** : Show the help screen
#' - **p** : Print the current state of the tree
#' - **s** : Save the current state of the tree to an .rds file
#' - **q** : Quit (exit interactive mode)
#' - **n** : Specify a node to edit by name (case sensitive)
#' - **1, 2, ...** : Specify a node to edit from the numbered list
#'
#' @param tree The `data.tree` object to be analysed.
#' @param sort_by A character string indicating how the prioritised questions
#' should be sorted. Options are:
#' - "TRUE" : Sort by the product of the node true_index for all ancestors, which
#'    measures the influence of the question if it is answered TRUE
#' - "FALSE" : Sort by the product of the node false_index for all ancestors, which
#'    measures the influence of the question if it is answered FALSE
#' - "BOTH" : (Default) Sort by the sum of 'TRUE' and 'FALSE' values which measures
#'    the aggregate influence of the question before the answer is known
#'
#' @return The final, updated `data.tree` object.
#' @importFrom data.tree FindNode isLeaf ToDataFrameTypeCol
#' @importFrom cli cli_verbatim cli_alert_danger cli_alert_info cli_alert_success cli_div cli_dl cli_h1 cli_h2 cli_ol cli_rule cli_text col_blue col_red col_cyan col_yellow style_bold
#' @importFrom dplyr %>% filter select arrange
#' @importFrom rlang .data
#' @importFrom stats setNames
#' @export
#' @examples
#' # Load a tree
#' ethical_tree <- load_tree_df(ethical)
#'
#' # Start interactive mode
#' \dontrun{
#' andorR_interactive(ethical_tree)
#' }
#'
andorR_interactive <- function(tree, sort_by = "BOTH") {

  # --- Local Helper Function to display the introduction to interactive mode ---
  # ------------------------------------------------------
  print_intro <- function() {

    version_string <- tryCatch({
      as.character(utils::packageVersion("andorR"))
    }, error = function(e) {
      "in-development"
    })

    cli::cli_h1("andorR")
    cli::cli_text("{.emph An analysis and optimisation tool for AND-OR decision trees.}")
    cli::cli_text("")

    cli::cli_text("Created by: EpiMundi ({.url https://epimundi.com})")
    cli::cli_text("Author:     {.strong Angus Cameron}")
    cli::cli_text("Email:      angus@epimundi.com")
    cli::cli_text("Version:    {version_string}")
    cli::cli_text("")

  }


  # --- Local Helper Function to display the help menu ---
  # ------------------------------------------------------
  display_interactive_help <- function() {
    cli_div(theme = list(rule = list(color = "blue")))
    cli_rule(left = style_bold("Help Menu"))
    cli_text( col_red("h"), ": Show this help message.")
    cli_text( col_red("q"), ": Quit the interactive session.")
    cli_text( col_red("p"), ": Print the current state of the tree.")
    cli_text( col_red("s"), ": Save the current tree state to an .rds file.")
    cli_text( col_red("n"), ": Specify a node to edit by typing its name.")
    cli_text( col_red("1, 2, ..."), ": Select a numbered question from the list to answer.")
    cli_rule()
  }

  # --- Local Helper Function to prompt for an answer and update the tree ---
  # ------------------------------------------------------
  prompt_for_answer_and_update <- function(tree_obj, node_name_to_edit) {
    target_node <- FindNode(tree_obj, node_name_to_edit)
    if (is.null(target_node)) {
      cli_alert_danger("Node {.val {node_name_to_edit}} not found.")
      return(tree_obj)
    }
    if (!target_node$isLeaf) {
      cli_alert_danger("Node {.val {node_name_to_edit}} is a parent node. Answers can only be set for leaves.")
      return(tree_obj)
    }

    cli_rule(left = style_bold(glue::glue("Editing Node: {node_name_to_edit}")))
    cli_text(target_node$question)

    # Prompt for new answer
    repeat {
      answer_prompt <- style_bold("Answer (t/true or f/false): ")
      raw_answer <- tolower(trimws(readline(prompt = answer_prompt)))
      if (raw_answer %in% c("t", "true")) { new_answer <- TRUE; break }
      if (raw_answer %in% c("f", "false")) { new_answer <- FALSE; break }
      cli_alert_danger("Invalid input. Please enter 't' or 'f'.")
    }

    # Prompt for new confidence
    repeat {
      conf_prompt <- style_bold("Confidence (0-5): ")
      raw_conf <- trimws(readline(prompt = conf_prompt))
      if (grepl("^[0-5]$", raw_conf)) { new_conf <- as.integer(raw_conf); break }
      cli_alert_danger("Invalid input. Please enter a number between 0 and 5.")
    }

    # Set the answer
    tree_obj <- set_answer(tree_obj, node_name_to_edit, new_answer, new_conf)
    return(tree_obj)
  }


  # ------------------------------------------------------
  # --- Main Function Logic ---
  # ------------------------------------------------------
  print_intro()
  display_interactive_help()

  # Initialise the tree state
  tree <- update_tree(tree)

  previous_tree_solved <- FALSE

  repeat {
    # Update status variables
    root_node <- tree
    tree_solved <- !is.null(root_node$answer) && !is.na(root_node$answer)

    if (tree_solved && !previous_tree_solved) {
      cli_rule()
      cli_h2("Conclusion Reached!")
      answer_style <- if (isTRUE(root_node$answer)) cli::col_green else cli::col_red
      styled_answer <- answer_style(toupper(as.character(root_node$answer)))
      cli_text("The current result is: ", styled_answer, " at a confidence of ", root_node$confidence)
      cli_text("You can now answer more questions or revise existing answers to boost confidence.")
    }

    tree_finished <- tree_solved && isTRUE(root_node$confidence == 1.0)
    if (tree_finished) {
      cli_alert_success("Tree solved with 100% confidence! Quitting.")
      break
    }

    # Get and display the list of questions
    cli_rule()
    questions_to_ask <- NULL

    if (!tree_solved) {
      cli_h2("Highest Impact Questions")
      questions_to_ask <- get_highest_influence(tree, top_n=10, sort_by = sort_by)
    } else {
      questions_to_ask <- get_confidence_boosters(tree, top_n=10)
      cli_h2("Questions to Boost Confidence")
    }

    if (!is.null(questions_to_ask) && nrow(questions_to_ask) > 0) {
      if (!tree_solved) {
        header1 <- glue::glue(
          "        [ {col_blue('Influence Index')}  ]"
        )
        header2 <- glue::glue(
          "ID {col_yellow('Name')} [{col_green('True')} |{col_red('False')} |{col_blue('Total')}] {'Question'}"
        )
        cli_verbatim(header1)
        cli_verbatim(header2)
        q_list <- setNames(
          glue::glue(
            "{col_yellow(questions_to_ask$name)} ",
            "[{col_green(sprintf('%.2f', questions_to_ask$influence_if_true))} | ",
            "{col_red(sprintf('%.2f', questions_to_ask$influence_if_false))} | ",
            "{col_blue(sprintf('%.2f', questions_to_ask$influence_index))}] ",
            "{questions_to_ask$question}"
          ),
          1:nrow(questions_to_ask)
        )
      } else {
        q_list <- setNames(
          glue::glue(
            "[{col_yellow(questions_to_ask$name)}] ",
            "{col_cyan(questions_to_ask$action)} ",
            "{col_green(questions_to_ask$details)} ",
            "{col_red(questions_to_ask$potential_gain)}"),
          1:nrow(questions_to_ask)
        )
      }
      cli_ol(q_list)
    } else {
      cli_alert_info("No more applicable questions to answer.")
    }
    cli_rule()

    # Get user input
    prompt <- style_bold(col_cyan("Enter a number, 'n', or command (h, p, s, q): "))
    user_input <- tolower(trimws(readline(prompt = prompt)))
    if (user_input == "") next

    # Process user input
    is_numeric_choice <- grepl("^[0-9]+$", user_input)

    if (is_numeric_choice) {
      choice_num <- as.integer(user_input)
      if (!is.null(questions_to_ask) && choice_num > 0 && choice_num <= nrow(questions_to_ask)) {
        node_to_edit <- questions_to_ask$name[choice_num]
        tree <- prompt_for_answer_and_update(tree, node_to_edit)
      } else {
        cli_alert_danger("Invalid number. Please choose from the list.")
      }
    } else {
      switch(user_input,
             "q" = { cli_alert_info("Quitting interactive session."); break },
             "h" = display_interactive_help(),
             "p" = { cli_h2("Current Tree State"); print_tree(tree) },
             "s" = {
               filename <- readline(prompt = style_bold("Enter filename (e.g., 'tree.rds'): "))
               if (filename != "") {
                 saveRDS(tree, filename)
                 cli_alert_success("Tree saved to {.file {filename}}")
               }
             },
             "n" = {
               node_name <- readline(prompt = style_bold("Enter the node name to edit: "))
               tree <- prompt_for_answer_and_update(tree, node_name)
             },
             cli_alert_danger("Invalid command. Press 'h' for help.")
      )
    }

    # After any action that changes an answer, update the entire tree state
    tree <- update_tree(tree)
    previous_tree_solved <- tree_solved
  }

  cli_h1("Exiting Interactive Mode")
  return(invisible(tree))
}
