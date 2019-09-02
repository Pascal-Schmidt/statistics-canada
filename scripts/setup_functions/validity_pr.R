library(tidyverse)

validity_pr <- function(df) {

  # arrange by date and pick distinct cids
  # census cut-off date is 10th of May, 2016. If a cid has more than one entry and has an effective
  # employment permit after 10th of May, 2016, then this/these row/rows is/are being removed
  # if a cid has only one entry and the effective date is after cut-off census date then the row is kept
  # if a cid has more than one row with permits after census cut-off date then the row which is closest to the census date is kept the other one removed
  df %>%
    dplyr::mutate(before_after_census = NA) %>%
    dplyr::mutate(
      census_date = lubridate::ymd("2016-05-10"),
      closest_to_census = as.character(census_date - lubridate::as_date(LAND_DT)) %>%
        as.integer(),
      before_after_census = ifelse(closest_to_census < 0,
        "After",
        "Before"
      )
    ) %>%
    dplyr::group_by(cid) %>%
    dplyr::mutate(n_cid = n()) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(cid, before_after_census) %>%
    dplyr::mutate(n_before_after = n()) %>%
    dplyr::ungroup() %>%

    # select only people who have had multiple permits after census date and none before census date, then take
    # the absolute value of the closest_to_census column entries of these particular people
    dplyr::mutate(closest_to_census = ifelse(before_after_census == "After" & (n_cid == n_before_after),
      abs(.$closest_to_census),
      .$closest_to_census
    )) %>%

    # the code below eliminates entries for people who have had permits before census and after census dates and then
    # removes the after census permits from the data frame
    dplyr::filter(closest_to_census >= 0 | NA) %>%

    # select the first entry of cid
    dplyr::arrange(cid, closest_to_census) %>%
    dplyr::distinct(cid, .keep_all = TRUE) %>%
    dplyr::mutate(type = "df_landing") %>%
    dplyr::mutate(validity = ifelse(lubridate::as_date(LAND_DT) < lubridate::ymd("2016-05-10"),
      "valid_before_census",
      NA
    )) %>%
    dplyr::mutate(validity = ifelse(lubridate::as_date(LAND_DT) > lubridate::ymd("2016-05-10"),
      "valid_after_census",
      .$validity
    )) %>%
    dplyr::mutate(validity = ifelse(is.na(validity),
      "valid_during_census",
      .$validity
    )) -> df

  # Immigrants who landed before census
  df %>%
    dplyr::filter(validity == "valid_before_census" | validity == "valid_during_census") %>%
    dplyr::select(-c(ar_uid:derived_da2016, address_mun, ER_CSDD:ARUID_CENSUS, IRCC_ARUID:CSDD_CD)) -> df

  return(df)
}
