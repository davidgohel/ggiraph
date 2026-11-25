outlier_ipar <- paste0("outlier.", IPAR_NAMES)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @importFrom vctrs vec_rbind
StatInteractiveBoxplot <- ggproto(
  "StatInteractiveBoxplot",
  StatBoxplot,
  default_aes = append_aes(
    StatBoxplot$default_aes,
    c(IPAR_DEFAULTS, rlang::set_names(IPAR_DEFAULTS, outlier_ipar))
  ),
  dropped_aes = c("x", "y", IPAR_NAMES, outlier_ipar),
  setup_data = function(self, data, params) {
    # the outlier.* columns keep one value per outlier, in a list; the other
    # interactive parameters are constant within a group (a list would turn
    # factors and dates into numbers)
    outlier_colnames <- intersect(colnames(data), outlier_ipar)
    if (length(outlier_colnames)) {
      for (name in outlier_colnames) {
        data[[name]] <- as.list(data[[name]])
      }
    }
    self$super()$setup_data(data, params)
  },
  # the parameters are those of StatBoxplot: compute_group() passes them on
  parameters = function(self, extra = FALSE) {
    StatBoxplot$parameters(extra = extra)
  },
  compute_group = function(data, scales, ..., flipped_aes = FALSE) {
    # compute boxplot data
    df <- StatBoxplot$compute_group(
      data,
      scales,
      ...,
      flipped_aes = flipped_aes
    )
    # add outlier aesthetics, one value per outlier; the outliers are values
    # of the flipped data. The columns are set for every group, even without
    # outliers: otherwise compute_panel() of 'ggplot2' would see them as
    # varying within groups and drop them for all groups
    values <- flip_data(data, flipped_aes)$y
    outlier_indices <- which(values %in% df$outliers[[1]])
    for (name in intersect(colnames(data), outlier_ipar)) {
      df[[name]] <- list(unlist(data[[name]][outlier_indices]))
    }
    df
  }
)

#' @title Create interactive boxplot
#'
#' @description
#' The geometry is based on [ggplot2::geom_boxplot()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @details
#' You can supply `interactive parameters` for the outlier points by prefixing them
#' with `outlier.` prefix. For example: aes(outlier.tooltip = 'bla', outlier.data_id = 'blabla').
#'
#' IMPORTANT: when supplying outlier interactive parameters,
#' the correct `group` aesthetic *must* be also supplied. Otherwise the default group calculation
#' will be incorrect, which will result in an incorrect plot.
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive boxplot -------
#' @example examples/geom_boxplot_interactive.R
#' @seealso [girafe()]
#' @importFrom rlang list2
#' @export
geom_boxplot_interactive <- function(...) {
  args <- list2(...)
  if ("extra_interactive_params" %in% names(args)) {
    args$extra_interactive_params <- c(
      args$extra_interactive_params,
      outlier_ipar
    )
  } else {
    args$extra_interactive_params <- outlier_ipar
  }
  if (!"stat" %in% names(args)) {
    args$stat <- StatInteractiveBoxplot
  }
  args$layer_func <- geom_boxplot
  do.call(layer_interactive, args)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveBoxplot <- ggproto(
  "GeomInteractiveBoxplot",
  GeomBoxplot,
  default_aes = append_aes(
    GeomBoxplot$default_aes,
    c(IPAR_DEFAULTS, rlang::set_names(IPAR_DEFAULTS, outlier_ipar))
  ),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(
    self,
    data,
    panel_params,
    coord,
    ...,
    whisker_gp = NULL,
    staple_gp = NULL,
    median_gp = NULL,
    staplewidth = 0,
    .ipar = IPAR_NAMES
  ) {
    gr <- GeomBoxplot$draw_group(
      data,
      panel_params,
      coord,
      ...,
      whisker_gp = whisker_gp,
      staple_gp = staple_gp,
      median_gp = median_gp,
      staplewidth = staplewidth
    )
    box_ipar <- setdiff(.ipar, outlier_ipar)
    # children: outliers (if any), staples (if staplewidth), whiskers, box
    n <- length(gr$children)
    i <- 1L
    if (n > 0 && inherits(gr$children[[1]], "points")) {
      gr$children[[1]] <- add_interactive_attrs(
        gr$children[[1]],
        boxplot_outlier_data(data),
        ipar = box_ipar
      )
      i <- 2L
    }
    # a group drawn without its box (outliers only)
    if (n < i + 1L) {
      return(gr)
    }
    if (staplewidth != 0) {
      gr$children[[i]] <- add_interactive_attrs(
        gr$children[[i]],
        boxplot_line_data(data, staple_gp),
        ipar = box_ipar,
        by_shape = TRUE
      )
      i <- i + 1L
    }
    gr$children[[i]] <- add_interactive_attrs(
      gr$children[[i]],
      boxplot_line_data(data, whisker_gp),
      ipar = box_ipar,
      by_shape = TRUE
    )
    gr$children[[i + 1L]] <- crossbar_add_interactive_attrs(
      gr$children[[i + 1L]],
      data,
      middle_gp = median_gp,
      ipar = box_ipar
    )
    gr
  }
)

#' Data of the outliers of a boxplot group
#' @details
#' The `outlier.*` interactive parameters of the group, one value per
#' outlier (computed by `StatInteractiveBoxplot`), named without their
#' prefix.
#' @noRd
boxplot_outlier_data <- function(data) {
  cols <- intersect(names(data), outlier_ipar)
  out <- lapply(cols, function(name) data[[name]][[1]])
  names(out) <- sub("^outlier[.]", "", cols)
  out
}

#' Data of the whiskers or staples of a boxplot group
#' @details
#' Two segments per group, with the linetype and linewidth of `gp`
#' (`whisker_gp`, `staple_gp`), without the rows removed by `GeomSegment`.
#' @noRd
boxplot_line_data <- function(data, gp = NULL) {
  lines <- vctrs::vec_rep(data, 2L)
  lines$linetype <- gp$linetype %||% lines$linetype
  lines$linewidth <- gp$linewidth %||% lines$linewidth
  segment_drawn_data(lines)
}
