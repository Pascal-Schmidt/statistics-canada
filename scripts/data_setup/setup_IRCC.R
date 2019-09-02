library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# helper functions for data cleaning
trans_date <- function(x) {
  format(as.Date(x, origin = "1960-01-01"), "%d%b%Y")
}
chr_to_date <- function(x) {
  lubridate::parse_date_time(x, "%d%b%Y")
}
chr_to_NA <- function(x) {
  ifelse(x == "", NA, x)
}

# read in data into r
IRCC <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/selected_vars.sas7bdat")
IRCC[, ] <- lapply(IRCC[, ], chr_to_NA)
