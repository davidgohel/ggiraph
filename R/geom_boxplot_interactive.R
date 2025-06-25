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
  compute_panel = function(self, data, scales, ...) {
    if (empty(data)) {
      return(data_frame0())
    }

    groups <- split(data, data$group)
    stats <- lapply(groups, function(group) {
      self$compute_group(data = group, scales = scales, ...)
    })

    # Record columns that are not constant within groups. We will drop them later.
    non_constant_columns <- character(0)

    stats <- mapply(
      function(new, old) {
        # In this function,
        #
        #   - `new` is the computed result. All the variables will be picked.
        #   - `old` is the original data. There are 3 types of variables:
        #     1) If the variable is already included in `new`, it's ignored
        #        because the values of `new` will be used.
        #     2) If the variable is not included in `new` and the value is
        #        constant within the group, it will be picked.
        #     3) If the variable is not included in `new` and the value is not
        #        constant within the group, it will be dropped. We need to record
        #        the dropped columns to drop it consistently later.
        if (empty(new)) {
          return(data_frame0())
        }

        # First, filter out the columns already included `new` (type 1).
        old <- old[, !(names(old) %in% names(new)), drop = FALSE]

        # Then, check whether the rest of the columns have constant values (type 2)
        # or not (type 3).
        non_constant <- vapply(
          old,
          function(x) length(unique0(x)) > 1,
          logical(1L)
        )

        # Record the non-constant columns.
        non_constant_columns <<- c(
          non_constant_columns,
          names(old)[non_constant]
        )

        vec_cbind(
          new,
          # Note that, while the non-constant columns should be dropped, we don't
          # do this here because it can be filled by vec_rbind() later if either
          # one of the group has a constant value (see #4394 for the details).
          old[rep(1, nrow(new)), , drop = FALSE]
        )
      },
      stats,
      groups,
      SIMPLIFY = FALSE
    )

    non_constant_columns <- unique0(non_constant_columns)

    # We are going to drop columns that are not constant within groups and not
    # carried over/recreated by the stat. This can produce unexpected results,
    # and hence we warn about it (variables in dropped_aes are expected so
    # ignored here).
    dropped <- non_constant_columns[!non_constant_columns %in% self$dropped_aes]
    if (length(dropped) > 0) {
      dropped_msg <- paste0(dropped, sep = ', ')
      abort(c(
        paste0(
          "The following aesthetics were dropped during statistical transformation: ",
          dropped_msg
        ),
        "i" = "This can happen when ggplot fails to infer the correct grouping structure in the data.",
        "i" = "Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor?"
      ))
    }

    # Finally, combine the results and drop columns that are not constant.
    data_new <- vec_rbind(!!!stats)
    non_constant_columns <- setdiff(
      non_constant_columns,
      c(IPAR_NAMES, outlier_ipar)
    )
    data_new[, !names(data_new) %in% non_constant_columns, drop = FALSE]
  },
  setup_data = function(data, params) {
    outlier_colnames <- intersect(colnames(data), c(IPAR_NAMES, outlier_ipar))
    if (length(outlier_colnames)) {
      for (name in outlier_colnames) {
        data[[name]] <- as.list(data[[name]])
      }
    }
    data
  },
  compute_group = function(
    data,
    scales,
    width = NULL,
    na.rm = FALSE,
    coef = 1.5,
    flipped_aes = FALSE
  ) {
    # compute boxplot data
    df <- StatBoxplot$compute_group(
      data,
      scales,
      width = width,
      na.rm = na.rm,
      coef = coef,
      flipped_aes = flipped_aes
    )
    # add outlier aesthetics
    if (length(df$outliers[[1]])) {
      outlier_indices <- which(data$y %in% df$outliers[[1]])
      outlier_colnames <- intersect(colnames(data), outlier_ipar)
      if (length(outlier_colnames)) {
        for (name in outlier_colnames) {
          df[[name]] <- list(unlist(data[[name]][outlier_indices]))
        }
      }
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
    lineend = "butt",
    linejoin = "mitre",
    fatten = 2,
    outlier_gp = NULL,
    whisker_gp = NULL,
    staple_gp = NULL,
    median_gp = NULL,
    box_gp = NULL,
    notch = FALSE,
    notchwidth = 0.5,
    staplewidth = 0,
    varwidth = FALSE,
    flipped_aes = FALSE,
    .ipar = IPAR_NAMES
  ) {
    # data <- fix_linewidth(data, snake_class(self))
    data <- flip_data(data, flipped_aes)
    # this may occur when using geom_boxplot(stat = "identity")
    if (nrow(data) != 1) {
      cli::cli_abort(c(
        "Can only draw one boxplot per group.",
        "i" = "Did you forget {.code aes(group = ...)}?"
      ))
    }

    common <- list(fill = fill_alpha(data$fill, data$alpha), group = data$group)
    .ipar <- setdiff(.ipar, outlier_ipar)
    common <- copy_interactive_attrs(data, common, ipar = .ipar)

    whiskers <- data_frame0(
      x = c(data$x, data$x),
      xend = c(data$x, data$x),
      y = c(data$upper, data$lower),
      yend = c(data$ymax, data$ymin),
      colour = rep(whisker_gp$colour %||% data$colour, 2),
      linetype = rep(whisker_gp$linetype %||% data$linetype, 2),
      linewidth = rep(whisker_gp$linewidth %||% data$linewidth, 2),
      alpha = c(NA_real_, NA_real_),
      !!!common,
      .size = 2
    )
    whiskers <- flip_data(whiskers, flipped_aes)

    box <- transform(
      data,
      y = middle,
      ymax = upper,
      ymin = lower,
      ynotchlower = ifelse(notch, notchlower, NA),
      ynotchupper = ifelse(notch, notchupper, NA),
      notchwidth = notchwidth
    )
    box <- flip_data(box, flipped_aes)

    if (!is.null(data$outliers) && length(data$outliers[[1]]) >= 1) {
      outliers <- data_frame0(
        y = data$outliers[[1]],
        x = data$x[1],
        colour = outlier_gp$colour %||% data$colour[1],
        fill = outlier_gp$fill %||% data$fill[1],
        shape = outlier_gp$shape %||% data$shape[1] %||% 19,
        size = outlier_gp$size %||% data$size[1] %||% 1.5,
        stroke = outlier_gp$stroke %||% data$stroke[1] %||% 0.5,
        fill = NA,
        alpha = outlier_gp$alpha %||% data$alpha[1],
        .size = length(data$outliers[[1]])
      )

      outlier_colnames <- intersect(colnames(data), outlier_ipar)
      if (length(outlier_colnames)) {
        for (name in outlier_colnames) {
          unprefixed_name <- sub("outlier.", "", name)
          outliers[[unprefixed_name]] <- data[[name]][[1]]
        }
      }
      outliers <- flip_data(outliers, flipped_aes)

      outliers_grob <- GeomInteractivePoint$draw_panel(
        outliers,
        panel_params,
        coord,
        .ipar = .ipar
      )
    } else {
      outliers_grob <- NULL
    }

    if (staplewidth != 0) {
      staples <- data_frame0(
        x = rep((data$xmin - data$x) * staplewidth + data$x, 2),
        xend = rep((data$xmax - data$x) * staplewidth + data$x, 2),
        y = c(data$ymax, data$ymin),
        yend = c(data$ymax, data$ymin),
        linetype = rep(staple_gp$linetype %||% data$linetype, 2),
        linewidth = rep(staple_gp$linewidth %||% data$linewidth, 2),
        colour = rep(staple_gp$colour %||% data$colour, 2),
        alpha = c(NA_real_, NA_real_),
        !!!common,
        .size = 2
      )
      staples <- flip_data(staples, flipped_aes)
      staple_grob <- GeomInteractiveSegment$draw_panel(
        staples,
        panel_params,
        coord,
        lineend = lineend,
        .ipar = .ipar
      )
    } else {
      staple_grob <- NULL
    }

    ggname(
      "geom_boxplot_interactive",
      grobTree(
        outliers_grob,
        staple_grob,
        GeomInteractiveSegment$draw_panel(
          whiskers,
          panel_params,
          coord,
          lineend = lineend,
          .ipar = .ipar
        ),
        GeomInteractiveCrossbar$draw_panel(
          box,
          fatten = fatten,
          panel_params,
          coord,
          lineend = lineend,
          linejoin = linejoin,
          flipped_aes = flipped_aes,
          middle_gp = median_gp,
          box_gp = box_gp,
          .ipar = .ipar
        )
      )
    )
  }
  # draw_group = function(
  #   data,
  #   panel_params,
  #   coord,
  #   lineend = "butt",
  #   linejoin = "mitre",
  #   fatten = 2,
  #   outlier.colour = NULL,
  #   outlier.fill = NULL,
  #   outlier.shape = 19,
  #   outlier.size = 1.5,
  #   outlier.stroke = 0.5,
  #   outlier.alpha = NULL,
  #   notch = FALSE,
  #   notchwidth = 0.5,
  #   staplewidth = 0,
  #   varwidth = FALSE,
  #   flipped_aes = FALSE,
  #   .ipar = IPAR_NAMES
  # ) {
  #   data <- flip_data(data, flipped_aes)
  #   # this may occur when using geom_boxplot(stat = "identity")
  #   if (nrow(data) != 1) {
  #     abort(
  #       "Can't draw more than one boxplot per group. Did you forget aes(group = ...)?"
  #     )
  #   }
  #
  #   common <- list(
  #     colour = data$colour,
  #     linewidth = data$linewidth,
  #     linetype = data$linetype,
  #     fill = alpha(data$fill, data$alpha),
  #     group = data$group
  #   )
  #
  #   .ipar <- setdiff(.ipar, outlier_ipar)
  #   common <- copy_interactive_attrs(data, common, ipar = .ipar)
  #
  #   whiskers <- data_frame0(
  #     x = c(data$x, data$x),
  #     xend = c(data$x, data$x),
  #     y = c(data$upper, data$lower),
  #     yend = c(data$ymax, data$ymin),
  #     alpha = c(NA_real_, NA_real_),
  #     !!!common,
  #     .size = 2
  #   )
  #   whiskers <- flip_data(whiskers, flipped_aes)
  #
  #   box <- data_frame0(
  #     xmin = data$xmin,
  #     xmax = data$xmax,
  #     ymin = data$lower,
  #     y = data$middle,
  #     ymax = data$upper,
  #     ynotchlower = ifelse(notch, data$notchlower, NA),
  #     ynotchupper = ifelse(notch, data$notchupper, NA),
  #     notchwidth = notchwidth,
  #     alpha = data$alpha,
  #     !!!common
  #   )
  #   box <- flip_data(box, flipped_aes)
  #
  #   if (
  #     !is.null(data$outliers) &&
  #       length(data$outliers[[1]] >= 1)
  #   ) {
  #     outliers <- data_frame0(
  #       y = data$outliers[[1]],
  #       x = data$x[1],
  #       colour = outlier.colour %||% data$colour[1],
  #       fill = outlier.fill %||% data$fill[1],
  #       shape = outlier.shape %||% data$shape[1],
  #       size = outlier.size %||% data$linewidth[1],
  #       stroke = outlier.stroke %||% data$stroke[1],
  #       fill = NA,
  #       alpha = outlier.alpha %||% data$alpha[1],
  #       .size = length(data$outliers[[1]])
  #     )
  #     outlier_colnames <- intersect(colnames(data), outlier_ipar)
  #     if (length(outlier_colnames)) {
  #       for (name in outlier_colnames) {
  #         unprefixed_name <- sub("outlier.", "", name)
  #         outliers[[unprefixed_name]] <- data[[name]][[1]]
  #       }
  #     }
  #     outliers <- flip_data(outliers, flipped_aes)
  #     outliers_grob <-
  #       GeomInteractivePoint$draw_panel(
  #         outliers,
  #         panel_params,
  #         coord,
  #         .ipar = .ipar
  #       )
  #   } else {
  #     outliers_grob <- NULL
  #   }
  #
  #   if (staplewidth != 0) {
  #     staples <- data_frame0(
  #       x = rep((data$xmin - data$x) * staplewidth + data$x, 2),
  #       xend = rep((data$xmax - data$x) * staplewidth + data$x, 2),
  #       y = c(data$ymax, data$ymin),
  #       yend = c(data$ymax, data$ymin),
  #       alpha = c(NA_real_, NA_real_),
  #       !!!common,
  #       .size = 2
  #     )
  #     staples <- flip_data(staples, flipped_aes)
  #     staple_grob <- GeomInteractiveSegment$draw_panel(
  #       staples,
  #       panel_params,
  #       coord,
  #       lineend = lineend,
  #       .ipar = .ipar
  #     )
  #   } else {
  #     staple_grob <- NULL
  #   }
  #
  #   ggname(
  #     "geom_boxplot_interactive",
  #     grobTree(
  #       outliers_grob,
  #       staple_grob,
  #       GeomInteractiveSegment$draw_panel(
  #         whiskers,
  #         panel_params,
  #         coord,
  #         lineend = lineend,
  #         .ipar = .ipar
  #       ),
  #       GeomInteractiveCrossbar$draw_panel(
  #         box,
  #         fatten = fatten,
  #         panel_params,
  #         coord,
  #         lineend = lineend,
  #         linejoin = linejoin,
  #         flipped_aes = flipped_aes,
  #         .ipar = .ipar
  #       )
  #     )
  #   )
  # }
)
