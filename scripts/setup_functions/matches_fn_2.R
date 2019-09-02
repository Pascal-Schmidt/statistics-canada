library(tidyverse)

matches_fn_2 <- function(df) {
  df_address <- readr::read_csv("//cptsas1/Demographie/Adresses IRCC/5_Programmes/Data/csd_roll_up.csv") %>%
    dplyr::mutate_all(as.character)

  df %>%
    dplyr::left_join(df_address, by = c("derived_sgc2016" = "CSD")) -> df

  df %>%
    dplyr::mutate(
      IRCC_ARUID = ifelse(!(is.na(ARUID_CENSUS)), ar_uid == ARUID_CENSUS, "CENSUS_Missing"),
      CSDD_ARUID = ifelse(!(is.na(ARUID_CENSUS)), ARUID_CSDD == ARUID_CENSUS, "CENSUS_Missing"),
      IRCC_CSD = ifelse(!(is.na(CSD_CENSUS)), derived_sgc2016 == CSD_CENSUS, "CENSUS_Missing"),
      CSDD_CSD = ifelse(!(is.na(CSD_CENSUS)), CSD_CSDD == CSD_CENSUS, "CENSUS_Missing"),
      IRCC_DA = ifelse(!(is.na(DA_CENSUS)), derived_da2016 == DA_CENSUS, "CENSUS_Missing"),
      CSDD_DA = ifelse(!(is.na(DA_CENSUS)), DA_CSDD == DA_CENSUS, "CENSUS_Missing"),

      IRCC_CMA = ifelse(!(is.na(CMA_CENSUS)), CMA == CMA_CENSUS, "CENSUS_Missing"),
      IRCC_ER = ifelse(!(is.na(CSD_CENSUS)), ER == ER_CENSUS, "CENSUS_Missing"),

      CD_CENSUS = stringr::str_sub(CSD_CENSUS, start = 1, end = 4),
      CD_IRCC = stringr::str_sub(derived_sgc2016, start = 1, end = 4),
      CD_CSDD = stringr::str_sub(CSD_CSDD, start = 1, end = 4),
      PROV_IRCC = stringr::str_sub(derived_sgc2016, start = 1, end = 2)
    ) %>%
    dplyr::mutate(
      IRCC_PROV = ifelse(!(is.na(PROV_CENSUS)), PROV_IRCC == PROV_CENSUS, "CENSUS_Missing"),
      CSDD_PROV = ifelse(!(is.na(PROV_CENSUS)), PROV_CSDD == PROV_CENSUS, "CENSUS_Missing")
    ) %>%
    dplyr::mutate(
      IRCC_CD = ifelse(!(is.na(CD_CENSUS)), CD_IRCC == CD_CENSUS, "CENSUS_Missing"),
      CSDD_CD = CD_CSDD == ifelse(!(is.na(CD_CENSUS)), CD_CENSUS, "CENSUS_Missing"),
      match_CSDD_ARUID = NA
    ) %>%
    dplyr::mutate(match_CSDD_ARUID = ifelse(CSDD_ARUID == "CENSUS_Missing", "CENSUS_Missing", match_CSDD_ARUID)) %>%
    dplyr::mutate(match_CSDD_ARUID = ifelse(CSDD_ARUID == "TRUE", "Match", match_CSDD_ARUID)) %>%
    dplyr::mutate(
      match_CSDD_ARUID = ifelse(CSDD_ARUID == "FALSE", "No Match", match_CSDD_ARUID),
      match_IRCC_ARUID = NA
    ) %>%
    dplyr::mutate(match_IRCC_ARUID = ifelse(IRCC_ARUID == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_ARUID)) %>%
    dplyr::mutate(match_IRCC_ARUID = ifelse(IRCC_ARUID == "TRUE", "Match", match_IRCC_ARUID)) %>%
    dplyr::mutate(
      match_IRCC_ARUID = ifelse(IRCC_ARUID == "FALSE", "No Match", match_IRCC_ARUID),
      match_CSDD_CSD = NA
    ) %>%
    dplyr::mutate(match_CSDD_CSD = ifelse(CSDD_CSD == "CENSUS_Missing", "CENSUS_Missing", match_CSDD_CSD)) %>%
    dplyr::mutate(match_CSDD_CSD = ifelse(CSDD_CSD == "TRUE", "Match", match_CSDD_CSD)) %>%
    dplyr::mutate(
      match_CSDD_CSD = ifelse(CSDD_CSD == "FALSE", "No Match", match_CSDD_CSD),
      match_IRCC_CSD = NA
    ) %>%
    dplyr::mutate(match_IRCC_CSD = ifelse(IRCC_CSD == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_CSD)) %>%
    dplyr::mutate(match_IRCC_CSD = ifelse(IRCC_CSD == "TRUE", "Match", match_IRCC_CSD)) %>%
    dplyr::mutate(
      match_IRCC_CSD = ifelse(IRCC_CSD == "FALSE", "No Match", match_IRCC_CSD),
      match_CSDD_DA = NA
    ) %>%
    dplyr::mutate(match_CSDD_DA = ifelse(CSDD_DA == "CENSUS_Missing", "CENSUS_Missing", match_CSDD_DA)) %>%
    dplyr::mutate(match_CSDD_DA = ifelse(CSDD_DA == "TRUE", "Match", match_CSDD_DA)) %>%
    dplyr::mutate(
      match_CSDD_DA = ifelse(CSDD_DA == "FALSE", "No Match", match_CSDD_DA),
      match_IRCC_DA = NA
    ) %>%
    dplyr::mutate(match_IRCC_DA = ifelse(IRCC_DA == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_DA)) %>%
    dplyr::mutate(match_IRCC_DA = ifelse(IRCC_DA == "TRUE", "Match", match_IRCC_DA)) %>%
    dplyr::mutate(
      match_IRCC_DA = ifelse(IRCC_DA == "FALSE", "No Match", match_IRCC_DA),
      match_CSDD_CD = NA
    ) %>%
    dplyr::mutate(match_CSDD_CD = ifelse(CSDD_CD == "CENSUS_Missing", "CENSUS_Missing", match_CSDD_CD)) %>%
    dplyr::mutate(match_CSDD_CD = ifelse(CSDD_CD == "TRUE", "Match", match_CSDD_CD)) %>%
    dplyr::mutate(
      match_CSDD_CD = ifelse(CSDD_CD == "FALSE", "No Match", match_CSDD_CD),
      match_IRCC_CD = NA
    ) %>%
    dplyr::mutate(match_IRCC_CD = ifelse(IRCC_CD == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_CD)) %>%
    dplyr::mutate(match_IRCC_CD = ifelse(IRCC_CD == "TRUE", "Match", match_IRCC_CD)) %>%
    dplyr::mutate(
      match_IRCC_CD = ifelse(IRCC_CD == "FALSE", "No Match", match_IRCC_CD),
      match_CSDD_PROV = NA
    ) %>%
    dplyr::mutate(match_CSDD_PROV = ifelse(CSDD_PROV == "CENSUS_Missing", "CENSUS_Missing", match_CSDD_PROV)) %>%
    dplyr::mutate(match_CSDD_PROV = ifelse(CSDD_PROV == "TRUE", "Match", match_CSDD_PROV)) %>%
    dplyr::mutate(
      match_CSDD_PROV = ifelse(CSDD_PROV == "FALSE", "No Match", match_CSDD_PROV),
      match_IRCC_PROV = NA
    ) %>%
    dplyr::mutate(match_IRCC_PROV = ifelse(IRCC_PROV == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_PROV)) %>%
    dplyr::mutate(match_IRCC_PROV = ifelse(IRCC_PROV == "TRUE", "Match", match_IRCC_PROV)) %>%
    dplyr::mutate(
      match_IRCC_PROV = ifelse(IRCC_PROV == "FALSE", "No Match", match_IRCC_PROV),
      match_IRCC_CMA = NA
    ) %>%
    dplyr::mutate(match_IRCC_CMA = ifelse(IRCC_CMA == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_CMA)) %>%
    dplyr::mutate(match_IRCC_CMA = ifelse(IRCC_CMA == "TRUE", "Match", match_IRCC_CMA)) %>%
    dplyr::mutate(
      match_IRCC_CMA = ifelse(IRCC_CMA == "FALSE", "No Match", match_IRCC_CMA),
      match_IRCC_ER = NA
    ) %>%
    dplyr::mutate(match_IRCC_ER = ifelse(IRCC_ER == "CENSUS_Missing", "CENSUS_Missing", match_IRCC_PROV)) %>%
    dplyr::mutate(match_IRCC_ER = ifelse(IRCC_ER == "TRUE", "Match", match_IRCC_PROV)) %>%
    dplyr::mutate(match_IRCC_ER = ifelse(IRCC_ER == "FALSE", "No Match", match_IRCC_PROV)) -> df

  return(df)
}
