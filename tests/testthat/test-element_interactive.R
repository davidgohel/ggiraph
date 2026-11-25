# element_interactive is working ----
test_that("element_interactive is working", {
  eval(test_theme_element, envir = list(name = "element_line_interactive"))
  eval(test_theme_element, envir = list(name = "element_rect_interactive"))
  eval(test_theme_element, envir = list(name = "element_text_interactive"))
})

# element_interactive is using correct ipar ----
test_that("element_interactive is using correct ipar", {
  mapping <- list(data_id = "data-id", tooltip = "tooltip", foo = "bar")
  args <- c(list(element_func = element_line), mapping)
  args <- c(list(extra_interactive_params = "foo"), args)
  result <- do.call(ggiraph:::element_interactive, args)
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping)
})

# label_interactive ----
test_that("label_interactive", {
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- c(list(label = "label"), mapping)
  result <- do.call(label_interactive, args)
  expect_s3_class(result, "interactive_label")
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "interactive attributes match")
})

# label_interactive extra_interactive_params ----
test_that("label_interactive extra_interactive_params", {
  mapping <- list(data_id = "data-id", tooltip = "tooltip", foo = "bar")
  args <- c(list(label = "label"), mapping)
  args <- c(list(extra_interactive_params = "foo"), args)
  result <- do.call(label_interactive, args)
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping)
})

# element_grob & merge_element ----
test_that("element_rect_interactive keeps its interactive attributes when rendered", {
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  rect_el <- do.call(element_rect_interactive, mapping)
  t <- theme_minimal() + theme(plot.background = rect_el)
  result <- element_render(t, "plot.background")
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "element_rect_interactive mapping")
})
test_that("element_line_interactive keeps its interactive attributes when rendered", {
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  line_el <- do.call(element_line_interactive, mapping)
  t <- theme_minimal() + theme(panel.grid.major = line_el)
  result <- element_render(t, "panel.grid.major")
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "element_line_interactive mapping")
})
test_that("element_text_interactive keeps its interactive attributes when rendered", {
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  text_el <- do.call(element_text_interactive, mapping)
  t <- theme_minimal() + theme(legend.text = text_el)

  # element_render() measures the text, so it needs a device: the element is
  # rendered and drawn in dsvg; returns the interactive attributes of the
  # text grob and the <text> nodes written in the svg
  render_text <- function(...) {
    doc <- dsvg_doc({
      grid.newpage()
      result <- element_render(t, "legend.text", ...)
      grid.draw(result)
    })
    list(
      ip = ggiraph:::compact(ggiraph:::get_interactive_data(result$children[[1]])),
      texts = xml_find_all(doc, "//text")
    )
  }

  # the element attributes are set on the text grob
  out <- render_text()
  expect_equal(out$ip, mapping)

  # the attributes of an interactive label replace those of the element
  out <- render_text(label = label_interactive("foo", tooltip = "tt foo"))
  expect_equal(out$ip, list(data_id = "data-id", tooltip = "tt foo"))
  expect_length(out$texts, 1)
  expect_equal(xml_attr(out$texts, "title"), "tt foo")
  expect_equal(xml_attr(out$texts, "theme-id"), "data-id")

  # a list of labels (guide labels of continuous scales) has one set of
  # attributes per label; grid draws one text per position, so each label
  # gets its own position
  out <- render_text(
    label = list("foo", label_interactive("bar", tooltip = "tt bar")),
    x = c(.3, .7), y = c(.5, .5)
  )
  expect_equal(
    out$ip,
    list(data_id = c("data-id", "data-id"), tooltip = c("tooltip", "tt bar"))
  )
  expect_length(out$texts, 2)
  expect_equal(xml_attr(out$texts, "title"), c("tooltip", "tt bar"))
  expect_equal(xml_attr(out$texts, "theme-id"), c("data-id", "data-id"))

  # a list with a single interactive label
  out <- render_text(label = list(label_interactive("foo", tooltip = "tt foo")))
  expect_equal(out$ip, list(data_id = "data-id", tooltip = "tt foo"))
  expect_length(out$texts, 1)
  expect_equal(xml_attr(out$texts, "title"), "tt foo")
})

# as_interactive_element_text ----
test_that("as_interactive_element_text", {
  expect_s3_class(ggiraph:::as_interactive_element_text("foo"), "interactive_element_text")
  expect_s3_class(ggiraph:::as_interactive_element_text(element_text_interactive()), "interactive_element_text")
})

# merging interactive elements (theme() + theme()) ----
merged_attrs <- function(theme, name) {
  ggiraph:::compact(ggiraph:::get_interactive_data(theme[[name]]))
}

test_that("an interactive element keeps the attributes of the one it replaces", {
  th <- theme(axis.text.x = element_text_interactive(data_id = "a", tooltip = "t")) +
    theme(axis.text.x = element_text_interactive(colour = "red"))
  expect_equal(th$axis.text.x@colour, "red")
  expect_equal(merged_attrs(th, "axis.text.x"), list(data_id = "a", tooltip = "t"))

  th <- theme(panel.background = element_rect_interactive(data_id = "a")) +
    theme(panel.background = element_rect_interactive(fill = "red"))
  expect_equal(th$panel.background@fill, "red")
  expect_equal(merged_attrs(th, "panel.background"), list(data_id = "a"))
})

test_that("the attributes of the new interactive element win", {
  th <- theme(axis.text.x = element_text_interactive(data_id = "a", tooltip = "t")) +
    theme(axis.text.x = element_text_interactive(data_id = "b"))
  expect_equal(merged_attrs(th, "axis.text.x"), list(data_id = "b", tooltip = "t"))
})

test_that("an interactive element replacing a plain one keeps its attributes", {
  th <- theme(axis.text.x = element_text(colour = "red")) +
    theme(axis.text.x = element_text_interactive(data_id = "a"))
  expect_s3_class(th$axis.text.x, "interactive_element_text")
  expect_equal(th$axis.text.x@colour, "red")
  expect_equal(merged_attrs(th, "axis.text.x"), list(data_id = "a"))
})

test_that("merged interactive attributes are written in the SVG", {
  p <- ggplot(data.frame(x = c("a", "b"), y = 1:2), aes(x, y)) +
    geom_col() +
    theme(axis.text.x = element_text_interactive(data_id = "axis-x")) +
    theme(axis.text.x = element_text_interactive(colour = "red"))
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, "//text[@theme-id='axis-x']")
  expect_equal(xml_text(nodes), c("a", "b"))
})
