library(tinytest)
library(ggiraph)
library(xml2)
source("setup.R")

# cex affects strwidth ----
{
  doc <- dsvg_doc({
    plot.new()
    w1 <- strwidth("X")
    par(cex = 4)
    w4 <- strwidth("X")
  })

  expect_equal(w4 / w1, 4, tol = 1e-3)
}

# special characters are escaped ----
{
  doc <- dsvg_doc({
    plot.new()
    text(0.5, 0.5, "<&>")
  })

  expect_equal(xml_text(xml_find_first(doc, ".//text")), "<&>")
}

# utf-8 characters are preserved ----
{
  # skip in windows because of xml2 buglet
  if (ggiraph:::get_os() != "windows") {
    doc <- dsvg_doc({
      plot.new()
      text(0.5, 0.5, "\u00b5")
    })

    expect_equal(xml_text(xml_find_first(doc, ".//text")), "\u00b5")
  }
}

# text color is written in fill attr ----
{
  doc <- dsvg_doc({
    plot.new()
    text(0.5, 0.5, "a", col = "#113399")
  })

  expect_equal(xml_attr(xml_find_first(doc, ".//text"), "fill"), "#113399")
}

# default point size is 12 ----
{
  doc <- dsvg_doc({
    plot.new()
    text(0.5, 0.5, "a")
  })

  expect_equal(xml_attr(xml_find_first(doc, ".//text"), "font-size"), "9.00pt")
}

# cex generates fractional font sizes ----
{
  doc <- dsvg_doc({
    plot.new()
    text(0.5, 0.5, "a", cex = .1)
  })

  expect_equal(xml_attr(xml_find_first(doc, ".//text"), "font-size"), "0.90pt")
}

# font sets weight/style ----
{
  doc <- dsvg_doc({
    plot.new()
    text(0.5, seq(0.9, 0.1, length = 4), "a", font = 1:4)
  })

  text <- xml_find_all(doc, ".//text")
  expect_equal(xml_attr(text, "font-weight"), c(NA, "bold", NA, "bold"))
  expect_equal(xml_attr(text, "font-style"), c(NA, NA, "italic", "italic"))
}

# font sets weight/style ----
{
  if (
    font_family_exists("Arial") &&
      font_family_exists("Times New Roman") &&
      font_family_exists("Courier New")
  ) {
    doc <- dsvg_doc(
      fonts = list(
        sans = "Arial",
        serif = "Times New Roman",
        mono = "Courier New"
      ),
      expr = {
        plot.new()
        text(0.5, 0.1, "a", family = "serif")
        text(0.5, 0.5, "a", family = "sans")
        text(0.5, 0.9, "a", family = "mono")
      }
    )

    text <- xml_find_all(doc, ".//text")
    expect_equal(
      xml_attr(text, "font-family"),
      c("Times New Roman", "Arial", "Courier New")
    )
  }
}

# a symbol has width greater than 0 ----
{
  doc <- dsvg_doc({
    plot(c(0, 2), c(0, 2), type = "n")
    strw <- strwidth(expression(symbol("\042")))
  })
  expect_true(strw > 0)
}
