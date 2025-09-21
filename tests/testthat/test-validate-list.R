# A minimal, valid list for testing
valid_list <- list(
  name = "Root",
  rule = "OR",
  nodes = list(
    list(name = "L1", question = "Is it true?"),
    list(name = "Node A", rule = "AND", nodes = list(
      list(name = "L2", question = "Is this other thing true?")
    ))
  )
)

test_that("validate_tree_list passes with valid data", {
  expect_true(validate_tree_list(valid_list))
})

test_that("validate_tree_list catches missing names", {
  invalid_list <- valid_list
  invalid_list$nodes[[1]]$name <- NULL # Remove name from a child

  # CORRECTED: Matches the error message "is missing a valid 'name'".
  expect_error(validate_tree_list(invalid_list), "missing a valid 'name'")
})

test_that("validate_tree_list catches leaves with children", {
  invalid_list <- valid_list
  invalid_list$nodes[[1]]$nodes <- list(list(name = "Illegal Child", question = "q")) # Add children to a leaf

  # CORRECTED: Matches the error message "A leaf node (no rule) cannot have children".
  expect_error(validate_tree_list(invalid_list), "A leaf node \\(no rule\\) cannot have children")
})

test_that("validate_tree_list catches leaves without questions", {
  invalid_list <- valid_list
  invalid_list$nodes[[1]]$question <- NULL

  # This test ensures the leaf-question validation works
  expect_error(validate_tree_list(invalid_list), "A leaf node \\(no rule\\) must have a 'question'")
})

test_that("validate_tree_list catches parents without children", {
  invalid_list <- valid_list
  invalid_list$nodes[[2]]$nodes <- NULL

  # This test ensures the parent-nodes validation works
  expect_error(validate_tree_list(invalid_list), "A parent node \\(with a rule\\) must have children")
})

test_that("validate_tree_list catches when 'nodes' is not a list", {
  invalid_list <- valid_list
  invalid_list$nodes[[2]]$nodes <- "this should be a list" # Corrupt a nodes entry

  # CORRECTED: Matches the error message "must have children in a 'nodes' list".
  expect_error(validate_tree_list(invalid_list), "must have children in a 'nodes' list")
})
