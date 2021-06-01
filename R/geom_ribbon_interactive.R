#' @title Create interactive ribbons and area plots
#'
#' @description
#' The geometries are based on [geom_ribbon()] and [geom_area()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_ribbon_interactive.R
#' @seealso [girafe()]
#' @export
geom_ribbon_interactive <- function(...)
  layer_interactive(geom_ribbon, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRibbon <- ggproto(
  "GeomInteractiveRibbon",
  GeomRibbon,
  default_aes = add_default_interactive_aes(GeomRibbon),
  draw_key = function(data, params, size) {
    gr <- GeomRibbon$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_group = function(data,
                        panel_params,
                        coord,
                        na.rm = FALSE,
                        flipped_aes = FALSE,
                        outline.type = "both") {
    data <- flip_data(data, flipped_aes)
    if (na.rm)
      data <-
        data[stats::complete.cases(data[c("x", "ymin", "ymax")]), ]
    data <- data[order(data$group), ]

    # Check that aesthetics are constant
    ia <- get_interactive_attr_names(data)
    cols <- c("colour", "fill", "size", "linetype", "alpha", ia)
    aes <- unique(data[cols])
    if (nrow(aes) > 1) {
      abort("Aesthetics can not vary with a ribbon")
    }
    aes <- as.list(aes)

    # Instead of removing NA values from the data and plotting a single
    # polygon, we want to "stop" plotting the polygon whenever we're
    # missing values and "start" a new polygon as soon as we have new
    # values.  We do this by creating an id vector for polygonGrob that
    # has distinct polygon numbers for sequences of non-NA values and NA
    # for NA values in the original data.  Example: c(NA, 2, 2, 2, NA, NA,
    # 4, 4, 4, NA)
    missing_pos <-
      !stats::complete.cases(data[c("x", "ymin", "ymax")])
    ids <- cumsum(missing_pos) + 1
    ids[missing_pos] <- NA

    data <- unclass(data) #for faster indexing

    # The upper line and lower line need to processed separately (#4023)
    positions_upper <- new_data_frame(list(
      x = data$x,
      y = data$ymax,
      id = ids
    ))

    positions_lower <- new_data_frame(list(
      x = rev(data$x),
      y = rev(data$ymin),
      id = rev(ids)
    ))

    positions_upper <- flip_data(positions_upper, flipped_aes)
    positions_lower <- flip_data(positions_lower, flipped_aes)

    munched_upper <-
      coord_munch(coord, positions_upper, panel_params)
    munched_lower <-
      coord_munch(coord, positions_lower, panel_params)

    munched_poly <- rbind(munched_upper, munched_lower)

    is_full_outline <- identical(outline.type, "full")
    g_poly <- polygonGrob(
      munched_poly$x,
      munched_poly$y,
      id = munched_poly$id,
      default.units = "native",
      gp = gpar(
        fill = alpha(aes$fill, aes$alpha),
        col = if (is_full_outline)
          aes$colour
        else
          NA,
        lwd = if (is_full_outline)
          aes$size * .pt
        else
          0,
        lty = if (is_full_outline)
          aes$linetype
        else
          1
      )
    )
    g_poly <- add_interactive_attrs(g_poly, aes)

    if (is_full_outline) {
      return(ggname("geom_ribbon", g_poly))
    }

    # Increment the IDs of the lower line so that they will be drawn as separate lines
    munched_lower$id <- munched_lower$id + max(ids, na.rm = TRUE)

    munched_lines <- switch(
      outline.type,
      both = rbind(munched_upper, munched_lower),
      upper = munched_upper,
      lower = munched_lower,
      abort(paste("invalid outline.type:", outline.type))
    )
    g_lines <- polylineGrob(
      munched_lines$x,
      munched_lines$y,
      id = munched_lines$id,
      default.units = "native",
      gp = gpar(
        col = aes$colour,
        lwd = aes$size * .pt,
        lty = aes$linetype
      )
    )
    g_lines <- add_interactive_attrs(g_lines, aes)

    ggname("geom_ribbon", grobTree(g_poly, g_lines))
  }
)

#' @rdname geom_ribbon_interactive
#' @export
geom_area_interactive <- function(...)
  layer_interactive(geom_area, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveArea <- ggproto(
  "GeomInteractiveArea",
  GeomArea,
  default_aes = add_default_interactive_aes(GeomArea),
  draw_key = function(data, params, size) {
    gr <- GeomArea$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  parameters = function(extra = FALSE) {
    GeomArea$parameters(extra = extra)
  },
  draw_group = function(...) {
    GeomInteractiveRibbon$draw_group(...)
  }
)
