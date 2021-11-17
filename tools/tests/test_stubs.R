# generates test files when missing
# files go to "inst/tinytest"
{
  all_files <- list.files("R/")
  all_files <- Filter(x = all_files, function(x) {
    !grepl("(ggplot2|RcppExports)", x)
  })
  gg_files <- c(
    # geoms scales guides
    list.files("R/", pattern = "^(geom|scale|guide)_(\\w+)_interactive.R$"),
    # grobs
    list.files("R/", pattern = "^interactive_(\\w+)_grob.R$"),
    # annotation geoms
    list.files("R/", pattern = "^annot\\w+?_interactive.R$")
  )
  misc_files <- setdiff(all_files, gg_files)

  gg_template <- "library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source(\"setup.R\")

# %s ----
{
  #TODO
}"
  misc_template <- "library(tinytest)
library(ggiraph)
source(\"setup.R\")

# %s ----
{
  #TODO
}"
  for (el in list(
    list(
      files = gg_files,
      template = gg_template
    ),
    list(
      files = misc_files,
      template = misc_template
    )
  )) {
    purrr::walk(
      el$files,
      function(x, template) {
        barename <- sub(".R$", "", x)
        fn <- barename
        fn <- paste0("test-", fn, ".R")
        fn <- file.path("inst/tinytest", fn)
        if (!file.exists(fn)) {
          message("Creating ", fn)
          f <- file(fn, "w")
          tryCatch(
            {
              cat(sprintf(template, barename), sep = "\n", file = f)
            },
            finally = close(f)
          )
        }
      },
      el$template
    )
  }
}
