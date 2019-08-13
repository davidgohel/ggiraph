#' @title Generate interactive grob points
#' @description This function can be used to generate interactive grob
#' points.
#' @inheritParams grid::pointsGrob
#' @param tooltip tooltip associated with points
#' @param onclick javascript action to execute when point is clicked
#' @param data_id identifiers to associate with points
#' @param cl class to set
#' @export
interactive_points_grob <- function( x = unit(0.5, "npc"),
		y = unit(0.5, "npc"),
		tooltip = NULL,
		onclick = NULL,
		data_id = NULL,
		pch=1, size=unit(1, "char"),
		default.units="native",
		name=NULL, gp=gpar(), vp=NULL, cl = "interactive_points_grob") {
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
			x = x, y = y, pch = pch, size=size,
			name=name, gp=gp, vp=vp, cl = cl)
}

#' @export
#' @title interactive_points_grob drawing
#' @description draw an interactive_points_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_points_grob <- function(x,recording) {
  dsvg_tracer_on()
  do.call( grid.points, x[grob_argnames(x = x, grob = grid::pointsGrob)] )
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
	invisible()
}
