# geom_crossbar_interactive ----
test_that("geom_crossbar_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_crossbar_interactive"))
})

crossbar_data <- data.frame(
  trt = factor(c("a", "b", "c")),
  resp = c(1, 5, 3),
  lower = c(0.8, 4.6, 2.4),
  upper = c(1.1, 5.3, 3.3)
)

crossbar_nodes <- function(p) {
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, "//*[@data-id]")
  data.frame(
    tag = xml_name(nodes),
    id = xml_attr(nodes, "data-id"),
    title = xml_attr(nodes, "title"),
    stroke = xml_attr(nodes, "stroke")
  )
}

test_that("box and middle line carry the attributes of their row", {
  vertical <- ggplot(crossbar_data, aes(trt, resp, ymin = lower, ymax = upper)) +
    geom_crossbar_interactive(aes(data_id = trt, tooltip = paste("tt", trt)))
  horizontal <- ggplot(crossbar_data, aes(resp, trt, xmin = lower, xmax = upper)) +
    geom_crossbar_interactive(aes(data_id = trt, tooltip = paste("tt", trt)))
  for (p in list(vertical, horizontal)) {
    nodes <- crossbar_nodes(p)
    boxes <- nodes[nodes$tag == "polygon", ]
    middles <- nodes[nodes$tag == "line", ]
    expect_equal(boxes$id, c("a", "b", "c"))
    expect_equal(boxes$title, c("tt a", "tt b", "tt c"))
    expect_equal(middles$id, c("a", "b", "c"))
    expect_equal(middles$title, c("tt a", "tt b", "tt c"))
  }
})

test_that("middle and box graphical parameters keep the attributes", {
  p <- ggplot(crossbar_data, aes(trt, resp, ymin = lower, ymax = upper)) +
    geom_crossbar_interactive(
      aes(data_id = trt),
      middle.colour = "red",
      box.colour = "blue"
    )
  nodes <- crossbar_nodes(p)
  expect_equal(nodes$id[nodes$tag == "line"], c("a", "b", "c"))
  expect_equal(unique(nodes$stroke[nodes$tag == "line"]), "#FF0000")
  expect_equal(unique(nodes$stroke[nodes$tag == "polygon"]), "#0000FF")
})
