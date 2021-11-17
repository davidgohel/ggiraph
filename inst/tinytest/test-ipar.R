library(tinytest)
library(ggiraph)
library(grid)

# has_interactive_attrs is working ----
{
  expect_true(ggiraph:::has_interactive_attrs(list(tooltip = "tooltip")))
  expect_false(ggiraph:::has_interactive_attrs(list(foo = "bar")))
  expect_true(ggiraph:::has_interactive_attrs(list(foo = "bar"),
    ipar = c(ggiraph:::IPAR_NAMES, "foo")
  ))
}

# get_interactive_attr_names is working ----
{
  expect_equal(ggiraph:::get_interactive_attr_names(
    list(tooltip = "tooltip")
  ), c("tooltip"))
  expect_equal(ggiraph:::get_interactive_attr_names(
    list(tooltip = "tooltip", foo = "bar"),
    ipar = c(ggiraph:::IPAR_NAMES, "foo")
  ), c("tooltip", "foo"))
  x <- "foo"
  attr(x, "interactive") <- list(tooltip = "tooltip")
  expect_equal(ggiraph:::get_interactive_attr_names(
    list(tooltip = "tooltip")
  ), c("tooltip"))
}

# get_interactive_attrs is working ----
{
  expect_equal(ggiraph:::get_interactive_attrs(
    list(tooltip = "tooltip", data_id = "id")
  ), list(tooltip = "tooltip", data_id = "id"))
  expect_equal(ggiraph:::get_interactive_attrs(
    list(tooltip = "tooltip", foo = "bar"),
    ipar = c(ggiraph:::IPAR_NAMES, "foo")
  ), list(tooltip = "tooltip", foo = "bar"))
  x <- "foo"
  attr(x, "interactive") <- list(tooltip = "tooltip")
  expect_equal(ggiraph:::get_interactive_attrs(
    x
  ), list(tooltip = "tooltip"))
}

# remove_interactive_attrs is working ----
{
  expect_equal(ggiraph:::remove_interactive_attrs(
    list(tooltip = "tooltip", data_id = "id", foo = "bar")
  ), list(foo = "bar"))
  expect_equal(unname(ggiraph:::remove_interactive_attrs(
    list(tooltip = "tooltip", foo = "bar"),
    ipar = c(ggiraph:::IPAR_NAMES, "foo")
  )), list())
}

# copy_interactive_attrs is working ----
{
  src <- list(tooltip = "tooltip", data_id = "id", foo = "bar")
  dst <- list(foo2 = "bar2")
  dst <- ggiraph:::copy_interactive_attrs(src, dst)
  expect_equal(dst, list(foo2 = "bar2", data_id = "id", tooltip = "tooltip"))

  src <- list(tooltip = "tooltip", data_id = "id", foo = "bar")
  dst <- list(foo2 = "bar2")
  dst <- ggiraph:::copy_interactive_attrs(src, dst, ipar = c(ggiraph:::IPAR_NAMES, "foo"))
  expect_equal(dst, list(foo2 = "bar2", data_id = "id", tooltip = "tooltip", foo = "bar"))
}

# copy_interactive_attrs preserves functions ----
{
  fun <- function(x) {
    x
  }
  src <- list(tooltip = fun)
  dst <- list()
  dst <- ggiraph:::copy_interactive_attrs(src, dst)
  expect_true(is.function(dst$tooltip))
}

# copy_interactive_attrs preserves names ----
{
  src <- list(tooltip = c(foo = "bar"))
  dst <- list()
  dst <- ggiraph:::copy_interactive_attrs(src, dst)
  expect_equal(names(dst$tooltip), "foo")
}

# copy_interactive_attrs accepts row indices ----
{
  src <- list(tooltip = c("1", "2", "3"))
  dst <- list(foo2 = "bar2")
  dst <- ggiraph:::copy_interactive_attrs(src, dst, rows = c(1, 2))
  expect_equal(dst, list(foo2 = "bar2", tooltip = c("1", "2")))
}

# copy_interactive_attrs accepts dots and uses list ----
{
  src <- list(tooltip = c(foo = "bar"))
  dst <- list()
  dst <- ggiraph:::copy_interactive_attrs(src, dst, 2)
  expect_equal(dst$tooltip, c(foo = "bar", foo = "bar"))
  dst <- ggiraph:::copy_interactive_attrs(src, dst, 2, useList = TRUE)
  expect_equal(dst$tooltip, matrix("bar", ncol = 1, nrow = 2, dimnames = list(NULL, "foo")))
}

# add_interactive_attrs is working with grob ----
{
  gr <- pointsGrob()
  dat <- list(tooltip = "tooltip", data_id = "id")
  gr <- ggiraph:::add_interactive_attrs(gr, dat)

  expect_inherits(gr, "interactive_points_grob")
  expect_equal(gr$.interactive$tooltip, dat$tooltip)
  expect_equal(gr$.interactive$data_id, dat$data_id)
}

# add_interactive_attrs accepts row indices ----
{
  gr <- pointsGrob()
  dat <- list(tooltip = c("1", "2", "3"))
  gr <- ggiraph:::add_interactive_attrs(gr, dat, rows = c(2))

  expect_inherits(gr, "interactive_points_grob")
  expect_equal(gr$.interactive$tooltip, dat$tooltip[2])
}

# add_interactive_attrs is working with gTree ----
{
  gr <- gTree(children = gList(pointsGrob()))
  dat <- list(tooltip = "tooltip", data_id = "id")
  gr <- ggiraph:::add_interactive_attrs(gr, dat)

  expect_inherits(gr$children[[1]], "interactive_points_grob")
  expect_equal(gr$children[[1]]$.interactive$tooltip, dat$tooltip)
  expect_equal(gr$children[[1]]$.interactive$data_id, dat$data_id)
}

# add_interactive_attrs needs non-empty gTree ----
{
  gr <- gTree()
  dat <- list(tooltip = "tooltip", data_id = "id")
  gr <- ggiraph:::add_interactive_attrs(gr, dat)
  expect_equal(length(gr$children), 0)
}

# add_interactive_attrs needs valid grob ----
{
  gr <- list()
  dat <- list(tooltip = "tooltip", data_id = "id")
  gr <- ggiraph:::add_interactive_attrs(gr, dat)
  expect_equal(length(gr), 0)

  gr <- ggplot2::zeroGrob()
  dat <- list(tooltip = "tooltip", data_id = "id")
  gr <- ggiraph:::add_interactive_attrs(gr, dat)
  expect_null(ggiraph:::get_interactive_data(gr)$tooltip)
}

# add_interactive_attrs needs valid interactive data ----
{
  gr <- grid::pointsGrob()
  result <- ggiraph:::add_interactive_attrs(gr, list())
  expect_identical(gr, result)
}

# add_interactive_attrs needs matching lengths of gTree children and data ----
{
  gr <- gTree(children = gList(pointsGrob(), pointsGrob()))
  dat <- base::data.frame(tooltip = c("tooltip1", "tooltip2"))
  gr <- ggiraph:::add_interactive_attrs(gr, dat)

  expect_inherits(gr$children[[1]], "interactive_points_grob")
  expect_equal(gr$children[[1]]$.interactive$tooltip, "tooltip1")
  expect_inherits(gr$children[[2]], "interactive_points_grob")
  expect_equal(gr$children[[2]]$.interactive$tooltip, "tooltip2")

  gr <- gTree(children = gList(pointsGrob()))
  dat <- base::data.frame(tooltip = c("tooltip1", "tooltip2"))
  expect_error(ggiraph:::add_interactive_attrs(gr, dat))
}

# get_ipar works
{
  ipar <- c("tooltip")
  gr <- grid::pointsGrob()
  gr$.ipar <- ipar
  expect_identical(ggiraph:::get_ipar(gr), ipar)
  gr$.ipar <- NULL
  attr(gr, "ipar") <- ipar
  expect_identical(ggiraph:::get_ipar(gr), ipar)
  expect_identical(ggiraph:::get_ipar(list()), ggiraph:::IPAR_NAMES)
}

# get_data_attr works
{
  data_attr <- c("key-id")
  gr <- grid::pointsGrob()
  gr$.data_attr <- data_attr
  expect_identical(ggiraph:::get_data_attr(gr), data_attr)
  gr$.data_attr <- NULL
  attr(gr, "data_attr") <- data_attr
  expect_identical(ggiraph:::get_data_attr(gr), data_attr)
  expect_identical(ggiraph:::get_data_attr(list()), "data-id")
}

# interactive_attr_toxml ---
{
  expect_null(ggiraph:::interactive_attr_toxml(interactive_points_grob(tooltip = "tooltip")))
  expect_null(ggiraph:::interactive_attr_toxml(interactive_points_grob(), ids = "1"))
}
