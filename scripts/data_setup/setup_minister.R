library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read data into r
minister <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_ministers_permits.sas7bdat")

########################
#### Load Functions ####
########################

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/clean_dates_fn.R"))

# remove CIDs that are in IRCC but not the census/csdd linkage
source(paste0(root_dir, "/scripts/setup_functions/linked_cid_fn.R"))

# create variables that identify if cid had a valid permit during census
source(paste0(root_dir, "/scripts/setup_functions/matches_fn.R"))

# remove CIDs that are in IRCC but not the census/csdd linkage
source(paste0(root_dir, "/scripts/setup_functions/validity_fn.R"))


minister %>%
  clean_dates() %>%
  linked_cid() %>%
  validity() %>%
  matches() -> minister

# write csv file
readr::write_csv(minister, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/minister.csv")
