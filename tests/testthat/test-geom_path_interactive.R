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
