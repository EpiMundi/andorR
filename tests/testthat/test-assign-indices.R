# --- Test for assign_indices() ---

test_that("assign_indices correctly calculates for a simple AND node", {
  # Arrange: Create an AND node with 3 unanswered children
  tree <- data.tree::Node$new("Root", rule = "AND")
  tree$AddChild("L1", answer = NA)
  tree$AddChild("L2", answer = NA)
  tree$AddChild("L3", answer = NA)

  # Act: Run the function on the tree
  tree$Do(assign_indices)

  # Assert: Check the calculated indices on the root node
  expect_equal(tree$true_index, 1 / 3)
  expect_equal(tree$false_index, 1.0)
})

test_that("assign_indices correctly calculates for a simple OR node", {
  # Arrange: Create an OR node with 2 unanswered children
  tree <- data.tree::Node$new("Root", rule = "OR")
  tree$AddChild("L1", answer = NA)
  tree$AddChild("L2", answer = NA)

  # Act
  tree$Do(assign_indices)

  # Assert
  expect_equal(tree$true_index, 1.0)
  expect_equal(tree$false_index, 1 / 2)
})

test_that("assign_indices is dynamic and counts only unanswered children", {
  # Arrange: An AND node with 3 children, but one is already answered
  tree <- data.tree::Node$new("Root", rule = "AND")
  tree$AddChild("L1", answer = NA)
  tree$AddChild("L2", answer = NA)
  tree$AddChild("L3", answer = TRUE)

  # The unanswered_count should be 2, not 3.

  # Act
  tree$Do(assign_indices)

  # Assert
  expect_equal(tree$true_index, 1 / 2)
  expect_equal(tree$false_index, 1.0)
})

test_that("assign_indices handles cases where all children are answered", {
  # Arrange: An OR node where all children are answered
  tree <- data.tree::Node$new("Root", rule = "OR")
  tree$AddChild("L1", answer = TRUE)
  tree$AddChild("L2", answer = FALSE)

  # Act
  tree$Do(assign_indices)

  # Assert
  expect_equal(tree$true_index, 1.0)
  expect_equal(tree$false_index, 1 / 1) # Should be 1
})

test_that("assign_indices does not modify leaf nodes", {
  # Arrange: Create a tree with a leaf
  tree <- data.tree::Node$new("Root", rule = "OR")
  leaf_node <- tree$AddChild("L1", answer = NA)

  # Act
  tree$Do(assign_indices)

  # Assert: Check that the leaf has NOT been given these attributes
  expect_null(leaf_node$true_index)
  expect_null(leaf_node$false_index)
})
