library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read in data into r
pr_students <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_student_permits_pr.sas7bdat")

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


pr_students %>%
  clean_dates() -> pr_students

# remove rows/CIDs that are in pr_students but not in census/CSDD
pr_students %>%
  dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr_students, SOURCE_FLAGS:ARUID_CENSUS)
    } %>%
      names() %>%
      length())
  } %>%
  pr_students[., ] -> pr_students

# remove rows/cids that are in pr_landing but not students
pr_students %>%
  dplyr::select(EFF_DT, VALID_DT) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr_students, EFF_DT, VALID_DT)
    } %>%
      names() %>%
      length())
  } %>%
  pr_students[., ] -> pr_students

pr_students %>%
  dplyr::rename(CID = cid) %>%

  # function determines which permits are valid on census date
  # and when people have multiple permits, keeps the one closest to cenus
  validity() %>%

  # function calculates the proportion of matching addresses and filters
  # people who's permit is valid on cenus date
  matches() -> pr_students

pr_students %>%
  dplyr::filter(LAND_DT <= lubridate::ymd("2016-05-10")) -> pr_students

# write csv file
readr::write_csv(pr_students, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/pr_students.csv")
