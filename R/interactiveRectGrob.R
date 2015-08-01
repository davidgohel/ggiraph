#' @title Generate interactive grob rectangles
#' @description This function can be used to generate interactive grob 
#' rectangles.
#' 
#' @inheritParams grid::rectGrob
#' @param tooltips tooltips associated with rectangles
#' @param clicks javascript action to execute when rectangle is clicked
#' @param dbclicks javascript action to execute when rectangle is double clicked
#' @export 
interactiveRectGrob <- function(x=unit(0.5, "npc"), y=unit(0.5, "npc"),
		width=unit(1, "npc"), height=unit(1, "npc"),
		tooltips = NULL, 
		clicks = NULL, 
		dbclicks = NULL, 
		just="centre", hjust=NULL, vjust=NULL,
		default.units="npc",
		name=NULL, gp=gpar(), vp=NULL) {
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	if (!is.unit(width))
		width <- unit(width, default.units)
	if (!is.unit(height))
		height <- unit(height, default.units)
	grob(tooltips = tooltips, clicks = clicks, dbclicks = dbclicks, 
			x=x, y=y, width=width, height=height, just=just,
			hjust=hjust, vjust=vjust,
			name=name, gp=gp, vp=vp, cl="interactiveRectGrob")
}


#' @export 
#' @title interactiveRectGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactiveRectGrob <- function(x,recording) {
	raphael_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "dbclicks") )
	do.call( grid.rect, x[argnames] )
	
	ids = raphael_tracer_off()
	if( length( ids )==2 && all( ids > 0 ) ) {
		ids = seq(from = ids[1], to = ids[2])
		
		if( !is.null( x$tooltips ))
			raphael_tooltips(ids, x$tooltips)
		if( !is.null( x$clicks ))
			raphael_clicks(ids, x$clicks)
		if( !is.null( x$dbclicks ))
			raphael_dbclicks(ids, x$dbclicks )
	}
	invisible()
}
