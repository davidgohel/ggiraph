library(tinytest)
library(ggiraph)
library(xml2)
source("setup.R")

# tracer is working ----
{
  doc <- dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6), c(.4, .3))
    ids <- ggiraph:::dsvg_tracer_off()
  })

  expect_equal(length(ids), 2)
  expect_equal(ids, 1:2)
}

# tracer does not work with if not turned on ----
{
  doc <- dsvg_doc({
    plot.new()
    points(0.5, .6)
    ids <- ggiraph:::dsvg_tracer_off()
  })

  expect_equal(length(ids), 0)
}

# attributes are written ----
{
  doc <- dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6), c(.4, .3))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(
      name = "onclick",
      ids = ids,
      values = c("alert(1)", "alert(2)")
    )
  })

  circle_nodes <- xml_find_all(doc, ".//circle")
  expect_equal(length(circle_nodes), 2)
  circle <- circle_nodes[[1]]
  expect_equal(xml_attr(circle, "onclick"), "alert(1)")
  circle <- circle_nodes[[2]]
  expect_equal(xml_attr(circle, "onclick"), "alert(2)")
}

# attributes cannot contain single quotes ----
{
  expect_error(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6), c(.4, .3))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(
      name = "onclick",
      ids = ids,
      values = c("alert('1')", "alert('2')")
    )
  }))
}

# set_attr throws error with invalid argument types ----
{
  expect_error(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = ids, values = 1)
  }))
  expect_error(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = 1, ids = ids, values = "bar")
  }))
  expect_error(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = "foo", values = "bar")
  }))
}

# set_attr converts factors to character ----
{
  doc <- dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(0.5, .6)
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = factor("foo"), ids = ids, values = factor("bar"))
  })

  circle_nodes <- xml_find_all(doc, ".//circle")
  expect_equal(length(circle_nodes), 1)
  circle <- circle_nodes[[1]]
  expect_equal(xml_attr(circle, "foo"), "bar")
}

# empty attributes are not set ----
{
  doc <- dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(0.5, .6)
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = ids, values = "")
  })

  circle_node <- xml_find_first(doc, ".//circle")
  expect_false(xml_has_attr(circle_node, "foo"))
}

# set_attr can only set one attribute at a time ----
{
  expect_error(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6, .7), c(.4, .3, .5))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = c("foo", "foo"), ids = ids, values = "bar")
  }))
}

# set_attr works with multiple ids and one value ----
{
  doc <- dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6), c(.4, .3))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = ids, values = "bar")
  })
  circle_nodes <- xml_find_all(doc, ".//circle")
  expect_equal(length(circle_nodes), 2)
  expect_equal(xml_attr(circle_nodes[[1]], "foo"), "bar")
  expect_equal(xml_attr(circle_nodes[[2]], "foo"), "bar")
}

# set_attr works with multiple ids and less but even values ----
{
  doc <- dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6, .7, .8), c(.4, .3, .5, .6))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = ids, values = c("bar1", "bar2"))
  })
  circle_nodes <- xml_find_all(doc, ".//circle")
  expect_equal(length(circle_nodes), 4)
  expect_equal(xml_attr(circle_nodes[[1]], "foo"), "bar1")
  expect_equal(xml_attr(circle_nodes[[2]], "foo"), "bar1")
  expect_equal(xml_attr(circle_nodes[[3]], "foo"), "bar2")
  expect_equal(xml_attr(circle_nodes[[4]], "foo"), "bar2")
}

# set_attr gives a warning with mismatched ids and values ----
{
  expect_warning(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5, .6, .7), c(.4, .3, .5))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = ids, values = c("bar1", "bar2"))
  }))
}

# attributes with style css work ----
{
  attrs <- c("hover", "selected")
  types <- c("data", "key", "theme")

  for (type in types) {
    for (attr in attrs) {
      typename <- paste0(type, "-id")
      attrname <- paste0(attr, "_css")
      suffix <- "_"
      if (type != "data") {
        suffix <- paste0(suffix, type, "_")
      }
      doc <- dsvg_doc({
        plot.new()
        ggiraph:::dsvg_tracer_on()
        points(0.5, .6)
        ids <- ggiraph:::dsvg_tracer_off()
        ggiraph:::set_attr(name = typename, ids = ids, values = "id")
        ggiraph:::set_attr(
          name = attrname, ids = ids,
          values = ggiraph:::check_css_attr("cursor: pointer;")
        )
      })
      style_node <- xml_find_first(doc, ".//style")
      style <- xml2::xml_text(style_node)
      expect_equal(style, paste0(
        ".", attr,
        suffix,
        "svgid[",
        typename,
        " = \"id\"] { cursor: pointer; }"
      ))
    }
  }
}
# add_attribute gives a warning when element index is not found ----
{
  expect_warning(dsvg_doc({
    plot.new()
    ggiraph:::dsvg_tracer_on()
    points(c(0.5), c(.4))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "foo", ids = 2, values = "bar")
  }))
}


# tracer does not work with non-dsvg device ----
{
  file <- tempfile()
  devlength <- length(dev.list())
  tryCatch(
    {
      postscript(file)
      ids <- ggiraph:::dsvg_tracer_off()
    },
    finally = {
      if (length(dev.list()) > devlength) {
        dev.off()
      }
      unlink(file)
    }
  )
  expect_equal(length(ids), 0)
}

# tracer does not work with non-dsvg device ----
{
  file <- tempfile()
  devlength <- length(dev.list())
  tryCatch(
    {
      postscript(file)
      result <- ggiraph:::dsvg_tracer_on()
    },
    finally = {
      if (length(dev.list()) > devlength) {
        dev.off()
      }
      unlink(file)
    }
  )
  expect_null(result)
}

# tracers do not work with no device ----
{
  expect_false(ggiraph:::set_tracer_on(0))
  expect_false(ggiraph:::set_tracer_off(0))
  expect_equal(length(ggiraph:::collect_id(0)), 0)
  expect_false(ggiraph:::add_attribute(0, "foo", 1, "bar"))
}
