# This file contains helper functions copied from ggplot2.

# from gglpot2 utilities-grid.r
ggname <- function(prefix, grob) {
  grob$name <- grobName(grob, prefix)
  grob
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
  paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "")
}

# from ggplot2 utilities.r
empty <- function(df) {
  is.null(df) || nrow(df) == 0 || ncol(df) == 0
}

# from ggplot2 utilities.r
"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

# from ggplot2 utilities.r
message_wrap <- function(...) {
  msg <- paste(..., collapse = "", sep = "")
  wrapped <- strwrap(msg, width = getOption("width") - 2)
  message(paste0(wrapped, collapse = "\n"))
}

# from ggplot2 grob-null.r
is.zero <- function(x)
  is.null(x) || inherits(x, "zeroGrob")

