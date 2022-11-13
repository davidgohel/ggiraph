#' @title Create interactive wraped facets
#' @description These facets are based on
#' [facet_wrap()].
#'
#' To make a facet interactive, it is mandatory to use
#' [labeller_interactive()] for argument `labeller`.
#'
#' @param ... arguments passed to base function and
#' [labeller_interactive()] for argument `labeller`.
#' @return An interactive facetting object.
#' @seealso [girafe()]
#' @export
facet_wrap_interactive <- function(...) {

  zzz <- facet_wrap(...)

  ggproto(NULL, FacetInteractiveWrap,
    shrink = zzz$shrink,
    params = zzz$params
  )
}


#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
FacetInteractiveWrap <- ggproto("FacetInteractiveWrap", FacetWrap,
  draw_panels = function(self, panels, layout, x_scales, y_scales, ranges, coord, data, theme, params) {

    panel_table <- FacetWrap$draw_panels(panels, layout, x_scales, y_scales, ranges, coord, data, theme, params)

    labels_df <- layout[names(params$facets)]

    labels_df <- order_labels_df(layout = layout, gtab_layout = panel_table$layout, labels_df = labels_df)

    labels <- self$params$labeller(labels_df)
    labels <- lapply(labels, lapply, function(z) attr(z, "interactive"))
    nlabels <- names(labels)

    index <- which(
      grepl("strip", panel_table$layout$name) &
        !sapply(panel_table$grobs, inherits, "zeroGrob"))

    for(grob_index in seq_along(index)) {
      panel_table_index <- index[grob_index]
      for(ilab in seq_along(nlabels)) {
        grob <- panel_table$grobs[[panel_table_index]]$grobs[[ilab]]
        # text grob is the second children, children is a list of 1 element
        grob$children[[2]]$children[[1]] <-
          do_add_interactive_attrs(
            gr = grob$children[[2]]$children[[1]],
            data = labels[[ilab]][[grob_index]],
            ipar = names(labels[[ilab]][[grob_index]]))
        panel_table$grobs[[panel_table_index]]$grobs[[ilab]] <- grob
      }
    }
    panel_table
  }
)

order_labels_df <- function(layout, gtab_layout, labels_df){
  gtab_layout$layout_key <- gsub("(.*)([0-9]+-[0-9]+)", "\\2", gtab_layout$name)
  layout$layout_key <- paste(layout$COL, layout$ROW, sep = "-")
  layout$layout_key <- factor(layout$layout_key, levels = gtab_layout$layout_key[grepl("strip", gtab_layout$name)])
  layout <- layout[c("layout_key", names(labels_df))]
  labels_df <- merge(labels_df, layout, by = names(labels_df), all.x = TRUE, all.y = FALSE)
  labels_df <- labels_df[order(labels_df$layout_key),]
  labels_df[["layout_key"]] <- NULL
  labels_df
}

extract_row_position <- function(gtab_layout) {
  gtab_layout_rows <- gtab_layout[grepl("strip-(l|r)", gtab_layout$name),]
  row_sep <- unique(gsub("(strip-)([lr]{1})(-[0-9]+)", "\\2", gtab_layout_rows$name))
  row_sep
}
extract_col_position <- function(gtab_layout) {
  gtab_layout_rows <- gtab_layout[grepl("strip-(t|b)", gtab_layout$name),]
  col_sep <- unique(gsub("(strip-)([tb]{1})(-[0-9]+)", "\\2", gtab_layout_rows$name))
  col_sep
}


layout_grid_rowscols <- function(layout, gtab_layout, rows, cols){

  row_sep <- extract_row_position(gtab_layout)
  col_sep <- extract_col_position(gtab_layout)
  layout$layout_key_col <- paste0("strip-", col_sep, "-", layout$COL)
  layout$layout_key_row <- paste0("strip-", row_sep, "-", layout$ROW)

  layout_cols <- unique(layout[, c(cols, "layout_key_col")])
  layout_rows <- unique(layout[, c(rows, "layout_key_row")])
  layout_cols$layout_key_col <- NULL
  layout_rows$layout_key_row <- NULL

  list(rows = layout_rows, cols = layout_cols)
}

#' @title Create interactive grid facets
#' @description These facets are based on
#' [facet_grid()].
#'
#' To make a facet interactive, it is mandatory to use
#' [labeller_interactive()] for argument `labeller`.
#'
#' @param ... arguments passed to base function and
#' [labeller_interactive()] for argument `labeller`.
#' @return An interactive facetting object.
#' @seealso [girafe()]
#' @export
facet_grid_interactive <- function(...) {

  zzz <- facet_grid(...)

  ggproto(NULL, FacetInteractiveGrid,
          shrink = zzz$shrink,
          params = zzz$params
  )
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
FacetInteractiveGrid <- ggproto("FacetInteractiveGrid", FacetGrid,
  draw_panels = function(self, panels, layout, x_scales, y_scales, ranges, coord, data, theme, params) {
    panel_table <- FacetGrid$draw_panels(panels, layout, x_scales, y_scales, ranges, coord, data, theme, params)

    labels_list <- layout_grid_rowscols(layout, gtab_layout = panel_table$layout, names(params$rows), names(params$cols))

    if(!extract_row_position(panel_table$layout) %in% "l" )
      labels <- self$params$labeller(rev(labels_list$rows))
    else labels <- self$params$labeller(labels_list$rows)

    labels <- lapply(labels, lapply, function(z) attr(z, "interactive"))
    nlabels <- names(labels)

    index <- which(
      grepl("strip-[lr]", panel_table$layout$name) &
        !sapply(panel_table$grobs, inherits, "zeroGrob"))

    for(grob_index in seq_along(index)) {
      panel_table_index <- index[grob_index]
      for(ilab in seq_along(nlabels)) {
        grob <- panel_table$grobs[[panel_table_index]]$grobs[[ilab]]
        # text grob is the second children, children is a list of 1 element
        grob$children[[2]]$children[[1]] <-
          do_add_interactive_attrs(
            gr = grob$children[[2]]$children[[1]],
            data = labels[[ilab]][[grob_index]],
            ipar = names(labels[[ilab]][[grob_index]]))
        panel_table$grobs[[panel_table_index]]$grobs[[ilab]] <- grob
      }
    }

    labels <- self$params$labeller(labels_list$cols)
    labels <- lapply(labels, lapply, function(z) attr(z, "interactive"))
    nlabels <- names(labels)

    index <- which(
      grepl("strip-[tb]", panel_table$layout$name) &
        !sapply(panel_table$grobs, inherits, "zeroGrob"))

    for(grob_index in seq_along(index)) {
      panel_table_index <- index[grob_index]
      for(ilab in seq_along(nlabels)) {
        grob <- panel_table$grobs[[panel_table_index]]$grobs[[ilab]]
        # text grob is the second children, children is a list of 1 element
        grob$children[[2]]$children[[1]] <-
          do_add_interactive_attrs(
            gr = grob$children[[2]]$children[[1]],
            data = labels[[ilab]][[grob_index]],
            ipar = names(labels[[ilab]][[grob_index]]))
        panel_table$grobs[[panel_table_index]]$grobs[[ilab]] <- grob
      }
    }

    panel_table
  }
)
