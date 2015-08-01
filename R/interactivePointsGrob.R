#' @title Generate interactive grob points
#' @description This function can be used to generate interactive grob 
#' points.
#' 
#' @inheritParams grid::pointsGrob
#' @param tooltips tooltips associated with points
#' @param clicks javascript action to execute when point is clicked
#' @param dbclicks javascript action to execute when point is double clicked
#' @export 
interactivePointsGrob <- function( x = unit(0.5, "npc"), 
		y = unit(0.5, "npc"), 
		tooltips = NULL, 
		clicks = NULL, 
		dbclicks = NULL, 
		pch=1, size=unit(1, "char"),
		default.units="native",
		name=NULL, gp=gpar(), vp=NULL) {
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltips = tooltips, clicks = clicks, dbclicks = dbclicks, 
			x = x, y = y, pch = pch, size=size,
			name=name, gp=gp, vp=vp, cl="interactivePointsGrob")
}

#' @export 
#' @title interactivePointsGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactivePointsGrob <- function(x,recording) {
	raphael_tracer_on()
	grid.points(x = x$x, y = x$y, pch = x$pch, size = x$size, default.units = "native", gp = x$gp )
	ids = raphael_tracer_off()

	if( length( ids )==2 && all( ids > 0 ) ) {
		ids = seq(from = ids[1], to = ids[2])
		
		if( !is.null( x$tooltips ))
			raphael_tooltips(ids, x$tooltips)
		if( !is.null( x$clicks ))
			raphael_clicks(ids, x$clicks)
		if( !is.null( x$dbclicks ))
			raphael_dbclicks(ids, x$dbclicks)
	}

	
	invisible()
}

