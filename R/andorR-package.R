#' andorR: An Analysis and Optimisation Tool for AND-OR Decision Trees
#'
#' @description
#' The `andorR` package provides a suite of tools to create, analyze, and
#' interactively solve complex logical decision trees. It is designed for
#' problems where a final TRUE/FALSE conclusion is determined by propagating
#' answers and their associated confidence scores up a hierarchical structure
#' of AND/OR rules. The package's core feature is an optimization algorithm that
#' guides the user to the most influential questions, minimizing the effort
#' required to reach a confident conclusion.
#'
#' @section Key Functions:
#' The main workflow is built around a few key functions:
#' \itemize{
#'   \item \code{\link{load_tree_csv}}, \code{\link{load_tree_df}},
#'     \code{\link{load_tree_yaml}}, \code{\link{load_tree_node_list}},
#'     \code{\link{load_tree_df_path}}, \code{\link{load_tree_csv_path}}: Load
#'     your decision tree from different formats.
#'   \item \code{\link{set_answer}}: Answer a question and provide a confidence
#'     score.
#'   \item \code{\link{update_tree}}: The core calculation engine that initializes
#'     and recalculates all logical states and influence indices.
#'   \item \code{\link{get_highest_influence}},
#'     \code{\link{get_confidence_boosters}}: Prioritisation of questions to
#'     optimise the completion of the tree.
#'   \item \code{\link{print_tree}} and \code{\link{print_questions}}: Visualise
#'     the state of the tree
#'   \item \code{\link{andorR_interactive}}: The main, user-facing function that
#'     automates the entire analysis in a step-by-step interactive session.
#' }
#'
#' @section Full Tutorials (Vignettes):
#' To learn how to use the package in detail, please see the vignettes:
#' - \href{../doc/andorR-intro.html}{Introduction to andorR}
#' - \href{../doc/data-formats.html}{Data Formats for andorR}
#' - \href{../doc/tree-optimisation.html}{Optimisation of AND-OR Decision Trees}
#' - \href{../doc/confidence-boosting.html}{Confidence Boosting and Sensitivity Analysis}
#' - \href{../doc/example-data-files.html}{Example Data Files}

#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
