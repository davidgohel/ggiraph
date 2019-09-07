#' Reads the interactive attributes from xml and assigns them to their svg elements.
#' @noRd
#' @importFrom purrr walk
#' @importFrom xml2 xml_find_first xml_add_child xml_cdata
set_svg_attributes <- function(data, canvas_id) {
  comments <- xml_find_all(data, "//*[local-name() = 'comment']")
  if (length(comments) == 0) {
    return()
  }
  idprefix <- paste0(canvas_id, "_el_")
  env_data_hover <- new.env(parent = emptyenv())
  env_key_hover <- new.env(parent = emptyenv())
  env_data_selected <- new.env(parent = emptyenv())
  env_key_selected <- new.env(parent = emptyenv())
  errored <- 0
  walk(comments, function(comment) {
    targetIndex <- xml_attr(comment, "target")
    attrName <- xml_attr(comment, "attr")
    attrValue <- xml_text(comment)
    target <- xml_find_first(data,
                             paste0("//*[@id='", idprefix, targetIndex, "']"))
    if (!inherits(target, "xml_missing")) {
      if (attrName == "hover_css") {
        # collect unique combinations of hover_css per data/key id
        collect_css(target, attrValue, env_data_hover, env_key_hover)

      } else if (attrName == "selected_css") {
        # collect unique combinations of selected_css per data/key id
        collect_css(target,
                    attrValue,
                    env_data_selected,
                    env_key_selected)

      } else {
        # set the attribute directly
        xml_attr(target, attrName) <- attrValue
      }
    } else {
      errored <<- errored + 1
    }
  })
  # now place the individual styles
  css <- make_css(env_data_hover,
                  "data-id",
                  "hover_",
                  canvas_id)
  css <- c(css,
           make_css(env_key_hover,
                    "key-id",
                    "hoverkey_",
                    canvas_id))
  css <- c(css,
           make_css(env_data_selected,
                    "data-id",
                    "clicked_",
                    canvas_id))
  css <- c(css,
           make_css(env_key_selected,
                    "key-id",
                    "clicked_key",
                    canvas_id))
  if (length(css) > 0) {
    style_tag <-
      xml_add_child(data, "style", type = "text/css", .where = 0)
    xml_add_child(style_tag, xml_cdata(paste(css, collapse = '\n')))
  }

  # clear the comments
  xml_remove(comments)
  if (errored > 0) {
    stop("Could not set svg attributes for some elements (",
         errored,
         " cases)")
  }
}

collect_css <- function(target, attrValue, env_data, env_key) {
  data_id <- xml_attr(target, "data-id")
  key_id <- xml_attr(target, "key-id")
  if (!is.null(data_id) && !is.na(data_id)) {
    env_data[[data_id]] <- attrValue
  } else if (!is.null(key_id) && !is.na(key_id)) {
    env_key[[key_id]] <- attrValue
  }
}

make_css <- function(envir, data_attr, cls_prefix, canvas_id) {
  lapply(ls(envir, all.names = TRUE, sorted = FALSE), function(x) {
    css <- get(x, envir = envir)
    paste0(".",
           cls_prefix,
           canvas_id,
           "[",
           data_attr,
           " = \"",
           x ,
           "\"]",
           " {",
           css,
           "}")
  })
}
