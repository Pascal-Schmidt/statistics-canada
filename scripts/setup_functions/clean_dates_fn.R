library(tidyverse)
clean_dates <- function(df) {

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

  # transform SAS numric into date format
  lapply(df[, colnames(df) %in% c("EFF_DT", "ARRIVAL_DT", "VALID_DT", "BIRTH_DT", "LAND_DT", "ADDRESS_EFF_DT", "CLAIM_DT")], trans_date) %>%
    lapply(chr_to_date) -> df[, colnames(df) %in% c("EFF_DT", "ARRIVAL_DT", "VALID_DT", "BIRTH_DT", "LAND_DT", "ADDRESS_EFF_DT", "CLAIM_DT")]

  # convert "" to NA values
  df[, !(colnames(df) %in% c(
    "EFF_DT", "ARRIVAL_DT", "VALID_DT", "BIRTH_DT",
    "LAND_DT", "ADDRESS_EFF_DT", "CLAIM_DT"
  ))] <- lapply(
    df[, !(colnames(df) %in% c(
      "EFF_DT", "ARRIVAL_DT",
      "VALID_DT", "BIRTH_DT", "LAND_DT",
      "ADDRESS_EFF_DT", "CLAIM_DT"
    ))],
    chr_to_NA
  )

  return(df)
}
