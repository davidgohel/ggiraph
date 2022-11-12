#' @export
facet_wrap_interactive <- function(...) {

  zzz <- facet_wrap(...)

  ggproto(NULL, FacetInteractiveWrap,
    shrink = zzz$shrink,
    params = zzz$params
  )
}


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
