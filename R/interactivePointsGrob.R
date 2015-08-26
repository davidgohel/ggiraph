#' @title Generate interactive grob points
#' @description This function can be used to generate interactive grob 
#' points.
#' 
#' @inheritParams grid::pointsGrob
#' @param tooltips tooltips associated with points
#' @param clicks javascript action to execute when point is clicked
#' @param id identifiers to associate with points
#' @export 
interactivePointsGrob <- function( x = unit(0.5, "npc"), 
		y = unit(0.5, "npc"), 
		tooltips = NULL, 
		clicks = NULL, 
		id = NULL, 
		pch=1, size=unit(1, "char"),
		default.units="native",
		name=NULL, gp=gpar(), vp=NULL) {
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltips = tooltips, clicks = clicks, id = id, 
			x = x, y = y, pch = pch, size=size,
			name=name, gp=gp, vp=vp, cl="interactivePointsGrob")
}

#' @export 
#' @title interactivePointsGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactivePointsGrob <- function(x,recording) {
	rvg_tracer_on()
	grid.points(x = x$x, y = x$y, pch = x$pch, size = x$size, default.units = "native", gp = x$gp )
	ids = rvg_tracer_off()

	if( length( ids ) > 0 ) {
		if( !is.null( x$tooltips ))
			send_tooltip(ids, x$tooltips)
		if( !is.null( x$clicks ))
			send_click(ids, x$clicks)
		if( !is.null( x$id ))
			set_data_id(ids, x$id)
	}

	
	invisible()
}

