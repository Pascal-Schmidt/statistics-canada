library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read data into r
students <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_student_permits.sas7bdat")

########################
#### Load Functions ####
########################

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/clean_dates_fn.R"))

# remove CIDs that are in IRCC but not the census/csdd linkage
source(paste0(root_dir, "/scripts/setup_functions/linked_cid_fn.R"))

# create variables that identify if addresses are matching
source(paste0(root_dir, "/scripts/setup_functions/matches_fn.R"))

# remove CIDs that have valid permits on census day
source(paste0(root_dir, "/scripts/setup_functions/validity_fn.R"))

students %>%
  clean_dates() %>%
  linked_cid() %>%
  validity() %>%
  matches() -> students

readr::write_csv(students, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/students.csv")
