# andorR 0.3.0

* **MAJOR CHANGES**
    * Changed the name of `print_questions()` to `get_questions()` to better reflect its function

* **MINOR CHANGES**
    * Added CONTRIBUTING.md
    * Added CODE_OF_CONDUCT.md
    
# andorR 0.2.5

* **Bug fixes**
    * Correct error in display of root node in `print_tree()`
    
* **MINOR CHANGES**
    * Improve display of output from `andorR_interactive()`


# andorR 0.2.4

* **Bug fixes**
    * Remove incorrect recalculation of influence indices from print_questions()
    
* **MINOR CHANGES**
    * Cleaned code to remove colour from lines in print_tree()

# andorR 0.2.3

* **Bug fixes**
    * Leaves with resolved ancestors were not having indices set to NA
    * get_highest_impact() list was filtering for NA indices

# andorR 0.2.2

* **MINOR CHANGES**
    * Added tests for set_answer()

# andorR 0.2.1

* **MINOR CHANGES**
    * Added tests for file loading (.yml, .json, .csv)

# andorR 0.2.0

* **NEW FEATURES**
    * Added `load_tree_json()`  to support loading trees from a json file 
    (hierarchical format)

* **MINOR CHANGES**
    * Update vignettes
    * Added `woah.yml` example data file

# andorR 0.1.0

* First pre-release version of the package.
* Includes core functions for loading, calculating, and optimising the analysis
  of AND-OR decision trees.
* Includes `ethical` example dataset and various example data files
