library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

# read in data into r
pr_refugee <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_refugee_pr.sas7bdat")

########################
#### Load Functions ####
########################

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/clean_dates_fn.R"))

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/matches_fn_2.R"))

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/validity_refugee.R"))

pr_refugee %>%
  clean_dates() -> pr_refugee

# remove rows/CIDs that are in refugee but not in PR
pr_refugee %>%
  dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr_refugee, SOURCE_FLAGS:ARUID_CENSUS)
    } %>%
      names() %>%
      length())
  } %>%
  pr_refugee[., ] -> pr_refugee

# remove rows/cids that are in pr_landing but not refugee
pr_refugee %>%
  dplyr::select(ADDRESS_EFF_DT, CLAIM_DT) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(pr_refugee, ADDRESS_EFF_DT, CLAIM_DT)
    } %>%
      names() %>%
      length())
  } %>%
  pr_refugee[., ] -> pr_refugee

pr_refugee %>%
  dplyr::rename(CID = cid) %>%

  # function determines which permits are valid on census date
  # and when people have multiple permits, keeps the one closest to cenus
  validity_refugee() %>%

  # function calculates the proportion of matching addresses and filters
  # people who's permit is valid on cenus date
  matches_fn_2() -> pr_refugee

pr_refugee %>%
  dplyr::filter(validity == "valid_during_census") -> pr_refugee

pr_refugee %>%
  dplyr::filter(LAND_DT <= lubridate::ymd("2016-05-10")) -> pr_refugee

pr_refugee %>%
  dplyr::select(-c(ar_uid:derived_da2016, address_mun:ARUID_CENSUS)) -> pr_refugee

# write csv file
readr::write_csv(pr_refugee, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/pr_refugee.csv")
