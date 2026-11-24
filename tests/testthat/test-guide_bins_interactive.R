# guide_bins_interactive ----
test_that("guide_bins_interactive", {
  eval(test_guide, envir = list(name = "guide_bins_interactive"))
})
# continuous scale - bins guide
test_that("continuous scale - bins guide", {
  p <- ggplot(mtcars) +
    geom_point_interactive(
      aes(disp, mpg, size = hp, info = I("test")),
      extra_interactive_params = "info"
    ) +
    scale_size_binned_interactive(
      data_id = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      tooltip = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      info = "scale",
      extra_interactive_params = "info",
      guide = "bins",
      name = label_interactive("hp",
        data_id = "hp",
        tooltip = "hp", info = "title",
        extra_interactive_params = "info"
      ),
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//circle[@info='scale']")
  expect_equal(length(nodes), 6, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("50-100", "100-150", "150-200", "200-250", "250-300", "300-350"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 5, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("100", "150", "200", "250", "300"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "hp", info = "legend title tooltip")
})
# continuous scale - bins guide - reverse
test_that("continuous scale - bins guide - reverse", {
  p <- ggplot(mtcars) +
    geom_point_interactive(
      aes(disp, mpg, size = hp, info = I("test")),
      extra_interactive_params = "info"
    ) +
    scale_size_binned_interactive(
      data_id = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      tooltip = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      info = "scale",
      extra_interactive_params = "info",
      guide = guide_bins(reverse = TRUE),
      name = label_interactive("hp",
        data_id = "hp",
        tooltip = "hp", info = "title",
        extra_interactive_params = "info"
      ),
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//circle[@info='scale']")
  expect_equal(length(nodes), 6, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("50-100", "100-150", "150-200", "200-250", "250-300", "300-350")), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 5, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("100", "150", "200", "250", "300")), info = "legend labels tooltips")
})
# continuous scale - bins guide - show.limits
test_that("continuous scale - bins guide - show.limits", {
  p <- ggplot(mtcars) +
    geom_point_interactive(
      aes(disp, mpg, size = hp, info = I("test")),
      extra_interactive_params = "info"
    ) +
    scale_size_binned_interactive(
      data_id = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      tooltip = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      info = "scale",
      extra_interactive_params = "info",
      guide = guide_bins(show.limits = TRUE),
      name = label_interactive("hp",
        data_id = "hp",
        tooltip = "hp", info = "title",
        extra_interactive_params = "info"
      ),
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 7, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("50", "100", "150", "200", "250", "300", "350"), info = "legend labels tooltips")
})

# labels given as a vector ----
test_that("bins guide accepts labels given as a vector, as ggplot2", {
  legend_texts <- function(p) {
    doc <- dsvg_plot(p)
    xml_text(xml_find_all(doc, ".//text"))
  }
  base <- ggplot(mtcars, aes(wt, mpg, size = hp)) + geom_point_interactive()
  expected <- legend_texts(
    base + scale_size_binned(breaks = c(100, 200, 300), labels = c("low", "mid", "high"))
  )
  p <- base + scale_size_binned_interactive(
    breaks = c(100, 200, 300),
    labels = c("low", "mid", "high"),
    data_id = function(breaks) paste0("k", seq_along(breaks))
  )
  expect_equal(legend_texts(p), expected)
  keys <- xml_find_all(dsvg_plot(p), ".//circle[@key-id]")
  expect_equal(xml_attr(keys, "key-id"), paste0("k", 1:4))
})

test_that("interactive labels given as a vector warn instead of failing", {
  base <- ggplot(mtcars, aes(wt, mpg, size = hp)) + geom_point_interactive()
  p <- base + scale_size_binned_interactive(
    breaks = c(100, 200, 300),
    labels = label_interactive(c("low", "mid", "high"), data_id = c("a", "b", "c"))
  )
  expect_warning(doc <- dsvg_plot(p), "Cannot set the guide interactive labels")
  expect_equal(
    xml_text(xml_find_all(doc, ".//text[text() = 'low' or text() = 'high']")),
    c("low", "high")
  )
})
