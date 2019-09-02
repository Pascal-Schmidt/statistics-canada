library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read in data into r
pr <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_landing_rec_pr_v2_nodup.sas7bdat")

########################
#### Load Functions ####
########################

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/clean_dates_fn.R"))

# create columns for matching addresses
source(paste0(root_dir, "/scripts/setup_functions/matches_fn_2.R"))

# only keep CIDs with valid PR status on census day
source(paste0(root_dir, "/scripts/setup_functions/validity_pr.R"))

pr %>%
  clean_dates() -> pr

# remove CIDs that are in PR but not in Census/CSDD
pr %>%
  dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr, SOURCE_FLAGS:ARUID_CENSUS)
    } %>%
      names() %>%
      length())
  } %>%
  pr[., ] -> pr

pr %>%
  matches_fn_2() -> pr

# Removal of individuals with invalid address on census
pr %>%
  dplyr::filter(match_IRCC_ARUID == "Match" | match_IRCC_ARUID == "No Match" | is.na(match_IRCC_ARUID)) -> pr

pr %>%
  validity_pr() -> pr

# Immigrants who landed before census
pr %>%
  dplyr::filter(validity == "valid_before_census" | validity == "valid_during_census") %>%
  dplyr::select(-c(ar_uid:derived_da2016, address_mun, ER_CSDD:ARUID_CENSUS, IRCC_ARUID:CSDD_CD)) -> pr

# write data frame to sas
haven::write_sas(pr, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/pr.sas7bdat")
