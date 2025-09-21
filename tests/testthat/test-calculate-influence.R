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

test_that("calculate_influence sets index to NA for a leaf under a resolved ancestor", {
  # Arrange
  tree <- data.tree::Node$new("Root", rule = "OR", answer = NA, confidence = NA)

  # THE FIX: Ensure ALL nodes are created with the attributes the functions expect.
  leaf_answered <- tree$AddChild("LeafAnswered", answer = NA, confidence = NA)
  leaf_moot <- tree$AddChild("LeafMoot", answer = NA, confidence = NA, influence_index = 1.5)

  # Provide an answer AND a confidence to the first leaf
  leaf_answered$answer <- TRUE
  leaf_answered$confidence <- 0.9

  # Act
  # Run calculate_tree to propagate this answer up to the Root
  calculate_tree(tree)

  # Now that the Root is resolved, run calculate_influence on the moot leaf
  calculate_influence(leaf_moot)

  # Assert
  # The moot leaf's influence index should now be NA
  expect_true(is.na(leaf_moot$influence_index))
})
