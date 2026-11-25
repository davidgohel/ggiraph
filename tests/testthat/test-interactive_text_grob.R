result <- gdtools::sys_fonts()
skip_if(!(is.data.frame(result) && nrow(result) > 0), "no available font")

# interactive_text_grob ----
test_that("interactive_text_grob", {
  eval(test_grob, envir = list(name = "interactive_text_grob"))
})

test_that("interactive_text_grob writes its attributes in the SVG", {
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.7, length.out = 10)
    gr <- interactive_text_grob(
      paste("label", seq_len(10)),
      x = s,
      y = s,
      tooltip = as.character(s),
      info = rep("bar", 10),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), length(s))
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), length(s))
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, as.character(s))
})
# check.overlap = TRUE
test_that("check.overlap = TRUE", {
  doc <- dsvg_doc({
    gr <- interactive_text_grob(
      paste("label", seq_len(6)),
      x = c(0.1, 0.12, 0.2, 0.2, 0.5, 0.55),
      y = c(0.12, 0.11, 0.2, 0.21, 0.55, 0.55),
      check.overlap = TRUE,
      tooltip = as.character(seq_len(6)),
      info = rep("bar", 6),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), 3)
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), 3)
})
# check.overlap = TRUE and rot
test_that("check.overlap = TRUE and rot", {
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.4, length.out = 10)
    gr <- interactive_text_grob(
      paste("label", seq_len(10)),
      x = s,
      y = s,
      rot = 45,
      check.overlap = TRUE,
      tooltip = as.character(s),
      info = rep("bar", 10),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), 2)
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), 2)
})

# check.overlap = TRUE and expression
test_that("check.overlap = TRUE and expression", {
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.4, length.out = 10)
    gr <- interactive_text_grob(
      str2expression(paste("label", "^(", seq_len(10), ")")),
      x = s,
      y = s,
      check.overlap = TRUE,
      tooltip = as.character(seq_len(10)),
      info = rep("bar", 10),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), 32)
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), 32)
})

# check.overlap = TRUE and recycled coordinates
test_that("check.overlap = TRUE recycles x and y as grid does", {
  expect_no_warning(
    doc <- dsvg_doc({
      gr <- interactive_text_grob(
        c("aaaa", "bbbb", "c"),
        x = c(0.1, 0.11, 0.7),
        y = 0.5,
        check.overlap = TRUE,
        data_id = c("A", "B", "C")
      )
      grid.draw(gr)
    })
  )
  nodes <- xml_find_all(doc, ".//text")
  expect_equal(xml_text(nodes), c("aaaa", "c"))
  expect_equal(xml_attr(nodes, "data-id"), c("A", "C"))
})

# expressions of different complexity ----
test_that("each expression gives its attributes to all its elements", {
  labels <- c("a", "alpha^2 + beta[i]", "b", "frac(x, y)")
  doc <- dsvg_doc(grid.draw(interactive_text_grob(
    str2expression(labels),
    x = c(0.2, 0.4, 0.6, 0.8), y = 0.5,
    data_id = c("A", "B", "C", "D")
  )))
  nodes <- xml_find_all(doc, ".//*[@data-id]")
  # alpha, 2, +, beta, i for B; x, y and the fraction bar for D
  expect_equal(xml_attr(nodes, "data-id"), rep(c("A", "B", "C", "D"), c(1, 5, 1, 3)))
})

test_that("expressions drawn with check.overlap are those of grid, with their attributes", {
  args <- list(
    str2expression(c("alpha", "beta^2", "gamma[i]", "delta")),
    x = c(0.2, 0.21, 0.6, 0.61), y = 0.5, gp = gpar(fontsize = 30),
    check.overlap = TRUE
  )
  texts <- function(doc) xml_text(xml_find_all(doc, ".//text"))
  expected <- dsvg_doc(grid.draw(do.call(textGrob, args)))
  expect_no_warning(doc <- dsvg_doc(grid.draw(do.call(
    interactive_text_grob, c(args, list(data_id = c("A", "B", "C", "D")))
  ))))
  expect_equal(texts(doc), texts(expected))
  # grid draws alpha, beta^2 (two elements) and gamma[i] (two elements)
  expect_equal(xml_attr(xml_find_all(doc, ".//*[@data-id]"), "data-id"), c("A", "B", "B", "C", "C"))
})
