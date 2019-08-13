GeomInteractiveCrossbar <- ggproto("GeomInteractiveCrossbar", Geom,
  setup_data = function(data, params) {
    GeomErrorbar$setup_data(data, params)
  },

  default_aes = aes(colour = "black", fill = NA, size = 0.5, linetype = 1,
                    alpha = NA, tooltip = NULL, onclick = NULL, data_id = NULL),

  required_aes = c("x", "y", "ymin", "ymax"),

  draw_key = draw_key_crossbar,

  draw_panel = function(data, panel_scales, coord, fatten = 2.5, width = NULL) {
    middle <- transform(data, x = xmin, xend = xmax, yend = y, size = size * fatten, alpha = NA)

      has_notch <- !is.null(data$ynotchlower) && !is.null(data$ynotchupper) &&
      !is.na(data$ynotchlower) && !is.na(data$ynotchupper)

    if (has_notch) {
      if (data$ynotchlower < data$ymin  ||  data$ynotchupper > data$ymax)
        message("notch went outside hinges. Try setting notch=FALSE.")

      notchindent <- (1 - data$notchwidth) * (data$xmax - data$xmin) / 2

      middle$x <- middle$x + notchindent
      middle$xend <- middle$xend - notchindent
      box <- data.frame(
        x = c(
          data$xmin, data$xmin, data$xmin + notchindent, data$xmin, data$xmin,
          data$xmax, data$xmax, data$xmax - notchindent, data$xmax, data$xmax,
          data$xmin
        ),
        y = c(
          data$ymax, data$ynotchupper, data$y, data$ynotchlower, data$ymin,
          data$ymin, data$ynotchlower, data$y, data$ynotchupper, data$ymax,
          data$ymax
        ),
        alpha = data$alpha,
        colour = data$colour,
        size = data$size,
        linetype = data$linetype, fill = data$fill,
        group = seq_len(nrow(data)),
        stringsAsFactors = FALSE
      )
    } else {
      # No notch
      box <- data.frame(
        x = c(data$xmin, data$xmin, data$xmax, data$xmax, data$xmin),
        y = c(data$ymax, data$ymin, data$ymin, data$ymax, data$ymax),
        alpha = data$alpha,
        colour = data$colour,
        size = data$size,
        linetype = data$linetype,
        fill = data$fill,
        group = seq_len(nrow(data)), # each bar forms it's own group
        stringsAsFactors = FALSE
      )
    }

    if( !is.null(data$tooltip) )
      box$tooltip <- as.character(data$tooltip)
    if( !is.null(data$onclick) )
      box$onclick <- as.character(data$onclick)
    if( !is.null(data$data_id) )
      box$data_id <- as.character(data$data_id)


      setGrobName("geom_crossbar", gTree(children = gList(
      GeomInteractivePolygon$draw_panel(box, panel_scales, coord),
      GeomInteractiveSegment$draw_panel(middle, panel_scales, coord)
    )))
  }
)
