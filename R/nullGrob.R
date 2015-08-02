nullGrob <- function() {
	grob(cl = "nullGrob", name = "NULL")
}

#' @export
#' @method widthDetails nullGrob
widthDetails.nullGrob <- function(x) unit(0, "cm")

#' @export
#' @method heightDetails nullGrob
heightDetails.nullGrob <- function(x) unit(0, "cm")

#' @export
#' @method grobWidth nullGrob
grobWidth.nullGrob <- function(x) unit(0, "cm")

#' @export
#' @method grobHeight nullGrob
grobHeight.nullGrob <- function(x) unit(0, "cm")

#' @export
#' @method drawDetails nullGrob
drawDetails.nullGrob <- function(x, recording) {}

