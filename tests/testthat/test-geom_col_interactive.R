# geom_col_interactive ----
test_that("geom_col_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_col_interactive"))
})

test_that("geom_col_interactive draws as geom_col", {
  dat <- data.frame(x = c("a", "b", "c"), y = c(3, 5, 2))
  expect_same_rects(
    ggplot(dat, aes(x, y)), geom_col(), geom_col_interactive(aes(data_id = x)),
    c("a", "b", "c")
  )
  expect_same_rects(
    ggplot(dat, aes(y, x)), geom_col(), geom_col_interactive(aes(data_id = x)),
    c("a", "b", "c")
  )
  expect_same_rects(
    ggplot(dat, aes(x, y)),
    geom_col(linejoin = "round", colour = "black"),
    geom_col_interactive(aes(data_id = x), linejoin = "round", colour = "black"),
    c("a", "b", "c")
  )
})

test_that("geom_col_interactive passes linejoin to the rectangles", {
  dat <- data.frame(x = c("a", "b", "c"), y = c(3, 5, 2))
  for (coord in list(coord_cartesian(), coord_polar())) {
    p <- ggplot(dat, aes(x, y)) +
      geom_col_interactive(aes(data_id = x), linejoin = "round", colour = "black", linewidth = 4) +
      coord
    nodes <- xml_find_all(dsvg_plot(p), ".//*[@data-id]")
    expect_equal(unique(xml_attr(nodes, "stroke-linejoin")), "round")
  }
})
