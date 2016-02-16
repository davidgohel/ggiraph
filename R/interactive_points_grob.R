#' @title Generate interactive grob points
#' @description This function can be used to generate interactive grob
#' points.
#' @inheritParams grid::pointsGrob
#' @param tooltip tooltip associated with points
#' @param onclick javascript action to execute when point is clicked
#' @param data_id identifiers to associate with points
#' @export
interactive_points_grob <- function( x = unit(0.5, "npc"),
		y = unit(0.5, "npc"),
		tooltip = NULL,
		onclick = NULL,
		data_id = NULL,
		pch=1, size=unit(1, "char"),
		default.units="native",
		name=NULL, gp=gpar(), vp=NULL) {
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
			x = x, y = y, pch = pch, size=size,
			name=name, gp=gp, vp=vp, cl="interactive_points_grob")
}

#' @export
#' @title interactive_points_grob drawing
#' @description draw an interactive_points_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_points_grob <- function(x,recording) {
	rvg_tracer_on()
	grid.points(x = x$x, y = x$y, pch = x$pch, size = x$size, default.units = "native", gp = x$gp )
	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {
		if( !is.null( x$tooltip ))
		  set_attr( ids = as.integer( ids ), str = x$tooltip, attribute = "title" )
		if( !is.null( x$onclick ))
		  set_attr( ids = as.integer( ids ), str = x$onclick, attribute = "onclick" )
		if( !is.null( x$data_id ))
		  set_attr( ids = as.integer( ids ), str = x$data_id, attribute = "data-id" )
	}


	invisible()
}

