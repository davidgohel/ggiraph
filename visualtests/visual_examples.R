library(purrr)
library(magrittr)
library(rmarkdown)
library(webshot)


files <- list.files(system.file("examples/shiny", package="ggiraph"), full.names = TRUE) %>%
  setdiff(system.file("examples/shiny/ggraph", package="ggiraph")) %>%
  map_chr(function(appdir) {
    message(appdir)
    png_ <- file.path( tempdir(), paste0( basename(appdir), ".png") )
    webshot::appshot(appdir, png_, delay = 2)
    png_
  })
files %>% walk( browseURL )

files <- list.files(system.file("rmd", package="ggiraph"), full.names = TRUE, recursive = TRUE, pattern = "\\.Rmd$") %>%
  map_chr(function(rmdfile) {
    render(rmdfile)
    png_ <- file.path( tempdir(), paste0( basename(rmdfile), ".png") )
    webshot::webshot(gsub("\\.Rmd$", ".html", rmdfile), png_, delay = 2)
    png_
  })
files %>% walk( browseURL )
