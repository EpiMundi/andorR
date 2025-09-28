
<!-- README.md is generated from README.Rmd. Please edit that file -->

# andorR

> Optimisation of the Analysis of AND-OR Decision Trees

<!-- badges: start -->

[![R-CMD-check](https://github.com/EpiMundi/andorR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EpiMundi/andorR/actions/workflows/R-CMD-check.yaml)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

`andorR` (pronounced ‘Andorra’) is an R package for the analysis and
optimisation of expert system AND-OR decision trees. It helps manage the
process of gathering evidence and reaching conclusions under
uncertainty, aiming to minimize resource use and maximise confidence.

## About

AND-OR decision trees (also known as logic trees or Boolean decision
trees) provide a structured way to implement expert systems in domains
where repeatable, transparent, and standardised decision processes are
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
questions_df <- get_questions(tree)

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

Answer more questions to complete the tree

``` r
tree <- set_answer(tree, "ENV5", TRUE, 3, verbose=FALSE)
tree <- set_answer(tree, "SOC3", TRUE, 3, verbose=FALSE)
tree <- set_answer(tree, "FIN4", TRUE, 2, verbose=FALSE)
tree <- set_answer(tree, "FIN5", TRUE, 1, verbose=FALSE)
tree <- set_answer(tree, "GOV1", TRUE, 0, verbose=FALSE)
tree <- set_answer(tree, "GOV2", TRUE, 0, verbose=FALSE)
tree <- set_answer(tree, "GOV3", TRUE, 0, verbose=FALSE)
tree <- set_answer(tree, "GOV4", TRUE, 0, verbose=FALSE)
tree <- set_answer(tree, "GOV5", TRUE, 0, verbose=FALSE)

tree <- update_tree(tree)
print_tree(tree)
#> Tree                                             Rule      Answer      Confidence   
#> Invest in Company X                               AND       TRUE        0.8% 
#> |-- Financial Viability                           AND       TRUE        37.8% 
#> |   |-- Profitability and Growth Signals          OR        TRUE        90% 
#> |   |   |-- FIN1                                            TRUE        4 
#> |   |   |-- FIN2                                                         
#> |   |   `-- FIN3                                                         
#> |   `-- Solvency and Stability                    AND       TRUE        42% 
#> |       |-- FIN4                                            TRUE        2 
#> |       `-- FIN5                                            TRUE        1 
#> |-- Acceptable Environmental Stewardship          OR        TRUE        80% 
#> |   |-- Has a Clean Current Record                AND       FALSE       80% 
#> |   |   |-- ENV1                                                         
#> |   |   |-- ENV2                                            FALSE       3 
#> |   |   `-- ENV3                                                         
#> |   `-- Has a Credible Transition Pathway         OR        TRUE        80% 
#> |       |-- ENV4                                                         
#> |       |-- ENV5                                            TRUE        3 
#> |       `-- ENV6                                                         
#> |-- Demonstrable Social Responsibility            OR        TRUE        80% 
#> |   |-- Shows Excellent Internal Culture          OR        TRUE        80% 
#> |   |   |-- SOC1                                                         
#> |   |   |-- SOC2                                                         
#> |   |   |-- SOC3                                            TRUE        3 
#> |   |   `-- SOC4                                                         
#> |   `-- Has a Positive External Impact            AND                    
#> |       |-- SOC5                                                         
#> |       |-- SOC6                                                         
#> |       `-- SOC7                                                         
#> `-- Strong Corporate Governance                   AND       TRUE        3.1% 
#>     |-- GOV1                                                TRUE        0 
#>     |-- GOV2                                                TRUE        0 
#>     |-- GOV3                                                TRUE        0 
#>     |-- GOV4                                                TRUE        0 
#>     `-- GOV5                                                TRUE        0
```

The conclusion for the investment decision is TRUE, but the confidence
is very low.

Identify the most efficient questions to focus on to increase
confidence.

``` r
display_df <- get_confidence_boosters(tree)[, c("name", "action", "details", "potential_gain")]
#> ℹ Analysing 12 unanswered questions...✔ Analysed 12 unanswered questions ✔  
#> ℹ Analysing 11 existing answers...✔ Analysed 11 existing answers ✔  
colnames(display_df) <- c("ID", "Action", "Details", "Potential gain")

kable(
  display_df,
  caption = "Priority questions to increase confidence", 
  align = 'l',
  escape = TRUE,
  booktabs = TRUE
) 
```

|      | ID   | Action              | Details           | Potential gain |
|:-----|:-----|:--------------------|:------------------|:---------------|
| GOV1 | GOV1 | Increase Confidence | Current conf: 0/5 | +0.76%         |
| GOV2 | GOV2 | Increase Confidence | Current conf: 0/5 | +0.76%         |
| GOV3 | GOV3 | Increase Confidence | Current conf: 0/5 | +0.76%         |
| GOV4 | GOV4 | Increase Confidence | Current conf: 0/5 | +0.76%         |
| GOV5 | GOV5 | Increase Confidence | Current conf: 0/5 | +0.76%         |

Priority questions to increase confidence

All elements of Strong Corporate Governance are important in the tree,
so more research into the company is required in this area. Let’s update
the results after having done a thorough assessment.

``` r
tree <- set_answer(tree, "GOV1", TRUE, 5, verbose=FALSE)
tree <- set_answer(tree, "GOV2", TRUE, 5, verbose=FALSE)
tree <- set_answer(tree, "GOV3", TRUE, 5, verbose=FALSE)
tree <- set_answer(tree, "GOV4", TRUE, 5, verbose=FALSE)
tree <- set_answer(tree, "GOV5", TRUE, 5, verbose=FALSE)

tree <- update_tree(tree)
print_tree(tree)
#> Tree                                             Rule      Answer      Confidence   
#> Invest in Company X                               AND       TRUE        24.2% 
#> |-- Financial Viability                           AND       TRUE        37.8% 
#> |   |-- Profitability and Growth Signals          OR        TRUE        90% 
#> |   |   |-- FIN1                                            TRUE        4 
#> |   |   |-- FIN2                                                         
#> |   |   `-- FIN3                                                         
#> |   `-- Solvency and Stability                    AND       TRUE        42% 
#> |       |-- FIN4                                            TRUE        2 
#> |       `-- FIN5                                            TRUE        1 
#> |-- Acceptable Environmental Stewardship          OR        TRUE        80% 
#> |   |-- Has a Clean Current Record                AND       FALSE       80% 
#> |   |   |-- ENV1                                                         
#> |   |   |-- ENV2                                            FALSE       3 
#> |   |   `-- ENV3                                                         
#> |   `-- Has a Credible Transition Pathway         OR        TRUE        80% 
#> |       |-- ENV4                                                         
#> |       |-- ENV5                                            TRUE        3 
#> |       `-- ENV6                                                         
#> |-- Demonstrable Social Responsibility            OR        TRUE        80% 
#> |   |-- Shows Excellent Internal Culture          OR        TRUE        80% 
#> |   |   |-- SOC1                                                         
#> |   |   |-- SOC2                                                         
#> |   |   |-- SOC3                                            TRUE        3 
#> |   |   `-- SOC4                                                         
#> |   `-- Has a Positive External Impact            AND                    
#> |       |-- SOC5                                                         
#> |       |-- SOC6                                                         
#> |       `-- SOC7                                                         
#> `-- Strong Corporate Governance                   AND       TRUE        100% 
#>     |-- GOV1                                                TRUE        5 
#>     |-- GOV2                                                TRUE        5 
#>     |-- GOV3                                                TRUE        5 
#>     |-- GOV4                                                TRUE        5 
#>     `-- GOV5                                                TRUE        5
```

Individually the impact was small but cumulatively the five questions
gave a major boost in confidence. Let’s see what we should look at next.

``` r
display_df <- get_confidence_boosters(tree)[, c("name", "action", "details", "potential_gain")]
#> ℹ Analysing 12 unanswered questions...✔ Analysed 12 unanswered questions ✔  
#> ℹ Analysing 6 existing answers...✔ Analysed 6 existing answers ✔  
colnames(display_df) <- c("ID", "Action", "Details", "Potential gain")

kable(
  display_df,
  caption = "Priority questions to increase confidence", 
  align = 'l',
  escape = TRUE,
  booktabs = TRUE
) 
```

|      | ID   | Action              | Details                | Potential gain |
|:-----|:-----|:--------------------|:-----------------------|:---------------|
| FIN5 | FIN5 | Increase Confidence | Current conf: 1/5      | +16.13%        |
| FIN4 | FIN4 | Increase Confidence | Current conf: 2/5      | +10.37%        |
| ENV4 | ENV4 | Answer New Question | Suggest answering TRUE | +6.05%         |
| ENV6 | ENV6 | Answer New Question | Suggest answering TRUE | +6.05%         |
| SOC1 | SOC1 | Answer New Question | Suggest answering TRUE | +6.05%         |

Priority questions to increase confidence

Let’s do more research on Solvency and Stability, as suggested.

``` r
tree <- set_answer(tree, "FIN4", TRUE, 5, verbose=FALSE)
tree <- set_answer(tree, "FIN5", TRUE, 5, verbose=FALSE)

tree <- update_tree(tree)
print_tree(tree)
#> Tree                                             Rule      Answer      Confidence   
#> Invest in Company X                               AND       TRUE        57.6% 
#> |-- Financial Viability                           AND       TRUE        90% 
#> |   |-- Profitability and Growth Signals          OR        TRUE        90% 
#> |   |   |-- FIN1                                            TRUE        4 
#> |   |   |-- FIN2                                                         
#> |   |   `-- FIN3                                                         
#> |   `-- Solvency and Stability                    AND       TRUE        100% 
#> |       |-- FIN4                                            TRUE        5 
#> |       `-- FIN5                                            TRUE        5 
#> |-- Acceptable Environmental Stewardship          OR        TRUE        80% 
#> |   |-- Has a Clean Current Record                AND       FALSE       80% 
#> |   |   |-- ENV1                                                         
#> |   |   |-- ENV2                                            FALSE       3 
#> |   |   `-- ENV3                                                         
#> |   `-- Has a Credible Transition Pathway         OR        TRUE        80% 
#> |       |-- ENV4                                                         
#> |       |-- ENV5                                            TRUE        3 
#> |       `-- ENV6                                                         
#> |-- Demonstrable Social Responsibility            OR        TRUE        80% 
#> |   |-- Shows Excellent Internal Culture          OR        TRUE        80% 
#> |   |   |-- SOC1                                                         
#> |   |   |-- SOC2                                                         
#> |   |   |-- SOC3                                            TRUE        3 
#> |   |   `-- SOC4                                                         
#> |   `-- Has a Positive External Impact            AND                    
#> |       |-- SOC5                                                         
#> |       |-- SOC6                                                         
#> |       `-- SOC7                                                         
#> `-- Strong Corporate Governance                   AND       TRUE        100% 
#>     |-- GOV1                                                TRUE        5 
#>     |-- GOV2                                                TRUE        5 
#>     |-- GOV3                                                TRUE        5 
#>     |-- GOV4                                                TRUE        5 
#>     `-- GOV5                                                TRUE        5
```

This approach to strategic targeted research helps apply resources to
the areas where they will have the most impact on the overall
conclusion. The process can be repeated until the target level of
confidence is reached.

### Interactive tool

This manual iterative approach can get a little tedious. The
`andorR_interactive()` function chains these actions together in a CLI
interactive loop to automate the process.

    ── andorR ──────────────────────────────────────────────────────────────────────────────
    An analysis and optimisation tool for AND-OR decision trees.

    Created by: EpiMundi (<https://epimundi.com>)
    Author: Angus Cameron
    Email: angus@epimundi.com
    Version: 0.2.4

    ── Help Menu ───────────────────────────────────────────────────────────────────────────
    h: Show this help message.
    q: Quit the interactive session.
    p: Print the current state of the tree.
    s: Save the current tree state to an .rds file.
    n: Specify a node to edit by typing its name.
    1, 2, ...: Select a numbered question from the list to answer.
    ────────────────────────────────────────────────────────────────────────────────────────
    ────────────────────────────────────────────────────────────────────────────────────────

    ── Conclusion Reached! ──

    The current result is: TRUE at a confidence of 57.6%
    You can now answer more questions or revise existing answers to boost confidence.
    ────────────────────────────────────────────────────────────────────────────────────────
    ✔ Analysed 12 unanswered questions ✔  
    ✔ Analysed 4 existing answers ✔  

    ── Questions to Boost Confidence ──

    1. [ENV4] Answer New Question Suggest answering TRUE +14.4%
    2. [ENV6] Answer New Question Suggest answering TRUE +14.4%
    3. [SOC1] Answer New Question Suggest answering TRUE +14.4%
    4. [SOC2] Answer New Question Suggest answering TRUE +14.4%
    5. [SOC4] Answer New Question Suggest answering TRUE +14.4%
    6. [ENV5] Increase Confidence Current conf: 3/5 +14.4%
    7. [SOC3] Increase Confidence Current conf: 3/5 +14.4%
    8. [FIN2] Answer New Question Suggest answering TRUE +6.4%
    9. [FIN3] Answer New Question Suggest answering TRUE +6.4%
    10. [FIN1] Increase Confidence Current conf: 4/5 +6.4%
    ────────────────────────────────────────────────────────────────────────────────────────
    Enter a number, 'n', or command (h, p, s, q): 

## API Documentation

Detailed documentation for all functions and their arguments can be
found in the package’s reference manual. You can access it in R using
`?function_name` (e.g., `?update_tree`) or by visiting the `andorR`
pkgdown website: <https://epimundi.github.io/andorR/>
