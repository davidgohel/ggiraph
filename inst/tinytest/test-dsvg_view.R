library(tinytest)
library(ggiraph)

# dsvg view
{
  v <- dsvg_view(plot(1:10))
  if (interactive()) {
    expect_inherits(v, "html")
  } else {
    expect_null(v)
  }
}
