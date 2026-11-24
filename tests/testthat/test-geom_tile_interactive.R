# geom_tile_interactive ----
test_that("geom_tile_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_tile_interactive"))
})

test_that("geom_tile_interactive draws as geom_tile", {
  dat <- expand.grid(x = 1:2, y = 1:2)
  dat$id <- c("a", "b", "c", "d")
  expect_same_rects(
    ggplot(dat, aes(x, y)), geom_tile(), geom_tile_interactive(aes(data_id = id)),
    c("a", "b", "c", "d")
  )
  expect_same_rects(
    ggplot(dat, aes(x, y)),
    geom_tile(width = .5, height = .5),
    geom_tile_interactive(aes(data_id = id), width = .5, height = .5),
    c("a", "b", "c", "d")
  )
})
