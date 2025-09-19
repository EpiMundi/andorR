## code to prepare `DATASET` dataset goes here

library(data.tree)
library(yaml)

# Ethical investing in YAML format
ethical_nl <- yaml::read_yaml("data-raw/ethical.yml")
usethis::use_data(ethical_nl)

#notifiable <- openxlsx::read.xlsx("data-raw/notifiable.xlsx", "Sheet1")
notifiable <- yaml::read_yaml("data-raw/notifiable.yml")
tree <- as.Node(notifiable)
usethis::use_data(notifiable)

usethis::use_data(DATASET, overwrite = TRUE)
