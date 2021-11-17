library(tinytest)
library(ggiraph)
library(grid)

# grob_interactive is working ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- c(list(grob_func = pointsGrob), mapping)
  result <- do.call(ggiraph:::grob_interactive, args)
  # is grob?
  expect_inherits(result, "grob")
  # is interactive grob?
  expect_true(any(grepl("^interactive_", class(result))))
  # ipar matching
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping)
}

# grob_interactive is using correct class ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- c(list(grob_func = pointsGrob), mapping)
  args <- c(list(cl = "anotherclass"), args)
  result <- do.call(ggiraph:::grob_interactive, args)
  expect_inherits(result, "anotherclass")
}

# grob_interactive is using correct data attr ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- c(list(grob_func = pointsGrob), mapping)
  args <- c(list(data_attr = "key-id"), args)
  result <- do.call(ggiraph:::grob_interactive, args)
  expect_equal(ggiraph:::get_data_attr(result), "key-id")
}

# grob_interactive is using correct ipar ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip", foo = "bar")
  args <- c(list(grob_func = pointsGrob), mapping)
  args <- c(list(extra_interactive_params = "foo"), args)
  result <- do.call(ggiraph:::grob_interactive, args)
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping)
}
