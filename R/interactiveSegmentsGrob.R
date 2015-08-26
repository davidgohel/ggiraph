#' @title Generate interactive grob segments
#' @description This function can be used to generate interactive grob 
#' segments.
#' 
#' @inheritParams grid::segmentsGrob
#' @param tooltips tooltips associated with segments
#' @param clicks javascript action to execute when segment is clicked
#' @param id identifiers to associate with segments
#' @export 
interactiveSegmentsGrob <- function(x0=unit(0, "npc"), y0=unit(0, "npc"),
		x1=unit(1, "npc"), y1=unit(1, "npc"),
		tooltips = NULL, 
		clicks = NULL, 
		id = NULL, 
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
	grob(tooltips = tooltips, clicks = clicks, id = id, 
			x0=x0, y0=y0, x1=x1, y1=y1, arrow=arrow, name=name, gp=gp, vp=vp,
			cl="interactiveSegmentsGrob")
}

#' @export 
#' @title interactiveSegmentsGrob drawing
#' @inheritParams grid::drawDetails
drawDetails.interactiveSegmentsGrob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltips", "clicks", "id") )
	do.call( grid.segments, x[argnames] )
	
	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {

		if( !is.null( x$tooltips )){
			if( length( x$tooltips ) == 1 && length(ids)>1 )
				x$tooltips = rep(x$tooltips, length(ids) )
			if( length(ids) %% length(x$tooltips) < 1 ){
				x$tooltips = rep( x$tooltips, each = length(ids) %/% length(x$tooltips) )
			}
			send_tooltip(ids, x$tooltips)
		}
			
		if( !is.null( x$clicks )){
			if( length( x$clicks ) == 1 && length(ids)>1 )
				x$clicks = rep(x$clicks, length(ids) )
			if( length(ids) %% length(x$clicks) < 1 ){
				x$clicks = rep( x$clicks, each = length(ids) %/% length(x$clicks) )
			}
			send_click(ids, x$clicks)
		}
		if( !is.null( x$id )){
			if( length( x$id ) == 1 && length(ids)>1 )
				x$id = rep(x$id, length(ids) )
			if( length(ids) %% length(x$id) < 1 ){
				x$id = rep( x$id, each = length(ids) %/% length(x$id) )
			}
			set_data_id(ids, x$id)
		}		
	}
	invisible()
}
