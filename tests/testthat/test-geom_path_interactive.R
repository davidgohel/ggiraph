# geom_path_interactive ----
test_that("geom_path_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_path_interactive"))

  df <- economics
  doc <- dsvg_plot(
    ggplot(df, aes(unemploy / pop, psavert, colour = as.numeric(date))) +
      geom_path_interactive(aes(tooltip = "tooltip", info = "geom_line_interactive"),
        extra_interactive_params = "info"
      )
  )
  nodes <- xml_find_all(doc, ".//line[@info]")
  expect_equal(length(nodes), length(unique(df$date)) - 1, info = "all lines are drawn")
  tooltips <- sort(unique(sapply(nodes, function(node) xml_attr(node, "title"))))
  expect_equal(tooltips, "tooltip", info = "text tooltips are set")
})

# geom_line_interactive ----
test_that("geom_line_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_line_interactive"))

  df <- economics_long
  doc <- dsvg_plot(
    ggplot(df, aes(date, value01, group = variable)) +
      geom_line_interactive(aes(tooltip = variable, info = "geom_line_interactive"),
        extra_interactive_params = "info"
      )
  )
  nodes <- xml_find_all(doc, ".//polyline[@info]")
  expect_equal(length(nodes), length(unique(df$variable)), info = "all lines are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(unique(df$variable)), info = "text tooltips are set")
})

# geom_step_interactive ----
test_that("geom_step_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_step_interactive"))

  df <- economics[economics$date > as.Date("2013-01-01"), ]
  doc <- dsvg_plot(
    ggplot(df, aes(date, unemploy)) +
      geom_step_interactive(aes(tooltip = "tooltip", info = "geom_step_interactive"),
        extra_interactive_params = "info"
      )
  )
  nodes <- xml_find_all(doc, ".//polyline[@info]")
  expect_equal(length(nodes), 1, info = "all lines are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "tooltip", info = "text tooltips are set")
})
test_that("stairstep handles every direction", {
  expect_equal(nrow(ggiraph:::stairstep(list(x = 1, y = 1))), 0)
  dat <- list(x = seq_len(10), y = seq_len(10))
  expect_s3_class(ggiraph:::stairstep(dat, direction = "vh"), "data.frame")
  expect_s3_class(ggiraph:::stairstep(dat, direction = "hv"), "data.frame")
  expect_s3_class(ggiraph:::stairstep(dat, direction = "mid"), "data.frame")
  expect_error(ggiraph:::stairstep(dat, direction = "d"))
})

# lines cut by missing values, arrows, varying aesthetics ----
path_na_data <- data.frame(
  x = rep(1:6, 2), y = c(1, 2, NA, 4, 5, 6, 2, 3, 4, NA, NA, 5),
  g = rep(c("a", "b"), each = 6)
)

test_that("lines cut by missing values have the arrow heads of ggplot2", {
  shapes <- function(p) {
    doc <- dsvg_plot(p + theme_void())
    nodes <- xml_find_all(doc, ".//polyline|.//polygon")
    vapply(xml_attrs(nodes), function(v) {
      paste(v[setdiff(names(v), c("id", "data-id"))], collapse = " ")
    }, "")
  }
  base <- ggplot(path_na_data, aes(x, y, group = g))
  arrow <- arrow(ends = "both")
  expect_equal(
    suppressWarnings(shapes(base + geom_path_interactive(aes(data_id = g), arrow = arrow))),
    suppressWarnings(shapes(base + geom_path(arrow = arrow)))
  )
  doc <- suppressWarnings(dsvg_plot(base + geom_path_interactive(aes(data_id = g), arrow = arrow)))
  # a: two pieces and two heads; b: one piece (the last one has one point) and one head
  expect_equal(
    xml_attr(xml_find_all(doc, ".//polyline[@data-id]"), "data-id"),
    c("a", "a", "a", "a", "b", "b")
  )
})

test_that("segments of lines with varying aesthetics take the attributes of their line", {
  full <- stats::na.omit(path_na_data)
  doc <- dsvg_plot(ggplot(full, aes(x, y, group = g, colour = y)) +
    geom_path_interactive(aes(data_id = g)))
  expect_equal(xml_attr(xml_find_all(doc, ".//line[@data-id]"), "data-id"), rep(c("a", "b"), c(4, 3)))
  # with missing values, the segments next to them are not drawn
  doc <- suppressWarnings(dsvg_plot(ggplot(path_na_data, aes(x, y, group = g, colour = x)) +
    geom_path_interactive(aes(data_id = g))))
  expect_equal(xml_attr(xml_find_all(doc, ".//line[@data-id]"), "data-id"), rep(c("a", "b"), c(3, 2)))
})

# geom_step_interactive follows geom_step ----
test_that("steps are drawn as in ggplot2: orientation, arrows, line ends", {
  dat <- data.frame(x = c(1, 2, 4, 5, 1, 3, 4, 6), y = c(1, 3, 2, 4, 2, 1, 3, 2), g = rep(c("a", "b"), each = 4))
  shapes <- function(p) {
    doc <- dsvg_plot(p + theme_void())
    nodes <- xml_find_all(doc, ".//polyline|.//polygon")
    vapply(xml_attrs(nodes), function(v) {
      paste(v[setdiff(names(v), c("id", "data-id"))], collapse = " ")
    }, "")
  }
  base <- ggplot(dat, aes(x, y, group = g))
  for (args in list(
    list(orientation = "y"),
    list(arrow = arrow()),
    list(lineend = "round", linejoin = "mitre", linewidth = 3)
  )) {
    expect_equal(
      shapes(base + do.call(geom_step_interactive, c(list(aes(data_id = g)), args))),
      shapes(base + do.call(geom_step, args)),
      info = names(args)[1]
    )
  }
  doc <- dsvg_plot(base + geom_step_interactive(aes(data_id = g), arrow = arrow()))
  expect_equal(
    xml_attr(xml_find_all(doc, ".//polyline[@data-id]"), "data-id"),
    c("a", "a", "b", "b")
  )
})
