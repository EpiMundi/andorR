# --- Test Setup ---

# Create a minimal, perfectly valid list to use as a base for tests.
valid_list <- list(
  name = "Root",
  rule = "OR",
  nodes = list(
    list(name = "L1", question = "Is the first condition met?"),
    list(name = "Node A",
         rule = "AND",
         nodes = list(
           list(name = "L2", question = "Is the second condition met?")
         )
    )
  )
)

# --- Start of Tests ---

test_that("validate_tree_list passes with valid data", {
  expect_true(validate_tree_list(valid_list))
})

test_that("validate_tree_list catches missing names", {
  invalid_list <- valid_list
  invalid_list$nodes[[1]]$name <- NULL # Remove name from a child
  expect_error(validate_tree_list(invalid_list), "missing its 'name' attribute")
})

test_that("validate_tree_list catches leaves with rules", {
  invalid_list <- valid_list
  invalid_list$nodes[[1]]$rule <- "AND" # Add a rule to a leaf
  expect_error(validate_tree_list(invalid_list), "cannot also have a 'rule'")
})

test_that("validate_tree_list catches leaves with children", {
  invalid_list <- valid_list
  invalid_list$nodes[[1]]$nodes <- list(list(name = "Illegal Child")) # Add children to a leaf
  expect_error(validate_tree_list(invalid_list), "cannot also have children")
})

test_that("validate_tree_list catches when 'nodes' is not a list", {
  invalid_list <- valid_list
  invalid_list$nodes[[2]]$nodes <- "this should be a list" # Corrupt a nodes entry
  expect_error(validate_tree_list(invalid_list), "'nodes' attribute must contain a list")
})
