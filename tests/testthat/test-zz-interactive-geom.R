context("ggiraph interactive geoms")

# layer_interactive -------
test_that("geom_*_interactive is working", {
  e <- getNamespace("ggiraph")
  geoms <- ls(e, pattern = "^geom_[a-z]*_interactive")
  geoms <- geoms [! geoms %in% c("geom_map_interactive", "geom_sf_interactive")]
  mapping <- aes(tooltip="tooltip", data_id="data-id")
  args <- list(mapping, onclick="hello")
  for (name in geoms) {
    # print(name)
    result <- do.call(name, args)
    # is layer?
    expect_true(inherits(result, "LayerInstance"))
    # is of class GeomInteractive*?
    cl <- class(result$geom)[1]
    expect_false(is.null(e[[cl]]))
    # has that class default interactive params?
    geom_class_ipar <- ggiraph:::get_interactive_attrs(result$geom$default_aes)
    geom_class_ipar <- unclass(geom_class_ipar)
    expect_equal(geom_class_ipar, ggiraph:::IPAR_DEFAULTS)
    # has the layer the passed interactive params in aes?
    geom_aes_ipar <- ggiraph:::get_interactive_attrs(result$mapping)
    expect_equal(geom_aes_ipar, mapping)
    # has the layer the passed interactive params in aes_params?
    geom_aes_par_ipar <- ggiraph:::get_interactive_attrs(result$aes_params)
    geom_aes_par_ipar <- unclass(geom_aes_par_ipar)
    expect_equal(geom_aes_par_ipar, list(onclick="hello"))
  }
})
