#' @title Ethical investment decision tree for a fictional company - data frame format
#' @description
#'   This dataframe represents a decision tree in relational format, in
#'   which hierarchical relationships are indicated by a value indicating
#'   the parent of each node.
#'
#'   The decision tree is a hypothetical tool to standardise the process of
#'   making ethical investments. It was developed to illustrate the functionality
#'   of this package.
#' @details
#'   A `data.tree` object is created from the dataframe using the `read_tree_df()`
#'   function.
#'
#' @docType data
#'
#' @keywords datasets
#'
#' @format A data frame with 5 variables and 34 rows
#'
#' \describe{
#'    Each rows represents a node or leaf in the tree and the columns represent
#'    attributes of those nodes. The columns are:
#'    \item{id}{A unique sequential numeric identifier for each node}
#'    \item{name}{A short, unique alphanumeric code or name for nodes. For
#'      leaf nodes (questions), a short code is used. For higher nodes, a
#'      descriptive phrase is used.}
#'    \item{question}{The full text of the question for leaves, or NA for
#'      higher nodes.}
#'    \item{rule}{The logical rule for nodes, either **AND** or **OR**, and
#'      NA for leaves.}
#'    \item{parent}{The numeric id of the parent node, and NA for the root node.}
#'
#' }
#' @source This is a simple hypothetical decision tree created solely to
#'    illustrate the use of the analytical approach.
#' @examples
#' # Read the data into a data.tree object for analysis
#' tree <- load_tree_df(ethical)
#'
#' # View the tree
#' print_tree(tree)
"ethical"

#' @title Ethical investment decision tree for a fictional company in hierarchical format
#' @description
#'   This dataframe represents a decision tree in hierarchical format, in
#'   which hierarchical relationships are indicated by a nested list
#'
#'   The decision tree is a hypothetical tool to standardise the process of
#'   making ethical investments. It was developed to illustrate the functionality
#'   of this package.
#' @details
#'   A `data.tree` object is created from the nested list using the
#'   `read_tree_node_list()` function.
#'
#' @docType data
#'
#' @keywords datasets
#'
#' @format A nested node list of the ethical investment dataset, in
#'   which hierarchical relationships are indicated by a nested list
#'
#' \describe{
#'    Each list element represents a node or leaf in the tree and has the
#'    following members:
#'    \item{name}{A short, unique alphanumeric code or name for nodes. For
#'      leaf nodes (questions), a short code is used. For higher nodes, a
#'      descriptive phrase is used.}
#'    \item{rule}{The logical rule for nodes, either **AND** or **OR**, and
#'      NA for leaves.}
#'    \item{question}{(Optional) For leaf nodes, the associated question.}
#'    \item{nodes}{A list of nested nodes}
#'
#' }
#' @source This is a simple hypothetical decision tree created solely to
#'    illustrate the use of the analytical approach.
#' @examples
#' # Read the data into a data.tree object for analysis
#' tree <- load_tree_node_list(ethical_nl)
#'
#' # View the tree
#' print_tree(tree)
"ethical_nl"
