library(tidyverse)
linked_cid <- function(df) {

  # remove rows/CIDs that are in IRCC but not in df
  df %>%
    dplyr::select(ARRIVAL_DT:VALID_DT) %>%
    is.na() %>%
    rowSums() %>%
    {
      which(. != {
        dplyr::select(df, ARRIVAL_DT:VALID_DT)
      } %>%
        names() %>%
        length())
    } %>%
    df[., ] -> df

  # remove rows/CIDs that are in df but not in IRCC
  df %>%
    dplyr::select(SOURCE_FLAGS:ARUID_CENSUS) %>%
    is.na() %>%
    rowSums() %>%
    {
      which(. != {
        dplyr::select(df, SOURCE_FLAGS:ARUID_CENSUS)
      } %>%
        names() %>%
        length())
    } %>%
    df[., ] -> df

  return(df)
}
