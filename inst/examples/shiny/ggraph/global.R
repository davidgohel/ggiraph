library(tidyverse)
library(stringr)
library(igraph)
library(tidygraph)
library(ggraph)
library(magrittr)
library(ggiraph)

# http://www.pieceofk.fr/?p=431 ----

pdb <- tools::CRAN_package_db()


aut <- pdb$Author %>%
  str_replace_all("\\(([^)]+)\\)", "") %>%
  str_replace_all("\\[([^]]+)\\]", "") %>%
  str_replace_all("<([^>]+)>", "") %>%
  str_replace_all("\n", " ") %>%
  str_replace_all("[Cc]ontribution.* from|[Cc]ontribution.* by|[Cc]ontributors", " ") %>%
  str_replace_all("\\(|\\)|\\[|\\]", " ") %>%
  iconv(to = "ASCII//TRANSLIT") %>%
  str_replace_all("'$|^'", "") %>%
  gsub("([A-Z])([A-Z]{1,})", "\\1\\L\\2", ., perl = TRUE) %>%
  gsub("\\b([A-Z]{1}) \\b", "\\1\\. ", .)

aut <- aut %>%
  purrr::map(str_split, ",|;|&| \\. |--|(?<=[a-z])\\.| [Aa]nd | [Ww]ith | [Bb]y ", simplify = TRUE) %>%
  purrr::map(str_replace_all, "[[:space:]]+", " ") %>%
  purrr::map(str_replace_all, " $|^ | \\.", "") %>%
  purrr::map(str_replace_all, "'", " ") %>%
  purrr::map(str_replace_all, "^(: )", " ") %>%
  purrr::map(function(x) x[str_length(x) != 0]) %>%
  set_names(pdb$Package) %>%
  extract(map_lgl(., function(x) length(x) > 1))


aut_list <- aut %>%
  unlist() %>%
  dplyr::as_data_frame() %>%
  count(value) %>%
  rename(Name = value, Package = n)

edge_list <- aut %>%
  purrr::map(combn, m = 2) %>%
  do.call("cbind", .) %>%
  t() %>%
  dplyr::as_data_frame() %>%
  arrange(V1, V2) %>%
  count(V1, V2)

g <- edge_list %>%
  select(V1, V2) %>%
  as.matrix() %>%
  graph.edgelist(directed = FALSE) %>%
  as_tbl_graph() %>%
  activate("edges") %>%
  mutate(Weight = edge_list$n) %>%
  activate("nodes") %>%
  rename(Name = name) %>%
  mutate(Component = group_components()) %>%
  filter(Component == names(table(Component))[which.max(table(Component))])


g <- g %>%
  left_join(aut_list) %>%
  filter(Package > 4) %>%
  mutate(Component = group_components()) %>%
  filter(Component == names(table(Component))[which.max(table(Component))])

pdb <- pdb[, c("Package", "Title", "Version", "License", "Author")] %>%
  as_tibble()
