# geom_smooth_interactive ----
test_that("geom_smooth_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_smooth_interactive"))
})

test_that("ribbons and lines are drawn as in ggplot2, with their attributes", {
  shapes <- function(p) {
    doc <- suppressMessages(dsvg_plot(p + theme_void()))
    nodes <- xml_find_all(doc, ".//polygon|.//polyline")
    data.frame(
      tag = xml_name(nodes),
      points = xml_attr(nodes, "points"),
      id = xml_attr(nodes, "data-id")
    )
  }
  dat <- transform(mtcars, am = factor(am))
  for (orientation in c("x", "y")) {
    base <- if (orientation == "x") {
      ggplot(dat, aes(wt, mpg, colour = am))
    } else {
      ggplot(dat, aes(mpg, wt, colour = am))
    }
    for (se in c(TRUE, FALSE)) {
      expected <- shapes(base + geom_smooth(method = "lm", se = se, orientation = orientation))
      result <- shapes(
        base + geom_smooth_interactive(
          aes(data_id = am),
          method = "lm", se = se, orientation = orientation
        )
      )
      expect_equal(result$points, expected$points)
      expect_false(anyNA(result$id))
      # ribbon (polygon and its two outlines) then line, for each group
      per_group <- if (se) 4 else 1
      expect_equal(result$id, rep(c("0", "1"), each = per_group))
      if (se) {
        expect_equal(
          result$tag,
          rep(c("polygon", "polyline", "polyline", "polyline"), 2)
        )
      }
    }
  }
})

test_that("each group keeps its attributes, with or without band, in polar coordinates", {
  mt <- transform(mtcars, cyl = factor(cyl))
  base <- ggplot(mt, aes(wt, mpg, colour = cyl))
  for (se in c(TRUE, FALSE)) {
    doc <- dsvg_plot(base + coord_polar() + geom_smooth_interactive(
      aes(data_id = cyl), method = "lm", formula = y ~ x, se = se
    ))
    lines <- xml_find_all(doc, ".//polyline[@data-id]")
    expect_equal(unique(xml_attr(lines, "data-id")), c("4", "6", "8"), info = se)
    expect_length(xml_find_all(doc, ".//polygon[@data-id]"), if (se) 3 else 0)
  }
})
