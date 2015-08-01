#' @title Generate an Interactive Grob Path
#' @description This function can be used to generate an interactive grob 
#' path.
#' 
#' @inheritParams grid::polylineGrob
#' @param tooltips tooltips associated with polylines
#' @param clicks javascript action to execute when polyline is clicked
#' @param dbclicks javascript action to execute when polyline is double clicked
#' @export 
interactivePolylineGrob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltips = NULL, 
		clicks = NULL, 
		dbclicks = NULL, 
		default.units="npc",
		arrow=NULL,
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltips = tooltips, clicks = clicks, dbclicks = dbclicks, 
			x=x, y=y, id=id, id.lengths=id.lengths,
			arrow=arrow, name=name, gp=gp, vp=vp, cl="interactivePolylineGrob")
}

#' @export 
#' @title interactivePolylineGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactivePolylineGrob <- function(x,recording) {
	raphael_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "dbclicks") )
	do.call( grid.polyline, x[argnames] )
	
	ids = raphael_tracer_off()
	if( length( ids )==2 && all( ids > 0 ) ) {
		ids = seq(from = ids[1], to = ids[2])
		.w = c( TRUE, x$id[-1]!=x$id[-length(x$id)] )
		if( !is.null( x$tooltips ))
			raphael_tooltips(ids, x$tooltips[.w])
		if( !is.null( x$clicks ))
			raphael_clicks(ids, x$clicks[.w])
		if( !is.null( x$dbclicks ))
			raphael_dbclicks(ids, x$dbclicks[.w] )
	}
	
	
	invisible()
}



