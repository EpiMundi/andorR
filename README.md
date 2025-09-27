
<!-- README.md is generated from README.Rmd. Please edit that file -->

# andorR

<!-- badges: start -->

<!-- badges: end -->

[![R-CMD-check](https://github.com/EpiMundi/andorR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EpiMundi/andorR/actions/workflows/R-CMD-check.yaml)
`andorR` (pronounced ‘Andorra’) is an R package for the analysis and
optimization of expert system AND-OR decision trees. It helps manage the
process of gathering evidence and reaching conclusions under
uncertainty, aiming to minimize resource use and maximize confidence.

## About

AND-OR decision trees (also known as logic trees or Boolean decision
trees) provide a structured way to implement expert systems in domains
where repeatable, transparent, and standardized decision processes are
critical, and where multiple pathways may lead to the same conclusion.
Such trees are particularly valuable when decisions are based on a set
of binary (TRUE/FALSE) criteria that can be combined using AND and OR
logic.

Examples include **clinical diagnosis of complex or ambiguous diseases**
(e.g., *Ottawa Ankle Rules*, *Centor criteria*, *Alvarado score*),
**transparent policy decisions** (e.g., criteria for listing notifiable
animal diseases by WOAH or selecting World Heritage sites by UNESCO),
and **finance and investment management** (e.g., stage-gate systems and
exclusionary screening).

In each case, determining an accurate answer to each criterion (a leaf
in the tree) can require considerable resources (expensive tests,
detailed research, extensive data collection). `andorR` addresses a
critical gap for R users by:

1.  **Optimizing the path to a conclusion:** It calculates the
    “influence index” for each unanswered question, guiding the user to
    the most efficient sequence to reach a decision.
2.  **Managing uncertainty:** It propagates semi-quantitative confidence
    scores through the tree’s logic, allowing for an overall confidence
    in the conclusion.
3.  **Guiding evidence generation:** For a partially resolved tree, it
    identifies which low-confidence answers are most critical to
    strengthen through further investigation to boost confidence in the
    final result.

While the R ecosystem has excellent packages for
machine-learning-derived decision trees (e.g., `rpart`), `andorR`
specifically caters to the interactive, evidence-gathering workflow of
expert-defined logic trees, making complex decision processes
transparent, reproducible, and resource-efficient.

## Installation

You can install `andorR` directly from GitHub:

``` r
# install.packages("remotes") # If you don't have remotes installed
remotes::install_github("epimundi/andorR")
```

## Example Usage

Let’s illustrate `andorR`’s core functionality by loading a predefined
ethical investment decision tree, making some initial decisions, and
then identifying the most influential remaining questions.

First, load the package and an example tree (assuming `load_tree_df` and
`ethical` data exist in your package).

``` r
library(andorR)

# Load the example 'ethical' dataset (assuming it's exported in your package)
data(ethical)
tree <- load_tree_df(ethical)

# Initially, the tree is unresolved
print_tree(tree)
#> Tree                                             Rule      Answer      Confidence   
#> Invest in Company X                               AND                    
#> |-- Financial Viability                           AND                    
#> |   |-- Profitability and Growth Signals          OR                     
#> |   |   |-- FIN1                                                         
#> |   |   |-- FIN2                                                         
#> |   |   `-- FIN3                                                         
#> |   `-- Solvency and Stability                    AND                    
#> |       |-- FIN4                                                         
#> |       `-- FIN5                                                         
#> |-- Acceptable Environmental Stewardship          OR                     
#> |   |-- Has a Clean Current Record                AND                    
#> |   |   |-- ENV1                                                         
#> |   |   |-- ENV2                                                         
#> |   |   `-- ENV3                                                         
#> |   `-- Has a Credible Transition Pathway         OR                     
#> |       |-- ENV4                                                         
#> |       |-- ENV5                                                         
#> |       `-- ENV6                                                         
#> |-- Demonstrable Social Responsibility            OR                     
#> |   |-- Shows Excellent Internal Culture          OR                     
#> |   |   |-- SOC1                                                         
#> |   |   |-- SOC2                                                         
#> |   |   |-- SOC3                                                         
#> |   |   `-- SOC4                                                         
#> |   `-- Has a Positive External Impact            AND                    
#> |       |-- SOC5                                                         
#> |       |-- SOC6                                                         
#> |       `-- SOC7                                                         
#> `-- Strong Corporate Governance                   AND                    
#>     |-- GOV1                                                             
#>     |-- GOV2                                                             
#>     |-- GOV3                                                             
#>     |-- GOV4                                                             
#>     `-- GOV5
```

If you run the above code, you’d see the tree with no answers. Let’s
make some decisions and update the tree. First, get a list of the
questions:

``` r
print_questions(tree)
#>    name
#> 1  FIN1
#> 2  FIN2
#> 3  FIN3
#> 4  FIN4
#> 5  FIN5
#> 6  ENV1
#> 7  ENV2
#> 8  ENV3
#> 9  ENV4
#> 10 ENV5
#> 11 ENV6
#> 12 SOC1
#> 13 SOC2
#> 14 SOC3
#> 15 SOC4
#> 16 SOC5
#> 17 SOC6
#> 18 SOC7
#> 19 GOV1
#> 20 GOV2
#> 21 GOV3
#> 22 GOV4
#> 23 GOV5
#>                                                                                           question
#> 1                                            Company demonstrates consistent, high revenue growth.
#> 2                                     Company maintains a high net profit margin for its industry.
#> 3                                        Company holds a dominant or rapidly growing market share.
#> 4                                              Debt-to-Equity ratio is below the industry average.
#> 5                                            Company generates strong and positive free cash flow.
#> 6                       Carbon emissions (Scopes 1 & 2) are verifiably below the industry average.
#> 7                                              Waste and water usage are minimal and well-managed.
#> 8                                        Supply chain has strong, audited environmental standards.
#> 9                          Company commits a high percentage of R&D to validated green technology.
#> 10                 Has ambitious, science-based emission reduction targets (e.g., SBTi certified).
#> 11 Executive compensation is directly and significantly linked to achieving environmental targets.
#> 12                                            Pays a verified living wage to all global employees.
#> 13                                   Employee turnover rate is exceptionally low for the industry.
#> 14                               Has strong, independently verified diversity & inclusion metrics.
#> 15    Supply chain is robustly and transparently audited for labor rights (no forced/child labor).
#> 16                                Products and services provide a clear, net positive social good.
#> 17                           Company has a clean record on product safety and consumer protection.
#> 18              No major, unresolved human rights controversies in its operations or supply chain.
#> 19                                     The board of directors is majority independent and diverse.
#> 20                   Executive pay ratio is reasonable and linked to long-term, sustainable value.
#> 21          Political lobbying and donations are transparent and align with stated company values.
#> 22                          Has strong shareholder protection rights (e.g., no dual-class shares).
#> 23                        Tax practices are transparent and fair (no excessive use of tax havens).
#>    answer confidence influence_if_true influence_if_false influence_index
#> 1      NA         NA        0.12500000          0.3333333       0.4583333
#> 2      NA         NA        0.12500000          0.3333333       0.4583333
#> 3      NA         NA        0.12500000          0.3333333       0.4583333
#> 4      NA         NA        0.06250000          1.0000000       1.0625000
#> 5      NA         NA        0.06250000          1.0000000       1.0625000
#> 6      NA         NA        0.08333333          0.5000000       0.5833333
#> 7      NA         NA        0.08333333          0.5000000       0.5833333
#> 8      NA         NA        0.08333333          0.5000000       0.5833333
#> 9      NA         NA        0.25000000          0.1666667       0.4166667
#> 10     NA         NA        0.25000000          0.1666667       0.4166667
#> 11     NA         NA        0.25000000          0.1666667       0.4166667
#> 12     NA         NA        0.25000000          0.1250000       0.3750000
#> 13     NA         NA        0.25000000          0.1250000       0.3750000
#> 14     NA         NA        0.25000000          0.1250000       0.3750000
#> 15     NA         NA        0.25000000          0.1250000       0.3750000
#> 16     NA         NA        0.08333333          0.5000000       0.5833333
#> 17     NA         NA        0.08333333          0.5000000       0.5833333
#> 18     NA         NA        0.08333333          0.5000000       0.5833333
#> 19     NA         NA        0.05000000          1.0000000       1.0500000
#> 20     NA         NA        0.05000000          1.0000000       1.0500000
#> 21     NA         NA        0.05000000          1.0000000       1.0500000
#> 22     NA         NA        0.05000000          1.0000000       1.0500000
#> 23     NA         NA        0.05000000          1.0000000       1.0500000
```

Now let’s unser some questions

``` r
# Set some answers and confidences
tree <- set_answer(tree, "FIN1", TRUE, 4) # Company shows consistent, high revenue growth (high confidence)
#> Answer for leaf 'FIN1' set to: TRUE with confidence 4/5
tree <- set_answer(tree, "ENV2", FALSE, 3) # Waste and water usage are NOT minimal (medium confidence)
#> Answer for leaf 'ENV2' set to: FALSE with confidence 3/5

# Update the tree to propagate answers and calculate influence indices
tree <- update_tree(tree)

# Print the updated tree
print_tree(tree)
#> Tree                                             Rule      Answer      Confidence   
#> Invest in Company X                               AND                    
#> |-- Financial Viability                           AND                    
#> |   |-- Profitability and Growth Signals          OR        TRUE        90% 
#> |   |   |-- FIN1                                            TRUE        4 
#> |   |   |-- FIN2                                                         
#> |   |   `-- FIN3                                                         
#> |   `-- Solvency and Stability                    AND                    
#> |       |-- FIN4                                                         
#> |       `-- FIN5                                                         
#> |-- Acceptable Environmental Stewardship          OR                     
#> |   |-- Has a Clean Current Record                AND       FALSE       80% 
#> |   |   |-- ENV1                                                         
#> |   |   |-- ENV2                                            FALSE       3 
#> |   |   `-- ENV3                                                         
#> |   `-- Has a Credible Transition Pathway         OR                     
#> |       |-- ENV4                                                         
#> |       |-- ENV5                                                         
#> |       `-- ENV6                                                         
#> |-- Demonstrable Social Responsibility            OR                     
#> |   |-- Shows Excellent Internal Culture          OR                     
#> |   |   |-- SOC1                                                         
#> |   |   |-- SOC2                                                         
#> |   |   |-- SOC3                                                         
#> |   |   `-- SOC4                                                         
#> |   `-- Has a Positive External Impact            AND                    
#> |       |-- SOC5                                                         
#> |       |-- SOC6                                                         
#> |       `-- SOC7                                                         
#> `-- Strong Corporate Governance                   AND                    
#>     |-- GOV1                                                             
#>     |-- GOV2                                                             
#>     |-- GOV3                                                             
#>     |-- GOV4                                                             
#>     `-- GOV5
```

Now that some questions are answered and the tree is updated, we can
find the most influential remaining questions to answer to efficiently
reach a conclusion:

``` r
# Get the top 3 most influential unanswered questions
highest_influence_questions <- get_highest_influence(tree, sort_by = "TRUE", top_n = 3)
print(highest_influence_questions)
#>   name
#> 1 ENV4
#> 2 ENV5
#> 3 ENV6
#>                                                                                          question
#> 1                         Company commits a high percentage of R&D to validated green technology.
#> 2                 Has ambitious, science-based emission reduction targets (e.g., SBTi certified).
#> 3 Executive compensation is directly and significantly linked to achieving environmental targets.
#>   influence_if_true influence_if_false influence_index
#> 1              0.25          0.3333333       0.5833333
#> 2              0.25          0.3333333       0.5833333
#> 3              0.25          0.3333333       0.5833333
```

This output helps users prioritize their next steps in gathering
evidence.

### Interactive tool

The `andorR_interactive()` function chains these actions together in a
CLI interactive loop to automate the process.

## API Documentation

Detailed documentation for all functions and their arguments can be
found in the package’s reference manual. You can access it in R using
`?function_name` (e.g., `?update_tree`) or by visiting the `andorR`
pkgdown website (xxx pending xxx).

## Community Guidelines

We welcome contributions, bug reports, and feature requests. Please
follow these guidelines:

- **Contributing:** If you’d like to contribute code, please open an
  issue first to discuss your proposed changes. Then, fork the
  repository, make your changes, and submit a pull request.
- **Reporting Issues:** If you encounter any bugs or have suggestions
  for improvements, please open an issue on the [GitHub Issues
  page](https://github.com/your-github-username/andorR/issues). Please
  provide a minimal reproducible example if reporting a bug.
- **Seeking Support:** For questions about using `andorR` or for general
  support, you can also open an issue on the [GitHub Issues
  page](https://github.com/your-github-username/andorR/issues).
