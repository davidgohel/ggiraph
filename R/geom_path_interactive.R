#' @title draw paths with tooltips or click actions or double click actions
#'
#' @description 
#' The path_interactive geom is used to create interactive lines, tooltips 
#' can be displayed when mouse is over lines, on click actions and double click actions can be 
#' set with javascript instructions.
#' @inheritParams geom_point_interactive
#' @param lineend Line end style (round, butt, square)
#' @param linejoin Line join style (round, mitre, bevel)
#' @param linemitre Line mitre limit (number greater than 1)
#' @param arrow Arrow specification, as created by \link[grid]{arrow}
#' @seealso \code{\link{geom_polygon_interactive}},  
#' \code{\link{geom_segment_interactive}}
#' @examples
#' # add interactive paths to a ggplot -------
#' @example examples/geom_path_interactive.R
#' @export 
#' @importFrom ggplot2 layer
geom_path_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", lineend = "butt",
		linejoin = "round", linemitre = 1, na.rm = FALSE,
		arrow = NULL, show.legend = NA, inherit.aes = TRUE, ...) {
	ggplot2::layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomPathInteractive,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			geom_params = list(
					lineend = lineend,
					linejoin = linejoin,
					linemitre = linemitre,
					arrow = arrow,
					na.rm = na.rm
			),
			params = list(...)
	)
}


#' @importFrom stats complete.cases
#' @importFrom stats ave
#' @importFrom plyr ddply
GeomPathInteractive <- ggproto("GeomPathInteractive", Geom,
		draw_groups = function(self, ...) self$draw(...),
		
		draw = function(data, scales, coordinates, arrow = NULL, lineend = "butt",
				linejoin = "round", linemitre = 1, ..., na.rm = FALSE)
		{
			if (!anyDuplicated(data$group)) {
				message("geom_path_interactive: Each group consist of only one observation. Do you need to adjust the group aesthetic?")
			}
			
			keep <- function(x) {
				# from first non-missing to last non-missing
				first <- match(FALSE, x, nomatch = 1) - 1
				last <- length(x) - match(FALSE, rev(x), nomatch = 1) + 1
				c(
						rep(FALSE, first),
						rep(TRUE, last - first),
						rep(FALSE, length(x) - last))
			}
			# Drop missing values at the start or end of a line - can't drop in the
			# middle since you expect those to be shown by a break in the line
			missing <- !stats::complete.cases(data[c("x", "y", "size", "colour",
									"linetype")])
			kept <- stats::ave(missing, data$group, FUN = keep)
			data <- data[kept, ]
			# must be sorted on group
			data <- plyr::arrange(data, group)
			
			if (!all(kept) && !na.rm) {
				warning("Removed ", sum(!kept), " rows containing missing values",
						" (geom_path_interactive).", call. = FALSE)
			}
			munched <- coord_munch(coordinates, data, scales)
			
			# Silently drop lines with less than two points, preserving order
			rows <- stats::ave(seq_len(nrow(munched)), munched$group, FUN = length)
			munched <- munched[rows >= 2, ]
			if (nrow(munched) < 2) return(zeroGrob())
			
			# Work out whether we should use lines or segments
			attr <- plyr::ddply(munched, "group", function(df) {
						data.frame(
								solid = identical(unique(df$linetype), 1),
								constant = nrow(unique(df[, c("alpha", "colour","size", "linetype")])) == 1
						)
					})
			solid_lines <- all(attr$solid)
			constant <- all(attr$constant)
			if (!solid_lines && !constant) {
				stop("geom_path: If you are using dotted or dashed lines",
						", colour, size and linetype must be constant over the line",
						call. = FALSE)
			}
			
			# Work out grouping variables for grobs
			n <- nrow(munched)
			group_diff <- munched$group[-1] != munched$group[-n]
			start <- c(TRUE, group_diff)
			end <-   c(group_diff, TRUE)
			
			if (!constant) {
				interactiveSegmentsGrob(
						munched$x[!end], munched$y[!end], munched$x[!start], munched$y[!start],
						tooltips = munched$tooltips[!end],
						clicks = munched$clicks[!end],
						datid = munched$id[!end],
						default.units = "native", arrow = arrow,
						gp = gpar(
								col = alpha(munched$colour, munched$alpha)[!end],
								fill = alpha(munched$colour, munched$alpha)[!end],
								lwd = munched$size[!end] * .pt,
								lty = munched$linetype[!end],
								lineend = lineend,
								linejoin = linejoin,
								linemitre = linemitre
						)
				)
			} else {
				id <- match(munched$group, unique(munched$group))
				interactivePolylineGrob(
						munched$x, munched$y, id = id,
						tooltips = munched$tooltips,
						clicks = munched$clicks,
						datid = munched$id,
						default.units = "native", arrow = arrow,
						gp = gpar(
								col = alpha(munched$colour, munched$alpha)[start],
								fill = alpha(munched$colour, munched$alpha)[start],
								lwd = munched$size[start] * .pt,
								lty = munched$linetype[start],
								lineend = lineend,
								linejoin = linejoin,
								linemitre = linemitre
						)
				)
			}
		},
		
		required_aes = c("x", "y"),
		
		default_aes = aes(colour = "black", size = 0.5, linetype = 1, alpha = NA),
		
		draw_key = draw_key_path
)
