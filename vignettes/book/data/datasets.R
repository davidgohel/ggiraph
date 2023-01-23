library(here)
library(charlatan)
library(data.table)
library(tidyverse)
library(glue)

species <- ch_taxonomic_species(n = 10)
dat <- lapply(species, function(species, n) {
  data.table(
    date = as.Date(seq_len(n), origin = "2022-01-01"),
    score = cumsum(runif(n, -1, 1)),
    species = species
  )
}, n = 365)
dat <- rbindlist(dat)
setDF(dat)
saveRDS(dat, file = here("data", "species-ts.RDS"))
rm(dat)


crimes <- USArrests |>
  add_column(state = tolower(rownames(USArrests)))

saveRDS(crimes, file = here("data", "crimes.RDS"))
rm(crimes)


departures <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-04-27/departures.csv') %>%
  drop_na(ceo_dismissal, departure_code) %>%
  mutate(coname = gsub(" +INC|CO?(RP)$", "", coname),
         motive = factor(
           x = departure_code, levels = 1:9,
           labels = c("Death", "Health Concerns", "Job performance", "Policy related problems", "Voluntary turnover", "When to work in other company", "Departure following a marger adquisition", "Unknown", "Unknown")),
         main_cause = factor(
           x = ceo_dismissal,
           levels = c(0, 1),
           labels = c("voluntary", "involuntary")
         ),
         tooltip = glue("Firm: {coname}\nCEO: {exec_fullname}\nYear: {fyear}\nMotive: {motive}")
  ) %>%
  semi_join(
    slice_max(.data = count(., coname), order_by=n, n = 20, with_ties = FALSE)
  ) %>%
  select(coname, main_cause, tooltip, fyear)
saveRDS(departures, file = here("data", "departures.RDS"))
rm(departures)
