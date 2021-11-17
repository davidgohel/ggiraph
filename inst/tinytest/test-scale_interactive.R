library(tinytest)
library(ggiraph)
library(ggplot2)

scale_func <- scale_color_discrete_interactive

# scale_interactive
# scale_interactive with no guide, returns default scale ----
{
  scale <- scale_func(guide = NULL, tooltip = "tooltip")
  expect_null(scale$tooltip)
  scale <- scale_func(guide = FALSE, tooltip = "tooltip")
  expect_null(scale$tooltip)
  scale <- scale_func(guide = "none", tooltip = "tooltip")
  expect_null(scale$tooltip)
  scale <- scale_func(guide = "guide_none", tooltip = "tooltip")
  expect_null(scale$tooltip)
  scale <- scale_func(guide = guide_none(), tooltip = "tooltip")
  expect_null(scale$tooltip)
}

# scale_interactive with guide as character, is working ----
{
  scale <- scale_func(guide = "legend", tooltip = "tooltip")
  expect_equal(scale$tooltip, "tooltip")
  scale <- scale_func(guide = "legend_interactive", tooltip = "tooltip")
  expect_equal(scale$tooltip, "tooltip")
}
# scale_interactive with guide as guide object, is working ----
{
  scale <- scale_func(guide = guide_legend(), tooltip = "tooltip")
  expect_inherits(scale$guide, c("interactive_guide", "interactive_legend"))
  scale <- scale_func(guide = guide_bins(), tooltip = "tooltip")
  expect_inherits(scale$guide, c("interactive_guide", "interactive_bins"))
  scale <- scale_func(guide = guide_colorsteps(), tooltip = "tooltip")
  expect_inherits(scale$guide, c("interactive_guide", "interactive_coloursteps"))
  scale <- scale_func(guide = guide_colourbar(), tooltip = "tooltip")
  expect_inherits(scale$guide, c("interactive_guide", "interactive_colourbar"))
}

# scale_interactive with unsupported guide, is working ----
{
  expect_warning(scale_func(guide = guide_axis(), tooltip = "tooltip"))
}

# scale_interactive with extra_interactive_params, is working ----
{
  scale <- scale_func(guide = "legend", foo = "bar", extra_interactive_params = "foo")
  expect_equal(scale$foo, "bar")
}
