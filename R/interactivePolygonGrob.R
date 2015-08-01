#' @title Generate interactive grob polygons
#' @description This function can be used to generate interactive grob 
#' polygons.
#' 
#' @inheritParams grid::polygonGrob
#' @param tooltips tooltips associated with polygons
#' @param clicks javascript action to execute when polygon is clicked
#' @param dbclicks javascript action to execute when polygon is double clicked
#' @export 
interactivePolygonGrob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltips = NULL, 
		clicks = NULL, 
		dbclicks = NULL, 
		default.units="npc",
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltips = tooltips, clicks = clicks, dbclicks = dbclicks, 
			x=x, y=y, id=id, id.lengths=id.lengths,
			name=name, gp=gp, vp=vp, cl="interactivePolygonGrob")
}

#' @export 
#' @title interactivePolygonGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactivePolygonGrob <- function(x,recording) {
	raphael_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "dbclicks") )
	do.call( grid.polygon, x[argnames] )
	
	ids = raphael_tracer_off()
	if( length( ids )==2 && all( ids > 0 ) ) {
		ids = seq(from = ids[1], to = ids[2])
		posid = which(!duplicated(x$id))
		if( !is.null( x$tooltips ))
			raphael_tooltips(ids, x$tooltips[posid])
		if( !is.null( x$clicks ))
			raphael_clicks(ids, x$clicks[posid])
		if( !is.null( x$dbclicks ))
			raphael_dbclicks(ids, x$dbclicks[posid] )
	}
	
	
	invisible()
}


