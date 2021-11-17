library(tinytest)
library(ggiraph)
library(ggplot2)

# copy_interactive_attrs_from_scale ----
{
  scale <- scale_colour_discrete_interactive(
    guide = guide_legend(), tooltip = "tooltip"
  )
  result <- ggiraph:::copy_interactive_attrs_from_scale(scale$guide, scale)
  ipar <- ggiraph:::get_ipar(result)
  ip <- ggiraph:::get_interactive_attrs(result$key, ipar = ipar)
  expect_equal(ip$tooltip, "tooltip")
}
{
  scale <- scale_colour_manual_interactive(
    guide = guide_legend(),
    tooltip = list(
      b = "tooltip 2",
      a = "tooltip 1",
      c = "tooltip 3"
    ),
    foo = rep("bar", 3), extra_interactive_params = "foo",
    breaks = c("a", "b", "c"),
    limits = c("a", "b", "c"),
    values = list(
      a = "black",
      b = "white",
      c = "grey"
    )
  )
  result <- ggiraph:::copy_interactive_attrs_from_scale(scale$guide, scale)
  ipar <- ggiraph:::get_ipar(result)
  ip <- ggiraph:::get_interactive_attrs(result$key, ipar = ipar)
  expect_equal(ip$tooltip, as.list(paste("tooltip", seq_len(3))))
}
{
  scale <- scale_colour_manual_interactive(
    guide = guide_legend(),
    tooltip = function(x) {
      (
        paste("tooltip", x)
      )
    },
    foo = rep("bar", 3), extra_interactive_params = "foo",
    breaks = c("a", "b", "c"),
    limits = c("a", "b", "c"),
    values = list(
      a = "black",
      b = "white",
      c = "grey"
    )
  )
  result <- ggiraph:::copy_interactive_attrs_from_scale(scale$guide, scale)
  ipar <- ggiraph:::get_ipar(result)
  ip <- ggiraph:::get_interactive_attrs(result$key, ipar = ipar)
  expect_equal(ip$tooltip, paste("tooltip", c("a", "b", "c")))
}
{
  scale <- scale_size_continuous_interactive(
    guide = guide_legend(),
    tooltip = function(x) {
      (
        paste("tooltip", x)
      )
    },
    labels = function(x) {
      label_interactive(x, tooltip = paste("tooltip", x))
    },
    foo = rep("bar", 5), extra_interactive_params = "foo",
    limits = c(1, 5)
  )
  result <- ggiraph:::copy_interactive_attrs_from_scale(scale$guide, scale)
  ipar <- ggiraph:::get_ipar(result)
  ip <- ggiraph:::get_interactive_attrs(result$key, ipar = ipar)
  expect_equal(ip$tooltip, paste("tooltip", seq_len(5)))
}
{
  scale <- scale_size_continuous_interactive(
    guide = guide_legend(reverse = TRUE),
    tooltip = function(x) {
      (
        paste("tooltip", x)
      )
    },
    labels = function(x) {
      label_interactive(x, tooltip = paste("tooltip", x))
    },
    foo = rep("bar", 5), extra_interactive_params = "foo",
    limits = c(1, 5)
  )
  result <- ggiraph:::copy_interactive_attrs_from_scale(scale$guide, scale)
  ipar <- ggiraph:::get_ipar(result)
  ip <- ggiraph:::get_interactive_attrs(result$key, ipar = ipar)
  expect_equal(ip$tooltip, paste("tooltip", seq_len(5)))
}
