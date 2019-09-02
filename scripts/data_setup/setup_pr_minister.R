library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read in data into r
pr_minister <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_minister_pr.sas7bdat")

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


pr_minister %>%
  clean_dates() -> pr_minister

# remove rows/CIDs that are in pr_minister but not in census/CSDD
pr_minister %>%
  dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr_minister, SOURCE_FLAGS:ARUID_CENSUS)
    } %>%
      names() %>%
      length())
  } %>%
  pr_minister[., ] -> pr_minister

# remove rows/cids that are in pr_landing but not students
pr_minister %>%
  dplyr::select(EFF_DT, VALID_DT) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr_minister, EFF_DT, VALID_DT)
    } %>%
      names() %>%
      length())
  } %>%
  pr_minister[., ] -> pr_minister

pr_minister %>%
  dplyr::rename(CID = cid) %>%

  # function determines which permits are valid on census date
  # and when people have multiple permits, keeps the one closest to cenus
  validity() %>%

  # function calculates the proportion of matching addresses and filters
  # people who's permit is valid on cenus date
  matches() -> pr_minister

pr_minister %>%
  dplyr::filter(LAND_DT <= lubridate::ymd("2016-05-10")) -> pr_minister

# write csv file
readr::write_csv(pr_minister, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/pr_minister.csv")
