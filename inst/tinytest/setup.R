library(tinytest)
library(ggiraph)
library(xml2)

# calls dsvg with some predefined args and returns an xml doc
dsvg_doc <- function(expr,
                     ...,
                     file = tempfile(fileext = ".svg"),
                     bg = "transparent",
                     standalone = TRUE,
                     srip_ns = TRUE,
                     canvas_id = "svgid",
                     remove_file = TRUE) {
  env <- parent.frame()
  tryCatch(
    {
      devlength <- length(dev.list())
      tryCatch(
        {
          dsvg(...,
            file = file, bg = bg,
            standalone = standalone, canvas_id = canvas_id
          )
          eval(expr, envir = env)
        },
        finally = {
          if (length(dev.list()) > devlength) {
            dev.off()
          }
        }
      )
      doc <- xml2::read_xml(file)
      if (srip_ns) {
        doc <- xml_ns_strip(doc)
      }
      doc
    },
    finally = {
      if (remove_file) {
        unlink(file)
      }
    }
  )
}

dsvg_plot <- function(p, ...) {
  dsvg_doc(
    {
      print(p)
    },
    ...
  )
}

nse <- getNamespace("ggiraph")

test_geom_layer <- expression({
  mapping <- aes(tooltip = "tooltip", data_id = "data-id")
  args <- list(mapping, onclick = "hello")
  if (name == "geom_map_interactive") {
    loadNamespace("maps")
    args$map <- map_data("state")
  }
  result <- do.call(name, args)
  if (is.list(result)) {
    result <- result[[1]]
  }
  # is layer?
  expect_inherits(result, "LayerInstance", info = name)
  # is of class GeomInteractive*?
  cl <- class(result$geom)[1]
  if (!endsWith(cl, "Repel")) {
    expect_false(is.null(nse[[cl]]), info = cl)
  }
  # has that class default interactive params?
  geom_class_ipar <- unclass(ggiraph:::get_interactive_attrs(result$geom$default_aes))
  expect_equal(geom_class_ipar, ggiraph:::IPAR_DEFAULTS, info = name)
  # has the layer the passed interactive params in aes?
  geom_aes_ipar <- unclass(ggiraph:::get_interactive_attrs(result$mapping))
  expect_equal(geom_aes_ipar, unclass(mapping), info = name)
  # has the layer the passed interactive params in aes_params?
  geom_aes_par_ipar <- unclass(ggiraph:::get_interactive_attrs(result$aes_params))
  expect_equal(geom_aes_par_ipar, list(onclick = "hello"), info = name)
  # has the layer geom params the .ipar element?
  expect_identical(result$geom_params$.ipar, ggiraph:::IPAR_NAMES)
  # test extra_interactive_params
  args[[1]] <- aes(foo = "bar")
  args$extra_interactive_params <- "foo"
  result <- do.call(name, args)
  if (is.list(result)) {
    result <- result[[1]]
  }
  expect_identical(result$geom_params$.ipar, c(ggiraph:::IPAR_NAMES, "foo"))
  geom_mapping <- unclass(result$mapping)
  expect_identical(geom_mapping$foo, "bar", info = name)
})

test_annot_layer <- expression({
  mapping <- list(tooltip = "tooltip", data_id = "data-id", onclick = "hello")
  args <- mapping
  if (name == "annotate_interactive") {
    args <- c(list(geom = "point", x = 1, y = 2), args)
  } else if (name == "annotation_raster_interactive") {
    args$raster <- matrix(hcl(seq(0, 360, length.out = 50 * 50), 80, 70), nrow = 50)
    args <- c(list(xmin = 15, xmax = 20, ymin = 3, ymax = 4), args)
  }
  result <- do.call(name, args)
  # is layer?
  expect_inherits(result, "LayerInstance", info = name)
  # is of class GeomInteractive*?
  cl <- class(result$geom)[1]
  expect_false(is.null(nse[[cl]]), info = cl)
  # has that class default interactive params?
  geom_class_ipar <- unclass(ggiraph:::get_interactive_attrs(result$geom$default_aes))
  expect_equal(geom_class_ipar, ggiraph:::IPAR_DEFAULTS, info = name)
  # has the layer the passed interactive params in aes_params?
  geom_aes_par_ipar <- unclass(ggiraph:::get_interactive_attrs(result$aes_params))
  expect_equal(geom_aes_par_ipar, mapping, info = name)
  # has the layer geom params the .ipar element?
  expect_identical(result$geom_params$.ipar, ggiraph:::IPAR_NAMES)
  # test extra_interactive_params
  args$foo <- "bar"
  args$extra_interactive_params <- "foo"
  result <- do.call(name, args)
  expect_identical(result$geom_params$.ipar, c(ggiraph:::IPAR_NAMES, "foo"))
  geom_mapping <- unclass(result$aes_params)
  expect_identical(geom_mapping$foo, "bar", info = name)
})

test_grob <- expression({
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- c(list(x = 1, y = 1), mapping)
  if (name == "interactive_raster_grob") {
    args$image <- matrix(hcl(0, 80, seq(50, 80, 10)), nrow = 4, ncol = 5)
  } else if (name == "interactive_segments_grob") {
    args$x <- NULL
    args$y <- NULL
    args$x0 <- 0
    args$y0 <- 0
    args$x1 <- 1
    args$y1 <- 1
  } else if (name == "interactive_curve_grob") {
    args$x <- NULL
    args$y <- NULL
    args$x1 <- 0
    args$y1 <- 0
    args$x2 <- 1
    args$y2 <- 1
  } else if (name == "interactive_text_grob") {
    args$label <- "label"
  }
  result <- do.call(name, args)
  # is grob?
  expect_inherits(result, "grob", info = "result inherits grob")
  # is interactive grob?
  expect_inherits(result, name, info = "result inherits interactive grob")
  # ipar matching
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "interactive attributes match")
})

test_guide <- expression({
  result <- do.call(name, list())
  # is guide?
  expect_inherits(result, "guide", info = "result inherits guide")
  # is interactive_guide?
  expect_inherits(result, "interactive_guide", info = "result inherits interactive_guide")
})

test_scale <- expression({
  args <- list(data_id = "data-id", tooltip = "tooltip")
  sargs <- args
  if (grepl("_(gradientn|stepsn)_", name)) {
    sargs$colors <- terrain.colors(10, 1)
  } else if (name == "scale_discrete_manual_interactive") {
    sargs$aesthetics <- c("colour", "fill")
  }
  result <- suppressWarnings(do.call(name, sargs))
  # is guide?
  expect_inherits(result, "Scale", info = "result inherits Scale")
  # is interactive guide?
  expect_true(grepl("_interactive", result$guide), info = "result has interactive guide")
  # ipar matching
  scale_ipar <- ggiraph:::compact(ggiraph:::get_interactive_attrs(result))
  expect_equal(scale_ipar, args, info = "interactive attributes match")
})

test_theme_element <- expression({
  mapping <- list(data_id = "data-id", tooltip = "tooltip")
  args <- mapping
  result <- do.call(name, args)
  # is element?
  expect_inherits(result, "element", info = "result inherits element")
  # is interactive element?
  expect_inherits(result, "interactive_element", info = "result inherits interactive_element")
  expect_true(any(grepl("^interactive_", class(result))), info = "result inherits interactive element class")
  # ipar matching
  ip <- ggiraph:::compact(ggiraph:::get_interactive_data(result))
  expect_equal(ip, mapping, info = "interactive attributes match")
})
