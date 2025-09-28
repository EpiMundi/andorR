# 1. Install the package if you don't have it
# install.packages("DiagrammeR")

# 2. Load the library
library(DiagrammeR)

# 3. Define the graph using the DOT language
diagram_code <- "
digraph ethical_tree {

  # Graph layout: Top-to-Bottom
  graph [layout = dot, rankdir = TB, splines = ortho]

  # Define default styles for nodes and edges
  node [shape = Mrecord, style = rounded, fontname = 'Helvetica', color = black, fillcolor = whitesmoke]
  edge [arrowhead = none, color = black]

  # Define Parent Nodes (with rules)
  n0 [label = '{Invest in Company X | AND}']
  n1 [label = '{Financial Viability | AND}']
  n1_1 [label = '{Profitability and Growth Signals | OR}']
  n1_2 [label = '{Solvency and Stability | AND}']
  n2 [label = '{Acceptable Environmental Stewardship | OR}']
  n2_1 [label = '{Has a Clean Current Record | AND}']
  n2_2 [label = '{Has a Credible Transition Pathway | OR}']
  n3 [label = '{Demonstrable Social Responsibility | OR}']
  n3_1 [label = '{Shows Excellent Internal Culture | OR}']
  n3_2 [label = '{Has a Positive External Impact | AND}']
  n4 [label = '{Strong Corporate Governance | AND}']

  # Define Leaf Nodes (no rule, simpler shape)
  node [shape = box, style = rounded]
  FIN1, FIN2, FIN3, FIN4, FIN5
  ENV1, ENV2, ENV3, ENV4, ENV5, ENV6
  SOC1, SOC2, SOC3, SOC4, SOC5, SOC6, SOC7
  GOV1, GOV2, GOV3, GOV4, GOV5

  # Define edges (the relationships that form the tree)
  n0 -> {n1, n2, n3, n4}

  n1 -> {n1_1, n1_2}
  n1_1 -> {FIN1, FIN2, FIN3}
  n1_2 -> {FIN4, FIN5}

  n2 -> {n2_1, n2_2}
  n2_1 -> {ENV1, ENV2, ENV3}
  n2_2 -> {ENV4, ENV5, ENV6}

  n3 -> {n3_1, n3_2}
  n3_1 -> {SOC1, SOC2, SOC3, SOC4}
  n3_2 -> {SOC5, SOC6, SOC7}

  n4 -> {GOV1, GOV2, GOV3, GOV4, GOV5}

}
"

# 4. Create and display the graph object
grViz(diagram_code)
