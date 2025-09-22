---
title: 'andorR: An R package for optimising the analysis of AND-OR trees'
tags:
  - R
  - decision tree
  - and or

authors:
  - given-names: Angus Robert
    surname: Cameron
    orcid: 0000-0001-8801-0366
    affiliation: 1
affiliations:
 - name: EpiMundi, France
   index: 1
date: 30 September 2025
# bibliography: paper.bib
---

# Summary

A summary describing the high-level functionality and purpose of the software 
for a diverse, non-specialist audience.

# Statement of need

A Statement of need section that clearly illustrates the research purpose of the 
and places it in the context of related work.

# Examples

## Installation

This package can be installed from GitHub (developmental version) or CRAN (stable version).

In order to install ``andorR`` use the following command:

```r
if(!require("devtools")) {
  install.packages("devtools")
}
devtools::install_github("epimundi/andorR")
```

## Loading

Load the package by typing


```r
library(andorR)
```
## Tree analysis

### Decision tree definition formats

Three formats can be used to define a decision tree: relational, hierarchical, 
and path-string. These are explained in the vignette [Data Formats for andorR](https://...data-formats.html) 
and [examples](https://...example-data-files.html) are provided.

### Loading and analysing a decision tree

A family of ``load_tree_`` functions load data from file or memory in different
formats. The ``update_tree()`` function performs optimisation calculations
based on responses provided.

### Determining the most influential questions

The ``get_highest_influence()`` function returns an ordered list of leaves that
have the greatest impact on resolving the tree. The algorithm is described in the
vignette on the [Optimisation of AND-OR Decision Trees](https://...tree-optimisation.html)

### Improving confidence in the conclusion

The ``get_confidence_boosters()`` function performs a sensitivity analysis to determine
which questions would have the greatest impact on the overall tree confidence if
more evidence was generated to improve the confidence in the individual respons.
the approach is described in the [Confidence Boosting and Sensitivity Analysis](https://...confidence-boosting.html)
vignette.

### Interactive use

The ``andorR_interactive()`` function launches a command-line interactive tool to
iteratively priotise questions, capture the response, recalculate the tree and
propose an updated list of priority questions. After the tree has been resolved
it switches to confidence boosting mode. The overall process is described in the
[Introduction to andorR](https://...andorR-intro.html) vignette.

The package also contains helper functions to read and display the current
state of decision trees during analysis.


# Acknowledgements

No financial support was received for this project. The work was inspired by 
the Canadian One Coast research project, under which EpiMundi was contracted
to develop a decision tree to standardise the process of listing notifiable
aquatic animal diseases.

# References

A list of key references, including to other software addressing related needs. 
Note that the references should include full names of venues, e.g., journals and 
conferences, not abbreviations only understood in the context of a specific discipline.

In separate paper.bib file in the following format:
@article{Pearson:2017,
  	url = {http://adsabs.harvard.edu/abs/2017arXiv170304627P},
  	Archiveprefix = {arXiv},
  	Author = {{Pearson}, S. and {Price-Whelan}, A.~M. and {Johnston}, K.~V.},
  	Eprint = {1703.04627},
  	Journal = {ArXiv e-prints},
  	Keywords = {Astrophysics - Astrophysics of Galaxies},
  	Month = mar,
  	Title = {{Gaps in Globular Cluster Streams: Pal 5 and the Galactic Bar}},
  	Year = 2017
}

