# Test for set_answer()

test_that("set_answer() correctly assigns values to a leaf", {
  # Arrange: Create an AND node with 3 unanswered children
  tree <- data.tree::Node$new("Root",
    rule = "AND",
    id = 0,
    parent_id = NA,
    answer= NA,
    confidence = NA
    )
  tree$AddChild("L1",
                rule = NA,
                id = 1,
                parent_id = 0,
                answer= NA,
                confidence = NA
  )
  tree$AddChild("L2",
                rule = NA,
                id = 2,
                parent_id = 0,
                answer= NA,
                confidence = NA
  )
  tree$AddChild("L3",
                rule = NA,
                id = 3,
                parent_id = 0,
                answer= NA,
                confidence = NA
  )

  # Act: Run the function
  tree <- set_answer(tree, "L2", TRUE, 3, verbose = FALSE)

  # Assert: Check the values of the affected and unaffected nodes
  expect_equal(FindNode(tree, "L2")$answer, TRUE)
  expect_equal(FindNode(tree, "L2")$confidence, 0.5 + 3 / 10)
  expect_equal(FindNode(tree, "L3")$answer, NA)
  expect_equal(FindNode(tree, "L3")$confidence, NA)
  expect_equal(FindNode(tree, "Root")$non_existent, NULL)
})
