# In tests/testthat/test-calculate_tree.R

# Test that an AND node with all TRUE children becomes TRUE
test_that("AND node resolves to TRUE when all children are TRUE", {

  # 1. Arrange: Create a minimal test tree
  tree <- Node$new("Root", rule = "AND")
  tree$AddChild("L1", answer = TRUE, confidence = 0.8)
  tree$AddChild("L2", answer = TRUE, confidence = 0.9)

  # 2. Act: Run the function we are testing
  calculate_tree(tree)

  # 3. Assert: Check if the results are what we expect
  expect_true(tree$answer)
  expect_equal(tree$confidence, 0.72) # 0.8 * 0.9 = 0.72
})


# Test that an AND node with one FALSE child becomes FALSE
test_that("AND node resolves to FALSE if any child is FALSE", {

  # 1. Arrange
  tree <- Node$new("Root", rule = "AND")
  tree$AddChild("L1", answer = TRUE, confidence = 0.8)
  tree$AddChild("L2", answer = FALSE, confidence = 0.9)

  # 2. Act
  calculate_tree(tree)

  # 3. Assert
  expect_false(tree$answer)
  expect_equal(tree$confidence, 0.9) # Confidence is based on the deciding FALSE node
})
