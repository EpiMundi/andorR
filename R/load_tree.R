#############################################################################
# Load trees in different formats
#############################################################################

#' @title Build a decision tree from a relational data frame
#' @description Constructs and initialises a tree from a data frame that is
#'   already in memory, where the hierarchy is defined in a relational
#'   (ID/parent) format.
#'
#' @details This is a core constructor function. It may be used to load one of
#'   the example datasets in relational format. It is called by the
#'   `load_tree_csv()` wrapper, which handles reading the data from a file.
#'
#' @param df A data frame with columns: id, name, question, rule, parent.
#' @return A `data.tree` object, fully constructed and initialized with `answer`
#'   and `confidence` attributes set to `NA`.
#' @seealso [load_tree_csv()] to read this format from a file.
#' @importFrom data.tree Node
#' @export
#' @examples
#' # Load a tree from the 'ethical' dataframe included in this package
#' ethical_tree <- load_tree_df(ethical)
#'
#' # View the tree structure
#' \dontrun{
#' print_tree(ethical_tree)
#' }
load_tree_df <- function(df) {

  node_list <- list()

  # First pass: Create all nodes and store their attributes from the dataframe
  for (i in 1:nrow(df)) {
    row <- df[i, ]
    # Use the 'name' column for the node's display name
    node <- Node$new(row$name)

    # Copy all relevant columns as attributes to the node object
    node$id <- row$id
    node$question <- row$question
    node$rule <- row$rule
    node$parent_id <- row$parent # Store parent id for the linking step

    # Initialize the dynamic attributes for the analysis
    node$answer <- NA
    node$confidence <- NA

    # Add the newly created node to our lookup list
    node_list[[as.character(row$id)]] <- node
  }

  # Second pass: Link the nodes together into a tree structure
  for (node in node_list) {
    # Check if the node has a parent (the root will have NA)
    if (!is.na(node$parent_id)) {
      # Find the parent node in our list using its ID
      parent_node <- node_list[[as.character(node$parent_id)]]

      # Add the current node as a child of its parent
      if (!is.null(parent_node)) {
        parent_node$AddChildNode(node)
      }
    }
  }

  # The root of the tree is the node with id = 0
  tree <- node_list[['0']]

  return(tree)
}

#' @title Build a decision tree from a hierarchical list
#' @description Constructs a tree from a nested R list, where the hierarchy is
#'   defined by the list's structure. It also initializes the `answer` and
#'   `confidence` attributes required for the analysis.
#'
#' @details This is a core constructor function, typically called by the
#'   `load_tree_yaml()` wrapper, which handles parsing the YAML file into a list.
#' @param data_list A nested R list representing the tree structure. Each list
#'   element should have a `name` and can have other attributes like `question`,
#'   `rule`, and a sub-list named `nodes` containing its children.
#'
#' @return A `data.tree` object, fully constructed and initialized with `answer`
#'   and `confidence` attributes set to `NA`.
#' @seealso [load_tree_yaml()] to read this format from a file.
#' @importFrom data.tree Node
#' @export
#' @examples
#' # 1. Define the tree structure as a nested list
#' my_data_list <- list(
#'   name = "Root",
#'   rule = "OR",
#'   nodes = list(
#'     list(name = "Leaf A", question = "Is A true?"),
#'     list(name = "Branch B",
#'          rule = "AND",
#'          nodes = list(
#'            list(name = "Leaf B1", question = "Is B1 true?"),
#'            list(name = "Leaf B2", question = "Is B2 true?")
#'          )
#'     )
#'   )
#' )
#'
#' # 2. Build the tree from the list
#' my_tree <- load_tree_node_list(my_data_list)
#'
#' # 3. Print the resulting tree
#' print_tree(my_tree)
#'
load_tree_node_list <- function(data_list) {

  # Define a recursive helper function to build the tree
  recursive_builder <- function(current_list_item) {
    # 1. Create the node from the 'name' field.
    node_name <- if (!is.null(current_list_item$name)) current_list_item$name else "Unnamed Node"
    new_node <- Node$new(node_name)
    new_node$rule <- NA
    new_node$question <- NA


    # 2. Loop through all keys in the list item.
    for (key in names(current_list_item)) {
      # If the key is 'nodes', it's the list of children. Recurse.
      if (key == "nodes") {
        children_list <- current_list_item[[key]]
        if (is.list(children_list)) {
          for (child_item in children_list) {
            # Recursively build the child and add it to the current node
            new_child <- recursive_builder(child_item)
            new_node$AddChildNode(new_child)
          }
        }
        # Otherwise, if it's not the name, add it as a standard attribute.
      } else if (key != "name") {
        new_node[[key]] <- current_list_item[[key]]
      }
    }

    return(new_node)
  }

  # Start the recursive building process with the top-level list
  tree <- recursive_builder(data_list)

  # Initialize the dynamic attributes for all nodes.
  tree$Do(function(node) {
    node$answer <- NA
    node$confidence <- NA
  })

  return(tree)
}


#' @title Load a decision tree from a CSV file (Relational Format)
#' @description Reads a CSV file from a given path and constructs a tree. This
#'   function expects the CSV to define the tree in a relational
#'   format with `id` and `parent` columns defining the hierarchy and `name`,
#'   `question` (for leaves) and `rule` (for nodes) columns for the decision
#'   tree attributes.
#'
#' @param file_path The path to the .csv file.
#' @return A `data.tree` object, fully constructed and initialized with `answer`
#'   and `confidence` attributes set to `NA`.
#' @seealso [load_tree_df()] for the underlying constructor function.
#' @importFrom utils read.csv
#' @export
#' @examples
#' # Load data from the `ethical.csv` file included with this package
#' path <- system.file("extdata", "ethical.csv", package = "andorR")
#' ethical_tree <- load_tree_csv(path)
#'
#' # View the tree
#' print_tree(ethical_tree)
#'
load_tree_csv <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(paste("File not found at path:", file_path), call. = FALSE)
  }

  # Read the data from the CSV file
  df <- utils::read.csv(file_path, stringsAsFactors = FALSE)

  # Call your existing function to build the tree from the data frame
  tree <- load_tree_df(df)

  return(tree)
}

#' @title Load a decision tree from a YAML file (Hierarchical Format)
#' @description Reads a YAML file from a given path and constructs a tree. This
#'   function expects the YAML to define the tree in a hierarchical (nested)
#'   format. It uses `load_tree_node_list` to construct the tree object.
#'
#' @param file_path The path to the .yml or .yaml file.
#' @return A `data.tree` object, fully constructed and initialized with `answer`
#'   and `confidence` attributes set to `NA`.
#' @seealso [load_tree_node_list()] for the underlying constructor function.
#' @importFrom yaml read_yaml
#' @export
#' @examples
#' \dontrun{
#' #' # Load data from the `ethical.yml` file included with this package
#' path <- system.file("extdata", "ethical.yml", package = "andorR")
#' ethical_tree <- load_tree_yaml(path)
#'
#' # View the tree
#' print_tree(ethical_tree)
#' }
load_tree_yaml <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(paste("File not found at path:", file_path), call. = FALSE)
  }

  # Read the data from the YAML file into a list
  data_list <- yaml::read_yaml(file_path)

  # Call your existing function to build the tree from the list
  tree <- load_tree_node_list(data_list)

  return(tree)
}



#' @title Build a decision tree from a path-string data frame
#' @description Constructs a tree from a data frame that is already in memory,
#'   where the hierarchy is defined using a path string for each node (e.g.,
#'   "Root/Branch/Leaf").
#'
#' @details This is a core constructor function, typically called by a wrapper
#'   like `load_tree_csv_path()`, which handles reading the data from a file.
#'   The node's name is inferred from the last element of its path.
#'
#' @param df A data frame with a column named `path` containing the node paths,
#'   and other optional attribute columns like `question` and `rule`.
#' @param delim The character used to separate nodes in the path string.
#'   Defaults to "/".
#'
#' @return A `data.tree` object.
#' @seealso [load_tree_csv_path()] to read this format from a file.
#' @importFrom data.tree as.Node
#' @export
#' @examples
#' \dontrun{
#' # Create a sample data frame in path format
#' path_df <- data.frame(
#'   path = c("Root", "Root/Branch1", "Root/Branch1/LeafA", "Root/Branch2"),
#'   rule = c("AND", "OR", NA, NA),
#'   question = c(NA, "Is Branch1 relevant?", "Is LeafA true?", "Is Branch2 true?")
#' )
#'
#' # Build the tree
#' my_tree <- load_tree_df_path(path_df)
#' print(my_tree)
#' }
load_tree_df_path <- function(df, delim = "/") {

  tree <- as.Node(df, pathName = "path", pathDelimiter = delim)

  # Initialize the dynamic attributes for all nodes.
  tree$Do(function(node) {
    node$answer <- NA
    node$confidence <- NA
  })

  # Return the fully constructed and initialized tree.
  return(tree)
}

#' @title Load a decision tree from a CSV file (Path String Format)
#' @description Reads a CSV file from a given path and constructs a tree. This
#'   function expects the CSV to define the tree in a path string format, with
#'   each node's hierarchy defined in a column named `path`.
#'
#' @param file_path The path to the .csv file.
#' @param delim The character used to separate nodes in the path string.
#'   Defaults to "/".
#'
#' @return A `data.tree` object.
#' @seealso [load_tree_df_path()] for the underlying constructor function.
#' @importFrom utils read.csv
#' @export
#' @examples
#' \dontrun{
#' #' # Load data from the `ethical_path.csv` file included with this package
#' path <- system.file("extdata", "ethical_path.csv", package = "andorR")
#' ethical_tree <- load_tree_csv_path(path)
#'
#' # View the tree
#' print_tree(ethical_tree)
#' }
load_tree_csv_path <- function(file_path, delim = "/") {
  if (!file.exists(file_path)) {
    stop(paste("File not found at path:", file_path), call. = FALSE)
  }

  # Read the data from the CSV file
  df <- utils::read.csv(file_path, stringsAsFactors = FALSE)

  # Call your existing function to build the tree from the data frame
  tree <- load_tree_df_path(df, delim = delim)

  return(tree)
}


