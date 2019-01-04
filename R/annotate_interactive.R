#' @title interactive annotations
#'
#' @description
#' Create interactive annotations, similar to ggplot2 \code{\link[ggplot2]{annotate}}.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams ggplot2::annotate
#' @importFrom ggplot2 annotate
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#'
#' gg <- ggplot(mtcars, aes(x = disp, y = qsec )) +
#'   geom_point(size=2) +
#'   annotate_interactive(
#'     "rect", xmin = 100, xmax = 400, fill = "red",
#'     data_id = "an_id", tooltip = "a tooltip",
#'     ymin = 18, ymax = 20, alpha = .5)
#'
#' x <- girafe(ggobj = gg, width_svg = 5, height_svg = 4)
#' if( interactive() ) print(x)
#' @export
annotate_interactive <-
  function (geom,
            x = NULL, y = NULL,
            xmin = NULL,
            xmax = NULL,
            ymin = NULL,
            ymax = NULL,
            xend = NULL,
            yend = NULL,
            ...,
            na.rm = FALSE)
  {
    geom <- check_interactive_class(geom, env = parent.frame())
    annotate(
      geom = geom,
      x = x,
      y = y,
      xmin = xmin,
      xmax = xmax,
      ymin = ymin,
      ymax = ymax,
      xend = xend,
      yend = yend,
      ...,
      na.rm = na.rm
    )
  }

# adapted from gglpot2 check_subclass in layer.r
check_interactive_class <- function(x, env = parent.frame()) {
  if (inherits(x, "Geom")) {
    name <- eval(quote(deparse(substitute(x))), envir = parent.frame())
  } else if (is.character(x) && length(x) == 1) {
    name <- x
    if (name == "histogram") {
      name <- "bar"
    }
    if (!startsWith(name, "GeomInteractive")) {
      name <- paste0("GeomInteractive", camelize(name, first = TRUE))
    }
  } else {
    stop(
      "`geom` must be either a string or a GeomInteractive* object, ",
      "not ", obj_desc(x),
      call. = FALSE
    )
  }
  obj <- find_global(name, env = env)
  if (is.null(obj) || !inherits(obj, "Geom")) {
    stop("Can't find interactive geom function called \"", x, "\"", call. = FALSE)
  } else {
    obj
  }
}

# from gglpot2 layer.r
obj_desc <- function(x) {
  if (isS4(x)) {
    paste0("an S4 object with class ", class(x)[[1]])
  } else if (is.object(x)) {
    if (is.data.frame(x)) {
      "a data frame"
    } else if (is.factor(x)) {
      "a factor"
    } else {
      paste0("an S3 object with class ", paste(class(x), collapse = "/"))
    }
  } else {
    switch(typeof(x),
           "NULL" = "a NULL",
           character = "a character vector",
           integer = "an integer vector",
           logical = "a logical vector",
           double = "a numeric vector",
           list = "a list",
           closure = "a function",
           paste0("a base object of type", typeof(x))
    )
  }
}

# from gglpot2 scale-type.r
find_global <- function(name, env, mode = "any") {
  if (exists(name, envir = env, mode = mode)) {
    return(get(name, envir = env, mode = mode))
  }

  nsenv <- asNamespace("ggiraph")
  if (exists(name, envir = nsenv, mode = mode)) {
    return(get(name, envir = nsenv, mode = mode))
  }

  NULL
}

# from gglpot2 utilities.r
camelize <- function(x, first = FALSE) {
  x <- gsub("_(.)", "\\U\\1", x, perl = TRUE)
  if (first) x <- firstUpper(x)
  x
}

# from gglpot2 utilities.r
firstUpper <- function(s) {
  paste(toupper(substring(s, 1,1)), substring(s, 2), sep = "")
}
