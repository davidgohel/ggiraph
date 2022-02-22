library(tinytest)
library(ggiraph)
source("setup.R")

if (!requireNamespace("shinytest", quietly = TRUE)) {
  exit_file("package 'shinytest' is not installed")
}

result <- ggiraph:::fortify_font_db()
if(!(is.data.frame(result) && nrow(result) > 0)){
  exit_file("no available font")
}

# fonts ----
{
  expect_true(is.data.frame(result) && nrow(result) > 0)
  result <- ggiraph::match_family("sans")
  expect_true(is.character(result) && nzchar(result) > 0)
  expect_true(ggiraph::font_family_exists(result))
  result <- ggiraph:::default_fontname()
  expect_true(is.list(result) && all(names(result) %in% c("sans", "serif", "mono", "symbol")))
  result <- ggiraph:::validated_fonts()
  expect_true(is.list(result) && all(names(result) %in% c("sans", "serif", "mono", "symbol")))
}
