library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read in data into r
landing <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_landing_records.sas7bdat")

########################
#### Load Functions ####
########################

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/clean_dates_fn.R"))

# create columns for matching addresses
source(paste0(root_dir, "/scripts/setup_functions/matches_fn_2.R"))

# only keep CIDs with valid PR status on census day
source(paste0(root_dir, "/scripts/setup_functions/validity_pr.R"))

landing %>%
  clean_dates() -> landing

# remove rows/CIDs that are in IRCC but not in landing
landing %>%
  dplyr::select(ARRIVAL_DT:YEARS_OF_SCHOOLING) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(landing, ARRIVAL_DT:YEARS_OF_SCHOOLING)
    } %>%
      names() %>%
      length())
  } %>%
  landing[., ] -> landing

# remove CIDs that are in landing but not in Census/CSDD
landing %>%
  dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(landing, SOURCE_FLAGS:ARUID_CENSUS)
    } %>%
      names() %>%
      length())
  } %>%
  landing[., ] -> landing

landing %>%
  matches_fn_2() -> landing

# Removal of individuals with invalid address on census
landing %>%
  dplyr::filter(match_IRCC_ARUID == "Match" | match_IRCC_ARUID == "No Match" | is.na(match_IRCC_ARUID)) -> landing

landing %>%
  dplyr::rename(cid = CID) %>%
  validity_pr() -> landing

# write data frame to sas
readr::write_csv(landing, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/landing.csv")
