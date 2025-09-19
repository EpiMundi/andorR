#' Notifiable aquatic animal disease decision tree
#' @format A data frame with 5 variables and 50 rows, in 'parent' format, in
#'   which hierarchical relationships are indicated by a value indicating
#'   the parent of each node.
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
#' @source This example is basedon a decision tree developed to guide provincial
#'    governements on the Canada Atlantic coast in their decisions on the
#'    listing or de-listing of notifiable aquatic animal diseases.
"notifiable"

#' Ethical investment decision tree for a fictional company
#' @format A data frame with 5 variables and 34 rows, in 'parent' format, in
#'   which hierarchical relationships are indicated by a value indicating
#'   the parent of each node.
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
"ethical"

