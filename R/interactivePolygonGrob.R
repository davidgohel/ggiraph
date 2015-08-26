#' @title Generate interactive grob polygons
#' @description This function can be used to generate interactive grob 
#' polygons.
#' 
#' @inheritParams grid::polygonGrob
#' @param tooltips tooltips associated with polygons
#' @param clicks javascript action to execute when polygon is clicked
#' @param datid identifiers to associate with polygons
#' @export 
interactivePolygonGrob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltips = NULL, 
		clicks = NULL, 
		datid = NULL, 
		default.units="npc",
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltips = tooltips, clicks = clicks, datid = datid, 
			x=x, y=y, id=id, id.lengths=id.lengths,
			name=name, gp=gp, vp=vp, cl="interactivePolygonGrob")
}

#' @export 
#' @title interactivePolygonGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactivePolygonGrob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "datid") )
	do.call( grid.polygon, x[argnames] )
	
	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {
		posid = which(!duplicated(x$id))
		if( !is.null( x$tooltips ))
			send_tooltip(ids, x$tooltips[posid])
		if( !is.null( x$clicks ))
			send_click(ids, x$clicks[posid])
		if( !is.null( x$datid ))
			set_data_id(ids, x$datid)
		
	}
	
	
	invisible()
}


