# geom_bar_interactive ----
test_that("geom_bar_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_bar_interactive"))
})

test_that("geom_bar_interactive draws as geom_bar", {
  dat <- data.frame(x = c("a", "b", "b", "c", "c", "c"))
  expect_same_rects(
    ggplot(dat, aes(x)), geom_bar(), geom_bar_interactive(aes(data_id = x)),
    c("a", "b", "c")
  )
  # linejoin reaches the rectangles, in cartesian and polar coordinates
  for (coord in list(coord_cartesian(), coord_polar())) {
    p <- ggplot(dat, aes(x)) +
      geom_bar_interactive(aes(data_id = x), linejoin = "round", colour = "black", linewidth = 4) +
      coord
    nodes <- xml_find_all(dsvg_plot(p), ".//*[@data-id]")
    expect_equal(unique(xml_attr(nodes, "stroke-linejoin")), "round")
  }
})
