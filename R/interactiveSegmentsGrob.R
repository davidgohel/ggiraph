#' @title Generate interactive grob segments
#' @description This function can be used to generate interactive grob 
#' segments.
#' 
#' @inheritParams grid::rectGrob
#' @param tooltips tooltips associated with segments
#' @param clicks javascript action to execute when segment is clicked
#' @param dbclicks javascript action to execute when segment is double clicked
#' @export 
interactiveSegmentsGrob <- function(x0=unit(0, "npc"), y0=unit(0, "npc"),
		x1=unit(1, "npc"), y1=unit(1, "npc"),
		tooltips = NULL, 
		clicks = NULL, 
		dbclicks = NULL, 
		default.units="npc",
		arrow=NULL,
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x0))
		x0 <- unit(x0, default.units)
	if (!is.unit(x1))
		x1 <- unit(x1, default.units)
	if (!is.unit(y0))
		y0 <- unit(y0, default.units)
	if (!is.unit(y1))
		y1 <- unit(y1, default.units)
	grob(tooltips = tooltips, clicks = clicks, dbclicks = dbclicks, 
			x0=x0, y0=y0, x1=x1, y1=y1, arrow=arrow, name=name, gp=gp, vp=vp,
			cl="interactiveSegmentsGrob")
}

#' @export 
#' @title interactiveSegmentsGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactiveSegmentsGrob <- function(x,recording) {
	raphael_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "dbclicks") )
	do.call( grid.segments, x[argnames] )
	
	ids = raphael_tracer_off()
	if( length( ids )==2 && all( ids > 0 ) ) {
		ids = seq(from = ids[1], to = ids[2])
		
		
		if( !is.null( x$tooltips )){
			if( length( x$tooltips ) == 1 && length(ids)>1 )
				x$tooltips = rep(x$tooltips, length(ids) )
			raphael_tooltips(ids, x$tooltips)
		}
			
		if( !is.null( x$clicks )){
			if( length( x$clicks ) == 1 && length(ids)>1 )
				x$clicks = rep(x$clicks, length(ids) )
			raphael_clicks(ids, x$clicks)
		}
			
		if( !is.null( x$dbclicks )){
			if( length( x$dbclicks ) == 1 && length(ids)>1 )
				x$dbclicks = rep(x$dbclicks, length(ids) )
			raphael_dbclicks(ids, x$dbclicks )
		}
			
	}
	invisible()
}
