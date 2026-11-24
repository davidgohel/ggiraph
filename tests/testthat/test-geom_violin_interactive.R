# geom_violin_interactive ----
test_that("geom_violin_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_violin_interactive"))
})

violin_nodes <- function(p) {
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, "//*[@data-id]")
  data.frame(
    tag = xml_name(nodes),
    id = xml_attr(nodes, "data-id"),
    title = xml_attr(nodes, "title")
  )
}

test_that("each violin carries its own attributes", {
  p <- ggplot(mtcars, aes(factor(cyl), mpg)) +
    geom_violin_interactive(aes(data_id = factor(cyl), tooltip = cyl))
  nodes <- violin_nodes(p)
  expect_equal(nodes$tag, rep("polygon", 3))
  expect_equal(nodes$id, c("4", "6", "8"))
  expect_equal(nodes$title, c("4", "6", "8"))
})

test_that("quantile lines carry the attributes of their violin", {
  vertical <- ggplot(mtcars, aes(factor(cyl), mpg)) +
    geom_violin_interactive(
      aes(data_id = factor(cyl), tooltip = cyl),
      quantile.linetype = 1
    )
  horizontal <- ggplot(mtcars, aes(mpg, factor(cyl))) +
    geom_violin_interactive(
      aes(data_id = factor(cyl), tooltip = cyl),
      quantile.linetype = 1
    )
  for (p in list(vertical, horizontal)) {
    nodes <- violin_nodes(p)
    polygons <- nodes[nodes$tag == "polygon", ]
    lines <- nodes[nodes$tag == "polyline", ]
    expect_equal(polygons$id, c("4", "6", "8"))
    # 3 quantiles (default) per violin
    expect_equal(lines$id, rep(c("4", "6", "8"), each = 3))
    expect_equal(lines$title, lines$id)
  }
})

test_that("quantile lines follow the quantiles argument", {
  p <- ggplot(mtcars, aes(factor(cyl), mpg)) +
    geom_violin_interactive(
      aes(data_id = factor(cyl)),
      quantiles = c(.1, .9),
      quantile.linetype = 2
    )
  nodes <- violin_nodes(p)
  lines <- nodes[nodes$tag == "polyline", ]
  expect_equal(lines$id, rep(c("4", "6", "8"), each = 2))
})
