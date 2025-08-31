# facet_wrap_interactive ----

#' @title Create interactive wraped facets
#' @description These facets are based on
#' [ggplot2::facet_wrap()].
#'
#' To make a facet interactive, it is mandatory to use
#' [labeller_interactive()] for argument `labeller`.
#'
#' @param ... arguments passed to base function and
#' [labeller_interactive()] for argument `labeller`.
#' @param interactive_on one of 'text' (only strip text are
#' made interactive), 'rect' (only strip rectangles are
#' made interactive) or 'both' (strip text and rectangles are
#' made interactive).
#' @return An interactive facetting object.
#' @seealso [girafe()]
#' @export
facet_wrap_interactive <- function(..., interactive_on = "text") {
  built_facet <- facet_wrap(...)
  built_facet$params$interactive_on <- match.arg(
    interactive_on,
    c("text", "rect", "both"),
    several.ok = FALSE
  )
  ggproto(
    NULL,
    FacetInteractiveWrap,
    shrink = built_facet$shrink,
    params = built_facet$params
  )
}


#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
FacetInteractiveWrap <- ggproto(
  "FacetInteractiveWrap",
  FacetWrap,
  draw_panels = function(
    self,
    panels,
    layout,
    x_scales,
    y_scales,
    ranges,
    coord,
    data,
    theme,
    params
  ) {
    panel_table <- FacetWrap$draw_panels(
      panels,
      layout,
      x_scales,
      y_scales,
      ranges,
      coord,
      data,
      theme,
      params
    )

    labels_data <- label_data_to_wrap(
      layout = layout,
      gtab_layout = panel_table$layout,
      facets = names(params$facets)
    )

    labels <- self$params$labeller(labels_data)
    labels <- lapply(labels, lapply, function(z) attr(z, "interactive"))

    index <- extract_panel_table_index(panel_table, pattern = "strip")
    panel_table_add_ipars(
      panel_table,
      index,
      labels,
      interactive_on = params$interactive_on
    )
  }
)


# facet_grid_interactive ----

#' @title Create interactive grid facets
#' @description These facets are based on
#' [ggplot2::facet_grid()].
#'
#' To make a facet interactive, it is mandatory to use
#' [labeller_interactive()] for argument `labeller`.
#'
#' @param ... arguments passed to base function and
#' [labeller_interactive()] for argument `labeller`.
#' @param interactive_on one of 'text' (only strip text are
#' made interactive), 'rect' (only strip rectangles are
#' made interactive) or 'both' (strip text and rectangles are
#' made interactive).
#' @return An interactive facetting object.
#' @seealso [girafe()]
#' @export
facet_grid_interactive <- function(..., interactive_on = "text") {
  built_facet <- facet_grid(...)
  built_facet$params$interactive_on <- match.arg(
    interactive_on,
    c("text", "rect", "both"),
    several.ok = FALSE
  )

  ggproto(
    NULL,
    FacetInteractiveGrid,
    shrink = built_facet$shrink,
    params = built_facet$params
  )
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
FacetInteractiveGrid <- ggproto(
  "FacetInteractiveGrid",
  FacetGrid,
  draw_panels = function(
    self,
    panels,
    layout,
    x_scales,
    y_scales,
    ranges,
    coord,
    data,
    theme,
    params
  ) {
    panel_table <- FacetGrid$draw_panels(
      panels,
      layout,
      x_scales,
      y_scales,
      ranges,
      coord,
      data,
      theme,
      params
    )

    labels_list <- label_data_to_grid(
      layout,
      gtab_layout = panel_table$layout,
      names(params$rows),
      names(params$cols)
    )

    # rows treatment
    labels <- self$params$labeller(labels_list$rows)
    labels <- lapply(labels, lapply, function(z) attr(z, "interactive"))
    index <- extract_panel_table_index(panel_table, pattern = "strip-[lr]")
    panel_table <- panel_table_add_ipars(
      panel_table,
      index,
      labels,
      interactive_on = params$interactive_on
    )

    # cols treatment
    labels <- self$params$labeller(labels_list$cols)
    labels <- lapply(labels, lapply, function(z) attr(z, "interactive"))
    index <- extract_panel_table_index(panel_table, pattern = "strip-[tb]")
    panel_table <- panel_table_add_ipars(
      panel_table,
      index,
      labels,
      interactive_on = params$interactive_on
    )

    panel_table
  }
)

# utils ----

extract_panel_table_index <- function(panel_table, pattern) {
  which(
    grepl(pattern, panel_table$layout$name) &
      !sapply(panel_table$grobs, inherits, "zeroGrob")
  )
}
extract_row_position <- function(gtab_layout) {
  gtab_layout_rows <- gtab_layout[grepl("strip-(l|r)", gtab_layout$name), ]
  row_sep <- unique(gsub(
    "(strip-)([lr]{1})(-[0-9]+)",
    "\\2",
    gtab_layout_rows$name
  ))
  row_sep
}

extract_col_position <- function(gtab_layout) {
  gtab_layout_rows <- gtab_layout[grepl("strip-(t|b)", gtab_layout$name), ]
  col_sep <- unique(gsub(
    "(strip-)([tb]{1})(-[0-9]+)",
    "\\2",
    gtab_layout_rows$name
  ))
  col_sep
}

label_data_to_wrap <- function(layout, gtab_layout, facets) {
  labels_data <- layout[facets] # need to be ordered as grobs

  ## ordering
  # create a fake key in gtab_layout
  gtab_layout$layout_key <- gsub("(.*?)([0-9]+-[0-9]+)", "\\2", gtab_layout$name)
  # create a fake key in layout
  layout$layout_key <- paste(layout$COL, layout$ROW, sep = "-")
  layout$layout_key <- factor(
    layout$layout_key,
    levels = gtab_layout$layout_key[grepl("strip", gtab_layout$name)]
  )
  layout <- layout[c("layout_key", names(labels_data))]

  # merge labels_data with reduced layout so that we can use layout_key for ordering
  labels_data <- merge(
    labels_data,
    layout,
    by = names(labels_data),
    all.x = TRUE,
    all.y = FALSE
  )

  # order labels_data as grobs
  labels_data <- labels_data[order(labels_data$layout_key), ]
  labels_data[["layout_key"]] <- NULL

  attr(labels_data, "facet") <- "wrap"
  labels_data
}

label_data_to_grid <- function(layout, gtab_layout, rows, cols) {
  layout_rows <- unique(layout[, rows, drop = FALSE])
  if (!extract_row_position(gtab_layout) %in% "l") {
    layout_rows <- rev(layout_rows)
  }
  attr(layout_rows, "facet") <- "grid"
  attr(layout_rows, "type") <- "rows"

  layout_cols <- unique(layout[, cols, drop = FALSE])
  attr(layout_cols, "facet") <- "grid"
  attr(layout_cols, "type") <- "cols"

  list(rows = layout_rows, cols = layout_cols)
}

panel_table_add_ipars <- function(
  panel_table,
  index,
  labels,
  interactive_on = "text"
) {
  for (grob_index in seq_along(index)) {
    panel_table_index <- index[grob_index]
    for (ilab in seq_along(labels)) {
      grob <- panel_table$grobs[[panel_table_index]]$grobs[[ilab]]
      # text grob is the second children, children is a list of 1 element
      if ("text" %in% interactive_on || "both" %in% interactive_on) {
        grob$children[[2]]$children[[1]] <-
          do_add_interactive_attrs(
            gr = grob$children[[2]]$children[[1]],
            data = labels[[ilab]][[grob_index]],
            ipar = names(labels[[ilab]][[grob_index]])
          )
      }
      if ("rect" %in% interactive_on || "both" %in% interactive_on) {
        grob$children[[1]] <-
          do_add_interactive_attrs(
            gr = grob$children[[1]],
            data = labels[[ilab]][[grob_index]],
            ipar = names(labels[[ilab]][[grob_index]])
          )
      }

      panel_table$grobs[[panel_table_index]]$grobs[[ilab]] <- grob
    }
  }
  panel_table
}
