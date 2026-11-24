# geom_density_interactive ----
test_that("geom_density_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_density_interactive"))
})

test_that("densities carry their attributes for every outline type", {
  dat <- data.frame(mpg = mtcars$mpg, g = factor(mtcars$am))
  expect_same_ribbons(
    ggplot(dat, aes(mpg, fill = g)),
    geom_density, geom_density_interactive, c("0", "1")
  )
})
