library(tidyverse)
root_dir <- rprojroot::find_rstudio_root_file()

refugee <- haven::read_sas("//cptsas1/Demographie/Adresses IRCC/5_Programmes/merged_refugee.sas7bdat")

########################
#### Load Functions ####
########################

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/clean_dates_fn.R"))

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/matches_fn_2.R"))

# clean up dates
source(paste0(root_dir, "/scripts/setup_functions/validity_refugee.R"))

refugee %>%
  clean_dates() -> refugee

# remove rows/CIDs that are in refugee but not in IRCC
refugee %>%
  dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(refugee, SOURCE_FLAGS:ARUID_CENSUS)
    } %>%
      names() %>%
      length())
  } %>%
  refugee[., ] -> refugee

# remove rows/CIDs that are in IRCC but not in refugee
refugee %>%
  dplyr::select(ADDRESS_EFF_DT:TOTPER) %>%
  is.na() %>%
  rowSums() %>%
  {
    which(. != {
      dplyr::select(refugee, ADDRESS_EFF_DT:TOTPER)
    } %>%
      names() %>%
      length())
  } %>%
  refugee[., ] -> refugee

refugee %>%
  matches_fn_2() -> refugee

# Removal of individuals with invalid address on census
refugee %>%
  dplyr::filter(match_IRCC_ARUID == "Match" | match_IRCC_ARUID == "No Match" | is.na(match_IRCC_ARUID)) -> refugee

refugee %>%
  validity_refugee() -> refugee

# Immigrants who landed before census
refugee %>%
  dplyr::filter(validity == "valid_before_census" | validity == "valid_during_census") %>%
  dplyr::select(-c(ar_uid:derived_da2016, address_mun:ARUID_CENSUS, IRCC_ARUID:CSDD_CD)) -> refugee

# write data frame to csv
readr::write_csv(refugee, "//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/refugee.csv")
