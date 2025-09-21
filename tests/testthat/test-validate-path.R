# A minimal, valid data frame in path-string format
valid_path_df <- tibble::tribble(
  ~path,                 ~question,              ~rule,
  "Root",                NA_character_,          "OR",
  "Root/L1",             "Is condition 1 met?",  NA,
  "Root/NodeA",          NA_character_,          "AND",
  "Root/NodeA/L2",       "Is condition 2 met?",  NA
)

test_that("validate_tree_df_path passes with valid data", {
  expect_true(validate_tree_df_path(valid_path_df))
})

test_that("validate_tree_df_path catches missing columns", {
  invalid_df <- valid_path_df
  invalid_df$path <- NULL
  expect_error(validate_tree_df_path(invalid_df))
})

test_that("validate_tree_df_path catches inconsistent roots", {
  invalid_df <- valid_path_df
  invalid_df$path[2] <- "AnotherRoot/L1"
  expect_error(validate_tree_df_path(invalid_df))
})

test_that("validate_tree_df_path catches multiple roots", {
  # CORRECTED: Use add_row() to correctly add a new row
  # All other columns for this new row will be NA by default, which is fine.
  invalid_df <- tibble::add_row(valid_path_df, path = "SecondRoot")

  # Now the data frame is correctly formed with 5 rows, and the validation should fail.
  expect_error(validate_tree_df_path(invalid_df))
})

test_that("validate_tree_df_path catches invalid rule values", {
  invalid_df <- valid_path_df
  invalid_df$rule[1] <- "MAYBE"
  expect_error(validate_tree_df_path(invalid_df))
})

test_that("validate_tree_df_path catches when parents have questions", {
  invalid_df <- valid_path_df
  invalid_df$question[3] <- "This parent should not have a question"
  expect_error(validate_tree_df_path(invalid_df))
})

test_that("validate_tree_df_path catches when leaves are missing questions", {
  invalid_df <- valid_path_df
  invalid_df$question[2] <- NA_character_
  expect_error(validate_tree_df_path(invalid_df))
})
