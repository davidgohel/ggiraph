library(tinytest)
library(ggiraph)

# count the calls listing the system fonts while evaluating `expr`
count_font_listings <- function(expr) {
  counter <- new.env()
  counter$n <- 0L
  suppressMessages(trace(
    "system_fonts",
    tracer = bquote(assign("n", get("n", envir = .(counter)) + 1L, envir = .(counter))),
    print = FALSE,
    where = asNamespace("gdtools")
  ))
  on.exit(suppressMessages(
    untrace("system_fonts", where = asNamespace("gdtools"))
  ))
  force(expr)
  counter$n
}

fs <- gdtools::font_set_liberation()

# validated_fonts lists the fonts once when all families are supplied ----
{
  n <- count_font_listings(fonts <- validated_fonts(fs$dsvg_fonts))
  expect_equal(n, 1L)
  expect_equal(fonts, fs$dsvg_fonts)
}

# validated_fonts completes missing or unknown families ----
{
  fonts <- validated_fonts(list(sans = "foo-bar-not-a-font", mono = fs$mono))
  expect_equal(sort(names(fonts)), sort(c("sans", "serif", "mono", "symbol")))
  expect_equal(fonts$sans, fs$sans)
  expect_equal(fonts$serif, fs$serif)
  expect_equal(fonts$mono, fs$mono)
}

# girafe with a font_set lists the fonts once ----
{
  library(ggplot2)
  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point_interactive(aes(tooltip = rownames(mtcars)))
  n <- count_font_listings(girafe(ggobj = p, font_set = fs))
  expect_equal(n, 1L)
}
