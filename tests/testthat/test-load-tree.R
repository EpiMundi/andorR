# Tests for load_tree_* functions

########################
# JSON Hierarchical file
########################

test_that("load_tree_json() correctly loads and parses a JSON file", {

  # 1. Arrange: Get the reliable path to the test file.
  test_file <- testthat::test_path("test_tree.json")

  # 2. Act: Call the function you want to test with the reliable path.
  tree <- load_tree_json(test_file)

  # 3. Assert: Check that the result is what you expect.
  #    Check the class of the object.
  expect_s3_class(tree, "Node")

  #    Check the name of the root.
  expect_equal(tree$name, "Root")

  #    Check the total number of nodes (Root + L1 + L2).
  expect_equal(tree$totalCount, 3)
})

test_that("load_tree_json() errors if invalid JSON file", {

  # 1. Arrange: Get the reliable path to the test file.
  test_file <- testthat::test_path("test_tree_invalid.json")

  # 2. Act & Assert:
  expect_error(load_tree_json(test_file), "Failed to read or parse the JSON file")
})


test_that("load_tree_json() errors if the file does not exist", {

  # Check that your function correctly throws an error for a non-existent file.
  expect_error(load_tree_json("a_file_that_does_not_exist.json"))
})


########################
# YAML Hierarchical file
########################

test_that("load_tree_yaml() correctly loads and parses a YAML file", {
  test_file <- testthat::test_path("test_tree.yml")
  tree <- load_tree_yaml(test_file)

  expect_s3_class(tree, "Node")
  expect_equal(tree$name, "Root")
  expect_equal(tree$totalCount, 3)
})

test_that("load_tree_yaml() errors on an invalid YAML file", {
  test_file <- testthat::test_path("test_tree_invalid.yml")
  expect_error(load_tree_yaml(test_file), "Failed to read or parse the YAML file")
})

test_that("load_tree_yaml() errors if the file does not exist", {
  expect_error(load_tree_yaml("a_file_that_does_not_exist.yml"))
})

########################
# CSV file
########################

test_that("load_tree_yaml() correctly loads and parses a csv file", {
  test_file <- testthat::test_path("test_tree.csv")
  tree <- load_tree_csv(test_file)

  expect_s3_class(tree, "Node")
  expect_equal(tree$name, "Root")
  expect_equal(tree$totalCount, 3)
})

test_that("load_tree_csv() errors if the file does not exist", {
  expect_error(load_tree_yaml("a_file_that_does_not_exist.csv"))
})



