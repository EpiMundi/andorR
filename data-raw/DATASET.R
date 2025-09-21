## code to prepare `DATASET` dataset goes here

library(data.tree)
library(yaml)

# Ethical investing in YAML format
ethical_nl <- yaml::read_yaml("data-raw/ethical.yml")
usethis::use_data(ethical_nl)



usethis::use_data(DATASET, overwrite = TRUE)
