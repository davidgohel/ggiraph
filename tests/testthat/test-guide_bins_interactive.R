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
# one value per class, lower bounds, reverse ----
bins_keys <- function(data_id, reverse = FALSE) {
  dat <- data.frame(x = 1:60, y = 1, z = 1:60)
  p <- ggplot(dat, aes(x, y, colour = z)) +
    geom_point_interactive(aes(data_id = z)) +
    scale_colour_binned_interactive(
      breaks = c(10, 30, 50), data_id = data_id,
      guide = guide_bins(reverse = reverse)
    )
  nodes <- xml_find_all(dsvg_plot(p), "//*[@key-id]")
  stats::setNames(xml_attr(nodes, "key-id"), xml_attr(nodes, "stroke"))
}

test_that("bins guide gives each class the value of its lower bound, also reversed", {
  keys <- bins_keys(function(x) paste0("k", x))
  expect_equal(unname(keys), c("k1", "k10", "k30", "k50"))
  reversed <- bins_keys(function(x) paste0("k", x), reverse = TRUE)
  expect_equal(unname(reversed), c("k50", "k30", "k10", "k1"))
  # each class keeps its colour
  expect_equal(reversed[names(keys)], keys)
})

test_that("bins guide accepts one value per class or per break", {
  per_class <- c("a", "b", "c", "d")
  expect_no_warning(keys <- bins_keys(per_class))
  expect_equal(unname(keys), per_class)
  reversed <- bins_keys(per_class, reverse = TRUE)
  expect_equal(unname(reversed), rev(per_class))
  expect_equal(reversed[names(keys)], keys)
  # one per break, limits included: the last one is not used
  expect_equal(unname(bins_keys(c(per_class, "e"))), per_class)
  expect_warning(
    keys <- bins_keys(c("a", "b")),
    "number of classes"
  )
  expect_length(keys, 0)
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
    data_id = function(breaks) paste0("k", breaks)
  )
  expect_equal(legend_texts(p), expected)
  # the functions receive the limits, not NA, as without labels
  key_ids <- function(p) {
    xml_attr(xml_find_all(dsvg_plot(p), ".//circle[@key-id]"), "key-id")
  }
  p_no_labels <- base + scale_size_binned_interactive(
    breaks = c(100, 200, 300),
    data_id = function(breaks) paste0("k", breaks)
  )
  expect_false(any(grepl("NA", key_ids(p))))
  expect_equal(key_ids(p), key_ids(p_no_labels))
})

test_that("interactive labels given as a vector warn instead of failing", {
  base <- ggplot(mtcars, aes(wt, mpg, size = hp)) + geom_point_interactive()
  p <- base + scale_size_binned_interactive(
    breaks = c(100, 200, 300),
    labels = label_interactive(c("low", "mid", "high"), data_id = c("a", "b", "c"))
  )
  expect_warning(doc <- dsvg_plot(p), "interactive labels of the guide")
  expect_equal(
    xml_text(xml_find_all(doc, ".//text[text() = 'low' or text() = 'high']")),
    c("low", "high")
  )
})

# discrete scale - bins guide ----
test_that("bins guide with a discrete scale of intervals draws as ggplot2", {
  dat <- data.frame(
    x = 1:8, y = 1:8,
    z = cut(c(10, 20, 30, 40, 60, 70, 80, 95), c(0, 25, 50, 100))
  )
  base <- ggplot(dat, aes(x, y, colour = z)) + geom_point_interactive()
  p_ggplot2 <- base + guides(colour = guide_bins())
  received <- NULL
  p_ggiraph <- base +
    scale_colour_discrete_interactive(
      data_id = function(breaks) {
        received <<- breaks
        c(paste0("bin", seq_len(length(breaks) - 1)), NA)
      },
      guide = "bins"
    )
  doc_ggplot2 <- dsvg_plot(p_ggplot2)
  doc_ggiraph <- dsvg_plot(p_ggiraph)

  # the intervals are parsed into breaks and limits
  expect_equal(received, c(0, 25, 50, 100))
  expect_equal(
    xml_text(xml_find_all(doc_ggiraph, "//text")),
    xml_text(xml_find_all(doc_ggplot2, "//text"))
  )
  keys <- xml_find_all(doc_ggiraph, "//circle[@key-id]")
  expect_equal(xml_attr(keys, "key-id"), c("bin1", "bin2", "bin3"))
})

test_that("bins guide with a discrete scale needs intervals as breaks", {
  dat <- data.frame(x = 1:3, y = 1:3, z = c("a", "b", "c"))
  p <- ggplot(dat, aes(x, y, colour = z)) +
    geom_point_interactive() +
    scale_colour_discrete_interactive(data_id = "bins", guide = "bins")
  # same warning ("NAs introduced by coercion") and error as ggplot2
  expect_error(suppressWarnings(dsvg_plot(p)), "not formatted correctly")
})
