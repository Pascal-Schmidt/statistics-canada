library(tidyverse)

validity_refugee <- function(df) {

  # arrange by date and pick distinct CIDs
  # census cut-off date is 10th of May, 2016. If a CID has more than one entry and has an effective
  # employment permit after 10th of May, 2016, then this/these row/rows is/are being removed
  # if a CID has only one entry and the effective date is after cut-off census date then the row is kept
  # if a CID has more than one row with permits after census cut-off date then the row which is closest to the census date is kept the other one removed

  df %>%
    dplyr::mutate(before_after_census = NA) %>%
    dplyr::mutate(
      census_date = lubridate::ymd("2016-05-10"),
      closest_to_census = as.character(census_date - lubridate::as_date(CLAIM_DT)) %>%
        as.integer(),
      before_after_census = "on"
    ) %>%
    dplyr::mutate(before_after_census = ifelse(closest_to_census < 0,
      "After",
      "Before"
    )) %>%
    dplyr::group_by(CID) %>%
    dplyr::mutate(n_CID = n()) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(CID, before_after_census) %>%
    dplyr::mutate(n_before_after = n()) %>%
    dplyr::ungroup() %>%

    # select only people who have had multiple permits after census date and none before census date, then take
    # the absolute value of the closest_to_census column entries of these particular people
    dplyr::mutate(closest_to_census = ifelse(before_after_census == "After" & (n_CID == n_before_after),
      abs(.$closest_to_census),
      .$closest_to_census
    )) %>%

    # the code below eliminates entries for people who have had permits before census and after census dates and then
    # removes the after census permits from the data frame
    dplyr::filter(closest_to_census >= 0 || NA) %>%

    # select the first entry of CID
    dplyr::arrange(CID, closest_to_census) %>%
    dplyr::distinct(CID, .keep_all = TRUE) %>%
    dplyr::mutate(type = "df") %>%
    dplyr::mutate(validity = ifelse(lubridate::as_date(CLAIM_DT) <= lubridate::ymd("2016-05-10"),
      "valid_during_census",
      NA
    )) %>%
    dplyr::mutate(validity = ifelse(lubridate::as_date(CLAIM_DT) > lubridate::ymd("2016-05-10"),
      "valid_after_census",
      .$validity
    )) %>%
    dplyr::mutate(validity = ifelse(is.na(validity),
      "valid_during_census",
      .$validity
    )) -> df

  return(df)
}
