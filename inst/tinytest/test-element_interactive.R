library(tinytest)
library(ggiraph)
library(ggplot2)
source("setup.R")

# element_interactive is working ----
{
  eval(test_theme_element, envir = list(name = "element_line_interactive"))
  eval(test_theme_element, envir = list(name = "element_rect_interactive"))
  eval(test_theme_element, envir = list(name = "element_text_interactive"))
}

# element_interactive is using correct ipar ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip", foo = "bar")
  args <- c(list(element_func = element_line), mapping)
  args <- c(list(extra_interactive_params = "foo"), args)
  result <- do.call(ggiraph:::element_interactive, args)
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping)
}

# label_interactive ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- c(list(label = "label"), mapping)
  result <- do.call(label_interactive, args)
  expect_inherits(result, "interactive_label", info = "inherits interactive_label")
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "interactive attributes match")
}

# label_interactive extra_interactive_params ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip", foo = "bar")
  args <- c(list(label = "label"), mapping)
  args <- c(list(extra_interactive_params = "foo"), args)
  result <- do.call(label_interactive, args)
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping)
}

# element_grob & merge_element ----
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  rect_el <- do.call(element_rect_interactive, mapping)
  t <- theme_minimal() + theme(plot.background = rect_el)
  result <- element_render(t, "plot.background")
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "element_rect_interactive mapping")
}
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  line_el <- do.call(element_line_interactive, mapping)
  t <- theme_minimal() + theme(panel.grid.major = line_el)
  result <- element_render(t, "panel.grid.major")
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "element_line_interactive mapping")
}
{
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  text_el <- do.call(element_text_interactive, mapping)
  t <- theme_minimal() + theme(legend.text = text_el)
  result <- element_render(t, "legend.text")
  result <- result$children[[1]]
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "element_text_interactive mapping")

  result <- element_render(t, "legend.text", label = label_interactive("foo"))
  result <- result$children[[1]]
  expect_equal(ip, mapping, info = "element_text_interactive mapping 2")

  result <- element_render(t, "legend.text", label = list("foo", "bar"))
  result <- result$children[[1]]
  expect_equal(ip, mapping, info = "element_text_interactive mapping 3")

  result <- element_render(t, "legend.text", label = list(label_interactive("foo")))
  result <- result$children[[1]]
  expect_equal(ip, mapping, info = "element_text_interactive mapping 4")
}

# as_interactive_element_text ----
{
  expect_inherits(ggiraph:::as_interactive_element_text("foo"), "interactive_element_text")
  expect_inherits(ggiraph:::as_interactive_element_text(element_text_interactive()), "interactive_element_text")
}
