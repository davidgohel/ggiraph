coloursteps_plot <- function(...) {
  dat <- data.frame(x = 1:10, y = 1:10, z = c(1:5, seq(15, 45, by = 10), 100))
  ggplot(dat, aes(x, y, colour = z)) +
    geom_point() +
    scale_colour_viridis_b_interactive(breaks = c(10, 30, 50), ...)
}

coloursteps_keys <- function(p) {
  doc <- dsvg_plot(p)
  xml_find_all(doc, "//*[@key-id]")
}

# one rectangle per class, as ggplot2 ----
test_that("coloursteps draws one rectangle per class, as ggplot2", {
  rect_sizes <- function(doc) {
    rects <- xml_find_all(doc, ".//rect")
    utils::tail(xml_attr(rects, "height"), 4)
  }
  dat <- data.frame(x = 1:10, y = 1:10, z = c(1:9, 100))
  base <- ggplot(dat, aes(x, y, colour = z)) + geom_point()
  for (even in c(TRUE, FALSE)) {
    guide <- guide_coloursteps(even.steps = even)
    expected <- rect_sizes(dsvg_plot(base + scale_colour_steps(breaks = c(2, 5, 50), guide = guide)))
    doc <- dsvg_plot(base + scale_colour_steps_interactive(breaks = c(2, 5, 50), data_id = "bar", guide = guide))
    nodes <- xml_find_all(doc, "//*[@key-id]")
    expect_equal(xml_name(nodes), rep("rect", 4), info = even)
    expect_equal(xml_attr(nodes, "height"), expected, info = even)
  }
})

test_that("coloursteps gives a single value to every class", {
  nodes <- coloursteps_keys(coloursteps_plot(data_id = "bar", tooltip = "my bar"))
  expect_length(nodes, 4)
  expect_equal(xml_attr(nodes, "key-id"), rep("bar", 4))
  expect_equal(xml_attr(nodes, "title"), rep("my bar", 4))
})

test_that("coloursteps gives each class the value of its lower bound", {
  # the function receives the limits and the breaks, as with the bins guide
  expect_no_warning(
    nodes <- coloursteps_keys(coloursteps_plot(data_id = function(x) paste0("k", x)))
  )
  expect_equal(xml_attr(nodes, "key-id"), c("k1", "k10", "k30", "k50"))
  # each class keeps its colour, also reversed
  p <- coloursteps_plot(
    data_id = function(x) paste0("k", x),
    guide = guide_coloursteps(reverse = TRUE)
  )
  reversed <- coloursteps_keys(p)
  expect_equal(
    xml_attr(reversed, "fill")[order(xml_attr(reversed, "key-id"))],
    xml_attr(nodes, "fill")[order(xml_attr(nodes, "key-id"))]
  )
})

test_that("coloursteps warns when the values do not match the breaks", {
  expect_warning(
    nodes <- coloursteps_keys(coloursteps_plot(data_id = c("a", "b"))),
    "length differs"
  )
  expect_length(nodes, 0)
})

test_that("coloursteps accepts one value per class or per break", {
  for (reverse in c(FALSE, TRUE)) {
    guide <- guide_coloursteps(reverse = reverse)
    expect_no_warning(
      nodes <- coloursteps_keys(coloursteps_plot(data_id = c("a", "b", "c", "d"), guide = guide))
    )
    expect_equal(xml_attr(nodes, "key-id"), c("a", "b", "c", "d"), info = reverse)
    nodes <- coloursteps_keys(coloursteps_plot(data_id = c("a", "b", "c", "d", "e"), guide = guide))
    expect_equal(xml_attr(nodes, "key-id"), c("a", "b", "c", "d"), info = reverse)
  }
})

test_that("coloursteps labels keep their own attributes", {
  p <- coloursteps_plot(
    data_id = "bar",
    labels = function(breaks) {
      label_interactive(as.character(breaks), data_id = paste0("lab", breaks))
    }
  )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, "//text[starts-with(@key-id, 'lab')]")
  expect_equal(xml_attr(nodes, "key-id"), c("lab10", "lab30", "lab50"))
})

test_that("coloursteps ignores even.steps = FALSE with a discrete scale, as ggplot2", {
  dat <- data.frame(x = 1:3, y = 1:3, z = cut(c(10, 30, 60), c(0, 25, 50, 100)))
  p <- ggplot(dat, aes(x, y, colour = z)) +
    geom_point() +
    scale_colour_discrete_interactive(
      data_id = "bar",
      guide = guide_coloursteps(even.steps = FALSE)
    )
  expect_no_warning(nodes <- coloursteps_keys(p))
  expect_equal(xml_attr(nodes, "key-id"), rep("bar", 3))
})
