# scale_linewidth_interactive ----
test_that("scale_linewidth_interactive", {
  eval(test_scale, envir = list(name = "scale_linewidth_interactive"))
  eval(test_scale, envir = list(name = "scale_linewidth_continuous_interactive"))
  eval(test_scale, envir = list(name = "scale_linewidth_discrete_interactive"))
  eval(test_scale, envir = list(name = "scale_linewidth_binned_interactive"))
  eval(test_scale, envir = list(name = "scale_linewidth_date_interactive"))
  eval(test_scale, envir = list(name = "scale_linewidth_datetime_interactive"))
  eval(test_scale, envir = list(name = "scale_linewidth_ordinal_interactive"))
})

lw_data <- data.frame(
  x = rep(1:5, 3), y = c(1:5, 2:6, 3:7),
  w = rep(c(1, 2, 3), each = 5), f = rep(c("a", "b", "c"), each = 5)
)
lw_shapes <- function(doc) {
  nodes <- xml_find_all(doc, ".//line|.//polyline|.//text")
  vapply(xml_attrs(nodes), function(v) {
    paste(v[setdiff(names(v), c("id", "data-id", "key-id", "title"))], collapse = " ")
  }, "")
}

test_that("linewidth scales draw as in ggplot2, with interactive legend keys", {
  cases <- list(
    list(aes(linewidth = w), scale_linewidth, scale_linewidth_interactive, list()),
    list(aes(linewidth = w), scale_linewidth_binned, scale_linewidth_binned_interactive, list()),
    list(aes(linewidth = f), scale_linewidth_discrete, scale_linewidth_discrete_interactive, list()),
    list(aes(linewidth = f), scale_linewidth_manual, scale_linewidth_manual_interactive,
         list(values = c(a = 0.5, b = 2, c = 4)))
  )
  for (case in cases) {
    base <- ggplot(lw_data, aes(x, y, group = w)) + case[[1]]
    expected <- suppressWarnings(dsvg_plot(base + geom_line() + do.call(case[[2]], case[[4]])))
    doc <- suppressWarnings(dsvg_plot(base + geom_line_interactive() + do.call(
      case[[3]], c(case[[4]], list(data_id = function(breaks) paste0("k", breaks)))
    )))
    expect_equal(lw_shapes(doc), lw_shapes(expected))
    keys <- xml_attr(xml_find_all(doc, ".//*[@key-id]"), "key-id")
    expect_true(length(keys) > 0)
    expect_true(all(startsWith(keys, "k")))
  }
})
