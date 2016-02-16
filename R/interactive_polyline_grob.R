#' @title Generate an Interactive Grob Path
#' @description This function can be used to generate an interactive grob
#' path.
#'
#' @inheritParams grid::polylineGrob
#' @param tooltip tooltip associated with polylines
#' @param onclick javascript action to execute when polyline is clicked
#' @param data_id identifiers to associate with polylines
#' @export
interactive_polyline_grob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltip = NULL,
		onclick = NULL,
		data_id = NULL,
		default.units="npc",
		arrow=NULL,
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
			x=x, y=y, id=id, id.lengths=id.lengths,
			arrow=arrow, name=name, gp=gp, vp=vp, cl="interactive_polyline_grob")
}

#' @export
#' @title interactive_polyline_grob drawing
#' @description draw an interactive_polyline_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_polyline_grob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltip", "onclick", "data_id") )
	do.call( grid.polyline, x[argnames] )

	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {

	  if( is.null(x$id) && is.null(x$id.lengths) )
	    x$id <- rep( 1, length(x$x) )

		.w = c( TRUE, x$id[-1]!=x$id[-length(x$id)] )

		if( !is.null( x$tooltip )){
		  tooltip <- x$tooltip[.w]
		  if( length( tooltip ) == 1 && length(ids)>1 ){
		    tooltip <- rep(tooltip, length(ids) )
		  }
		  if( length(ids) %% length(tooltip) < 1 &&
		      length(ids) != length(tooltip) ){
		    tooltip <- rep( tooltip, each = length(ids) %/% length(tooltip) )
		  }
		  set_attr( ids = ids, str = tooltip, attribute = "title" )
		}

		if( !is.null( x$onclick )){
		  onclick <- x$onclick[.w]
		  if( length( onclick ) == 1 && length(ids)>1 ){
		    onclick <- rep(onclick, length(ids) )
		  }
		  if( length(ids) %% length(onclick) < 1 &&
		      length(ids) != length(onclick) ){
		    onclick <- rep( onclick, each = length(ids) %/% length(onclick) )
		  }
		  set_attr( ids = ids, str = onclick, attribute = "onclick" )
		}
		if( !is.null( x$data_id )){
		  data_id <- x$data_id[.w]
		  if( length( data_id ) == 1 && length(ids)>1 ){
		    data_id <- rep(data_id, length(ids) )
		  }
		  if( length(ids) %% length(data_id) < 1 &&
		      length(ids) != length(data_id) ){
		    data_id <- rep( data_id, each = length(ids) %/% length(data_id) )
		  }
		  set_attr( ids = ids, str = data_id, attribute = "data-id" )
    }
	}

	invisible()
}



