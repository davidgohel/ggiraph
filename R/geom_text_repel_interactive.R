#' @title Create interactive repulsive textual annotations
#'
#' @description
#' The geometries are based on [ggrepel::geom_text_repel()] and [ggrepel::geom_label_repel()].
#' See the documentation for those functions for more details.
#'
#' @note The `ggrepel` package is required for these geometries
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive repulsive texts to a ggplot -------
#' @example examples/geom_text_repel_interactive.R
#' @seealso [girafe()]
#' @export
geom_text_repel_interactive <- function(...) {
  if (requireNamespace("ggrepel")) {
    layerfunc <- getExportedValue("ggrepel", "geom_text_repel")
    layer_interactive(
      layerfunc,
      ...,
      interactive_geom = get_repel_geom("GeomTextRepel")
    )
  }
}

#' @rdname geom_text_repel_interactive
#' @export
geom_label_repel_interactive <- function(...) {
  if (requireNamespace("ggrepel")) {
    layerfunc <- getExportedValue("ggrepel", "geom_label_repel")
    layer_interactive(
      layerfunc,
      ...,
      interactive_geom = get_repel_geom("GeomLabelRepel")
    )
  }
}

get_repel_geom <- function(name) {
  repelgeom <- getExportedValue("ggrepel", name)
  classname <- sub("Geom", "GeomInteractive", name)
  ggproto(
    classname,
    repelgeom,
    default_aes = add_default_interactive_aes(repelgeom),
    parameters = interactive_geom_parameters,
    draw_key = interactive_geom_draw_key,
    draw_panel = function(..., .ipar = IPAR_NAMES) {
      gr <- repelgeom$draw_panel(...)
      class(gr) <- c("interactive_repeltree_grob", class(gr))
      gr$.ipar <- .ipar
      gr
    }
  )
}

#' @export
makeContent.interactive_repeltree_grob <- function(x) {
  gr <- NextMethod()
  # The returned repel gtree contains text, roundrect (if it's label) & segment grobs
  # and each one is named by a prefix and the index in the data.
  # Some rows in data might be omitted by ggrepel (due to max overlaps or empty label)
  if (inherits(gr, "gTree") && length(gr$children) > 0) {
    # get the data from the grob
    data <- gr$data
    data_attr <- get_data_attr(x)
    ipar <- get_ipar(x)
    if (is.null(data$tooltip_fill) && !is.null(data$fill)) {
      data$tooltip_fill <- data$fill
    }
    # get the grob names
    gnames <- names(gr$children)
    # process only the text & rect grobs
    gnames <- gnames[grepl("^(text|rect)repelgrob[0-9]+$", gnames)]
    for (name in gnames) {
      # the data index is appended to grob's name
      index <- as.numeric(sub("^(text|rect)repelgrob", "", name))
      # set the interactive attrs from the data
      gr$children[[name]] <-
        add_interactive_attrs(
          gr = gr$children[[name]],
          data = data[index, , drop = FALSE],
          data_attr = data_attr,
          ipar = ipar
        )
    }
  }
  gr
}
