#' @title Generate interactive grob text
#' @description This function can be used to generate interactive grob
#' text.
#'
#' @inheritParams grid::textGrob
#' @param tooltip tooltip associated with rectangles
#' @param onclick javascript action to execute when rectangle is clicked
#' @param data_id identifiers to associate with rectangles
#' @export
interactive_text_grob <- function(label, x=unit(0.5, "npc"), y=unit(0.5, "npc"),
                                tooltip = NULL,
                                onclick = NULL,
                                data_id = NULL,
                                just="centre", hjust=NULL, vjust=NULL,
                                rot=0, check.overlap=FALSE,
                                default.units="npc",
                                name=NULL, gp=gpar(), vp=NULL) {
  if (!is.unit(x))
    x <- unit(x, default.units)
  if (!is.unit(y))
    y <- unit(y, default.units)
  grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
       label=label, x=x, y=y, just=just, hjust=hjust, vjust=vjust,
       rot=rot, check.overlap=check.overlap,
       name=name, gp=gp, vp=vp, cl="interactive_text_grob")
}


#' @export
#' @title interactive_text_grob drawing
#' @description draw an interactive_text_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_text_grob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltip", "onclick", "data_id") )
	do.call( grid.text, x[argnames] )

	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {
	  if( !is.null( x$tooltip ))
	    set_attr( ids = as.integer( ids ), str = x$tooltip, attribute = "title" )
	  if( !is.null( x$onclick ))
	    set_attr( ids = as.integer( ids ), str = x$onclick, attribute = "onclick" )
	  if( !is.null( x$data_id ))
	    set_attr( ids = as.integer( ids ), str = x$data_id, attribute = "data-id" )
	}
	invisible()
}
