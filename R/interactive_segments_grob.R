#' @title Generate interactive grob segments
#' @description This function can be used to generate interactive grob
#' segments.
#'
#' @inheritParams grid::segmentsGrob
#' @param tooltip tooltip associated with segments
#' @param onclick javascript action to execute when segment is clicked
#' @param data_id identifiers to associate with segments
#' @export
interactive_segments_grob <- function(x0=unit(0, "npc"), y0=unit(0, "npc"),
		x1=unit(1, "npc"), y1=unit(1, "npc"),
		tooltip = NULL,
		onclick = NULL,
		data_id = NULL,
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
	grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
			x0=x0, y0=y0, x1=x1, y1=y1, arrow=arrow, name=name, gp=gp, vp=vp,
			cl="interactive_segments_grob")
}

#' @export
#' @title interactive_segments_grob drawing
#' @description draw an interactive_segments_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_segments_grob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltip", "onclick", "data_id") )
	do.call( grid.segments, x[argnames] )

	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {

		if( !is.null( x$tooltip )){
		  if( length( x$tooltip ) == 1 && length(ids)>1 )
		    x$tooltip = rep(x$tooltip, length(ids) )
		  if( length(ids) %% length(x$tooltip) < 1 ){
		    x$tooltip = rep( x$tooltip, each = length(ids) %/% length(x$tooltip) )
		  }
		  set_attr( ids = as.integer( ids ), str = x$tooltip, attribute = "title" )
		}

		if( !is.null( x$onclick )){
		  if( length( x$onclick ) == 1 && length(ids)>1 )
		    x$onclick = rep(x$onclick, length(ids) )
		  if( length(ids) %% length(x$onclick) < 1 ){
		    x$onclick = rep( x$onclick, each = length(ids) %/% length(x$onclick) )
		  }
		  set_attr( ids = as.integer( ids ), str = x$onclick, attribute = "onclick" )
		}
		if( !is.null( x$data_id )){
			if( length( x$data_id ) == 1 && length(ids)>1 )
				x$data_id = rep(x$data_id, length(ids) )
			if( length(ids) %% length(x$data_id) < 1 ){
				x$data_id = rep( x$data_id, each = length(ids) %/% length(x$data_id) )
			}
			set_attr( ids = ids, str = x$data_id, attribute = "data-id" )
		}
	}
	invisible()
}
