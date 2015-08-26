#' @title Generate interactive grob rectangles
#' @description This function can be used to generate interactive grob 
#' rectangles.
#' 
#' @inheritParams grid::rectGrob
#' @param tooltips tooltips associated with rectangles
#' @param clicks javascript action to execute when rectangle is clicked
#' @param id identifiers to associate with rectangles
#' @export 
interactiveRectGrob <- function(x=unit(0.5, "npc"), y=unit(0.5, "npc"),
		width=unit(1, "npc"), height=unit(1, "npc"),
		tooltips = NULL, 
		clicks = NULL, 
		id = NULL, 
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
	grob(tooltips = tooltips, clicks = clicks, id = id, 
			x=x, y=y, width=width, height=height, just=just,
			hjust=hjust, vjust=vjust,
			name=name, gp=gp, vp=vp, cl="interactiveRectGrob")
}


#' @export 
#' @title interactiveRectGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactiveRectGrob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "id") )
	do.call( grid.rect, x[argnames] )
	
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
