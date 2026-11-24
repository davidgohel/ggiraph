# geom_abline_interactive ----
test_that("geom_abline_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_abline_interactive"))
})

test_that("geom_abline_interactive draws as geom_abline", {
  # lines crossing the panel (wt from 1.5 to 5.4, mpg from 10.4 to 33.9)
  lines <- data.frame(intercept = c(37, 20, -40), slope = c(-5, 0, 20))
  for (i in seq_len(nrow(lines))) {
    expect_same_reference_line(
      geom_abline(intercept = lines$intercept[i], slope = lines$slope[i]),
      geom_abline_interactive(
        intercept = lines$intercept[i],
        slope = lines$slope[i],
        data_id = "a"
      ),
      "a"
    )
  }
})

test_that("each abline carries the attributes of its row", {
  lines <- data.frame(i = c(37, 30), s = c(-5, -3), id = c("a", "b"))
  shapes <- svg_line_shapes(
    ggplot(mtcars, aes(wt, mpg)) +
      geom_blank() +
      geom_abline_interactive(aes(intercept = i, slope = s, data_id = id), data = lines)
  )
  expect_equal(shapes$id, c("a", "b"))
})
