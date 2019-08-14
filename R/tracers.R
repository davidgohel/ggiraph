#' @import graphics
#' @importFrom grDevices dev.cur dev.list

#' @title trace on id colection
#'
#' @description Start collecting id of an dsvg device.
#' @noRd
dsvg_tracer_on <- function(){

  dl <- dev.list()
  if( length( dl ) < 1 )
    stop("cannot find any open graphical device")
  dev_num <- as.integer(dev.cur()-1L)
  if( .Device == "dsvg_device" ) set_tracer_on(dn = dev_num)
  invisible()
}

#' @title trace off id colection
#'
#' @description get collected id of an dsvg device and
#' stop collecting.
#' @return graphical elements id as integer values.
#' @noRd
dsvg_tracer_off <- function(){

  dl <- dev.list()
  if( length( dl ) < 1 )
    stop("cannot find any open graphical device")
  if( .Device == "dsvg_device" ) {
    dev_num <- as.integer(dev.cur()-1L)
    ids <- collect_id(dev_num)
    set_tracer_off(dn = dev_num)
  } else ids = integer(0)

  ids

}


#' @title set attributes to graphical elements
#'
#' @description set attributes with javascript instructions
#' to graphical elements.
#' @param ids integer vector of graphical elements identifiers (returned by
#' \code{\link{dsvg_tracer_off}}).
#' @param attribute name of the attribute to set.
#' @param str values to set for the attribute.
#' @noRd
set_attr = function( ids, attribute, str ){
  stopifnot( .Device == "dsvg_device" )
  if( is.factor(str) )
    str <- as.character( str )
  if( is.factor(attribute) )
    str <- as.character( attribute )

  stopifnot( is.character(attribute) )
  stopifnot( is.character(str) )
  stopifnot( is.numeric(ids) )

  if (length(str) == 1 && length(ids) > 1) {
    str <- rep(str, length(ids))
  }
  if (length(ids) %% length(str) < 1 &&
      length(ids) != length(str)) {
    str <- rep(str, each = length(ids) %/% length(str))
  }

  if( length(ids) != length(str) ){
    stop("ids don't have the same length than str (most often, it occurs because of clipping)")
  }
  stopifnot( length(attribute) == 1 )

  if( any( grepl(pattern = "'", str) ) )
    stop("str cannot contain single quote \"'\".")
  dev_num <- as.integer(dev.cur()-1L)
  add_attribute(dn = dev_num,
                id = as.integer( ids ),
                str = str,
                name = attribute
  )

  invisible()
}
