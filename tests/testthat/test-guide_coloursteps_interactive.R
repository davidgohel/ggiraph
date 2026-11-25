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

# the steps are a single grob ----
test_that("coloursteps bar carries the interactive attributes", {
  nodes <- coloursteps_keys(coloursteps_plot(data_id = "bar", tooltip = "my bar"))
  expect_length(nodes, 1)
  expect_equal(xml_name(nodes), "image")
  expect_equal(xml_attr(nodes, "key-id"), "bar")
  expect_equal(xml_attr(nodes, "title"), "my bar")
})

test_that("coloursteps bar gives the breaks to a function", {
  expect_no_warning(
    nodes <- coloursteps_keys(
      coloursteps_plot(data_id = function(x) paste(x, collapse = "-"))
    )
  )
  expect_equal(xml_attr(nodes, "key-id"), "10-30-50")
})

test_that("coloursteps bar warns when a function returns several values", {
  expect_warning(
    nodes <- coloursteps_keys(coloursteps_plot(data_id = function(x) paste("value", x))),
    "single element"
  )
  expect_length(nodes, 0)
})

test_that("coloursteps bar warns when given several values", {
  expect_warning(
    nodes <- coloursteps_keys(coloursteps_plot(data_id = c("a", "b", "c", "d"))),
    "single element"
  )
  expect_length(nodes, 0)
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
