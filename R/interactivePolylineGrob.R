#' @title Generate an Interactive Grob Path
#' @description This function can be used to generate an interactive grob 
#' path.
#' 
#' @inheritParams grid::polylineGrob
#' @param tooltips tooltips associated with polylines
#' @param clicks javascript action to execute when polyline is clicked
#' @param datid identifiers to associate with polylines
#' @export 
interactivePolylineGrob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltips = NULL, 
		clicks = NULL, 
		datid = NULL, 
		default.units="npc",
		arrow=NULL,
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltips = tooltips, clicks = clicks, datid = datid, 
			x=x, y=y, id=id, id.lengths=id.lengths,
			arrow=arrow, name=name, gp=gp, vp=vp, cl="interactivePolylineGrob")
}

#' @export 
#' @title interactivePolylineGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactivePolylineGrob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "datid") )
	do.call( grid.polyline, x[argnames] )
	
	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {

		.w = c( TRUE, x$id[-1]!=x$id[-length(x$id)] )
		if( !is.null( x$tooltips ))
			send_tooltip(ids, x$tooltips[.w])
		if( !is.null( x$clicks ))
			send_click(ids, x$clicks[.w])
		if( !is.null( x$datid ))
			set_data_id(ids, x$datid[.w])
		
	}
	
	
	invisible()
}



