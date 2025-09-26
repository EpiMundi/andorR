# --- Test for calculate_influence() ---

test_that("calculate_influence correctly sums the products of ancestor indices", {
  # Arrange
  tree <- data.tree::Node$new("Root", answer = NA, confidence = NA)
  tree$true_index <- 1.0
  tree$false_index <- 0.5
  node_a <- tree$AddChild("NodeA", answer = NA, confidence = NA)
  node_a$true_index <- 0.5
  node_a$false_index <- 1.0
  leaf1 <- node_a$AddChild("Leaf1", answer = NA, confidence = NA)
  expected_influence <- 1.0

  # Act
  calculate_influence(leaf1)

  # Assert
  expect_equal(leaf1$influence_index, expected_influence)
})

test_that("calculate_influence sets index to NA for an already-answered leaf", {
  # Arrange
  tree <- data.tree::Node$new("Root")
  leaf1 <- tree$AddChild("Leaf1", answer = TRUE, confidence = 0.9, influence_index = 1.5)

  # Act
  calculate_influence(leaf1)

  # Assert
  expect_true(is.na(leaf1$influence_index))
})

test_that("calculate_influence sets index to NA for an already-answered leaf", {
  # Arrange: Create a leaf that has an answer
  tree <- data.tree::Node$new("Root")
  leaf1 <- tree$AddChild("Leaf1", answer = TRUE, confidence = 0.9, influence_index = 1.5)

  # Act: Run the function on the answered leaf
  calculate_influence(leaf1)

  # Assert: The influence index should now be NA
  expect_true(is.na(leaf1$influence_index))
})
