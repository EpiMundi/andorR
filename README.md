
<!-- README.md is generated from README.Rmd. Please edit that file -->

# andorR

<!-- badges: start -->

[![R-CMD-check](https://github.com/EpiMundi/andorR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EpiMundi/andorR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

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

First, load the package and an example tree, and view the tree
structure.

``` r
library(andorR)
library(knitr)

# Load the example 'ethical' dataset
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

Get a list of the questions:

``` r
questions_df <- print_questions(tree)

display_df <- questions_df[, c("name", "question")]
colnames(display_df) <- c("ID", "Question")

kable(
  display_df,
  caption = "Ethical investment decision tree questions", 
  align = 'l',
  escape = TRUE,
  booktabs = TRUE
) 
```

| ID | Question |
|:---|:---|
| FIN1 | Company demonstrates consistent, high revenue growth. |
| FIN2 | Company maintains a high net profit margin for its industry. |
| FIN3 | Company holds a dominant or rapidly growing market share. |
| FIN4 | Debt-to-Equity ratio is below the industry average. |
| FIN5 | Company generates strong and positive free cash flow. |
| ENV1 | Carbon emissions (Scopes 1 & 2) are verifiably below the industry average. |
| ENV2 | Waste and water usage are minimal and well-managed. |
| ENV3 | Supply chain has strong, audited environmental standards. |
| ENV4 | Company commits a high percentage of R&D to validated green technology. |
| ENV5 | Has ambitious, science-based emission reduction targets (e.g., SBTi certified). |
| ENV6 | Executive compensation is directly and significantly linked to achieving environmental targets. |
| SOC1 | Pays a verified living wage to all global employees. |
| SOC2 | Employee turnover rate is exceptionally low for the industry. |
| SOC3 | Has strong, independently verified diversity & inclusion metrics. |
| SOC4 | Supply chain is robustly and transparently audited for labor rights (no forced/child labor). |
| SOC5 | Products and services provide a clear, net positive social good. |
| SOC6 | Company has a clean record on product safety and consumer protection. |
| SOC7 | No major, unresolved human rights controversies in its operations or supply chain. |
| GOV1 | The board of directors is majority independent and diverse. |
| GOV2 | Executive pay ratio is reasonable and linked to long-term, sustainable value. |
| GOV3 | Political lobbying and donations are transparent and align with stated company values. |
| GOV4 | Has strong shareholder protection rights (e.g., no dual-class shares). |
| GOV5 | Tax practices are transparent and fair (no excessive use of tax havens). |

Ethical investment decision tree questions

Answer some questions

``` r

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
reach a conclusion. In this case we are sorting by “TRUE”, a ‘rule-in’
approach which ranks influence assuming we respond TRUE. The other
options are “FALSE” (‘rule-out’) and “BOTH” (unopinionated).

``` r
# Get the top 10 most influential unanswered questions
highest_influence_questions <- get_highest_influence(tree, sort_by = "TRUE", top_n = 10)

display_df <- highest_influence_questions[, c("name", "influence_if_true", "influence_if_false", "question")]
colnames(display_df) <- c("ID", "Inf True", "Inf False", "Question")

kable(
  display_df,
  caption = "Priority questions based on 'rule-in' strategy", 
  align = 'l',
  escape = TRUE,
  booktabs = TRUE
) 
```

| ID | Inf True | Inf False | Question |
|:---|:---|:---|:---|
| ENV4 | 0.2500000 | 0.3333333 | Company commits a high percentage of R&D to validated green technology. |
| ENV5 | 0.2500000 | 0.3333333 | Has ambitious, science-based emission reduction targets (e.g., SBTi certified). |
| ENV6 | 0.2500000 | 0.3333333 | Executive compensation is directly and significantly linked to achieving environmental targets. |
| SOC1 | 0.2500000 | 0.1250000 | Pays a verified living wage to all global employees. |
| SOC2 | 0.2500000 | 0.1250000 | Employee turnover rate is exceptionally low for the industry. |
| SOC3 | 0.2500000 | 0.1250000 | Has strong, independently verified diversity & inclusion metrics. |
| SOC4 | 0.2500000 | 0.1250000 | Supply chain is robustly and transparently audited for labor rights (no forced/child labor). |
| FIN4 | 0.1250000 | 1.0000000 | Debt-to-Equity ratio is below the industry average. |
| FIN5 | 0.1250000 | 1.0000000 | Company generates strong and positive free cash flow. |
| SOC5 | 0.0833333 | 0.5000000 | Products and services provide a clear, net positive social good. |

Priority questions based on ‘rule-in’ strategy

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
  page](https://github.com/EpiMundi/andorR/issues). Please provide a
  minimal reproducible example if reporting a bug.
- **Seeking Support:** For questions about using `andorR` or for general
  support, you can also open an issue on the [GitHub Issues
  page](https://github.com/EpiMundi/andorR/issues).
