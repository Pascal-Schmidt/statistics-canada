# preparing data for combinations
list(emp, minister, refugee, students) %>%
  purrr::map(~ dplyr::select(., CID, type)) %>%
  base::do.call(rbind, .) %>%
  dplyr::group_by(CID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::arrange(CID) %>%
  dplyr::mutate(comb = type) -> combination

# convert to matrix for faster iterations
combination[, ] <- lapply(combination[, ], as.character)
combination <- as.matrix(combination)


for (i in (2:nrow(combination) - 1)) {
  if (combination[i, "CID"] == combination[i + 1, "CID"]) {
    combination[i + 1, "comb"] <- paste0(combination[i, "comb"], "_", combination[i + 1, "comb"])
  }
}

# convert matrix back to data frame
combination_combination <- as.data.frame(combination)

# only keep distinct CIDs
combination_combination %>%
  dplyr::mutate(
    comb = as.character(comb),
    n = as.integer(as.character(n)),
    CID = as.character(CID),
    type = as.character(type)
  ) %>%
  dplyr::arrange(CID, desc(comb)) %>%
  dplyr::distinct(CID, .keep_all = TRUE) %>%
  dplyr::select(-type) -> combination_combination
