# A minimal, valid data frame where the root id is 1, not 0
valid_df <- tibble::tribble(
  ~id, ~name,    ~question,                 ~rule, ~parent,
  1L, "Root",   NA_character_,             "OR",     NA_integer_,
  2L, "L1",     "Is the first condition met?", NA,        1L,
  3L, "Node A", NA_character_,             "AND",      1L,
  4L, "L2",     "Is the second condition met?", NA,       3L
)

test_that("validate_tree_df passes with valid data (non-zero root)", {
  expect_true(validate_tree_df(valid_df))
})

test_that("validate_tree_df catches missing columns", {
  invalid_df <- valid_df
  invalid_df$parent <- NULL # Remove the parent column
  expect_error(validate_tree_df(invalid_df))
})

test_that("validate_tree_df catches bad data types", {
  invalid_df_num <- valid_df
  invalid_df_num$id <- as.character(invalid_df_num$id)
  expect_error(validate_tree_df(invalid_df_num), "must be numeric")

  invalid_df_char <- valid_df
  invalid_df_char$name <- as.factor(invalid_df_char$name)
  expect_error(validate_tree_df(invalid_df_char), "must be character")
})

test_that("validate_tree_df catches invalid rule values", {
  invalid_df <- valid_df
  invalid_df$rule[1] <- "XOR" # Not a valid rule
  expect_error(validate_tree_df(invalid_df), "contains invalid values")
})

test_that("validate_tree_df catches duplicate IDs", {
  invalid_df <- valid_df
  invalid_df$id[2] <- 1L
  expect_error(validate_tree_df(invalid_df))
})

test_that("validate_tree_df catches missing names", {
  invalid_df <- valid_df
  invalid_df$name[2] <- NA_character_
  expect_error(validate_tree_df(invalid_df))
})

test_that("validate_tree_df catches incorrect number of roots", {
  invalid_df <- valid_df
  invalid_df$parent[2] <- NA_integer_ # Creates a second root
  expect_error(validate_tree_df(invalid_df))
})

test_that("validate_tree_df catches when root ID is not the minimum ID", {
  # This is invalid because the root has id=10, but another node has id=2.
  invalid_df <- tibble::tribble(
    ~id, ~name,    ~question,    ~rule, ~parent,
    10L, "Root",   NA,           "OR",     NA,
    2L, "L1",     "Is it true?", NA,     10L
  )
  expect_error(validate_tree_df(invalid_df), "must have the smallest 'id'")
})

test_that("validate_tree_df catches orphaned children", {
  invalid_df <- valid_df
  invalid_df$parent[2] <- 99L # This parent ID does not exist
  expect_error(validate_tree_df(invalid_df), "'parent' IDs do not correspond")
})

test_that("validate_tree_df catches when parents have questions", {
  invalid_df <- valid_df
  invalid_df$question[3] <- "This parent should not have a question."
  expect_error(validate_tree_df(invalid_df))
})

test_that("validate_tree_df catches when leaves are missing questions", {
  invalid_df <- valid_df
  invalid_df$question[2] <- NA_character_
  expect_error(validate_tree_df(invalid_df))
})
