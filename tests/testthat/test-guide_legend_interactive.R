# guide_legend_interactive ----
test_that("guide_legend_interactive", {
  eval(test_guide, envir = list(name = "guide_legend_interactive"))
})
# discrete scale - legend guide
test_that("discrete scale - legend guide", {
  dat <- data.frame(
    name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
    gender = c("Male", "Female", "Male", "Male", "Male"),
    height = c(169, 160, 171, 172, 171)
  )
  p <- ggplot(dat, aes(x = name, y = height, fill = gender)) +
    geom_bar_interactive(
      stat = "identity",
      extra_interactive_params = "info",
      aes(info = I("test"))
    ) +
    scale_fill_manual_interactive(
      guide = "legend",
      name = label_interactive("gender",
        tooltip = "Gender levels", data_id = "legend.title",
        info = "title", extra_interactive_params = "info"
      ),
      extra_interactive_params = "info",
      values = c(Male = "#0072B2", Female = "#009E73"),
      data_id = c(Female = "Female", Male = "Male"),
      tooltip = c(Male = "Male", Female = "Female"),
      info = c(Male = "scale", Female = "scale"),
      labels = function(breaks) {
        lapply(breaks, function(br) {
          label_interactive(
            as.character(br),
            data_id = as.character(br),
            tooltip = as.character(br),
            info = "label",
            extra_interactive_params = "info"
          )
        })
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 2, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Female", "Male"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 2, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Female", "Male"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "Gender levels", info = "legend title tooltip")
})
# discrete scale - legend guide - reverse
test_that("discrete scale - legend guide - reverse", {
  dat <- data.frame(
    name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
    gender = c("Male", "Female", "Male", "Male", "Male"),
    height = c(169, 160, 171, 172, 171)
  )
  p <- ggplot(dat, aes(x = name, y = height, fill = gender)) +
    geom_bar_interactive(
      stat = "identity",
      extra_interactive_params = "info",
      aes(info = I("test"))
    ) +
    scale_fill_manual_interactive(
      guide = guide_legend(reverse = TRUE),
      name = label_interactive("gender",
        tooltip = "Gender levels", data_id = "legend.title",
        info = "title", extra_interactive_params = "info"
      ),
      extra_interactive_params = "info",
      values = c(Male = "#0072B2", Female = "#009E73"),
      data_id = c(Female = "Female", Male = "Male"),
      tooltip = c(Male = "Male", Female = "Female"),
      info = c(Male = "scale", Female = "scale"),
      labels = function(breaks) {
        lapply(breaks, function(br) {
          label_interactive(
            as.character(br),
            data_id = as.character(br),
            tooltip = as.character(br),
            info = "label",
            extra_interactive_params = "info"
          )
        })
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 2, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Male", "Female"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 2, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Male", "Female"), info = "legend labels tooltips")
})
# continuous scale - legend guide
test_that("continuous scale - legend guide", {
  set.seed(4393)
  dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
  p <- ggplot(dsmall, aes(x, y)) +
    geom_density_2d_filled_interactive(
      aes(
        fill = after_stat(nlevel),
        tooltip = paste("nlevel:", after_stat(nlevel))
      ),
      extra_interactive_params = "info"
    ) +
    facet_grid(. ~ cut) +
    scale_fill_viridis_c_interactive(
      data_id = function(breaks) {
        as.character(breaks)
      },
      tooltip = function(breaks) {
        as.character(breaks)
      },
      info = "scale",
      extra_interactive_params = "info",
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          onclick = paste0("alert(\"", as.character(breaks), "\")"),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      },
      name = label_interactive("nlevel",
        data_id = "nlevel", tooltip = "nlevel",
        info = "title", extra_interactive_params = "info"
      ),
      guide = "legend"
    )
  girafe(ggobj = p)
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.25", "0.5", "0.75", "1"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 4, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.25", "0.5", "0.75", "1"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "nlevel", info = "legend title tooltip")
})
# continuous scale - legend guide - reverse
test_that("continuous scale - legend guide - reverse", {
  set.seed(4393)
  dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
  p <- ggplot(dsmall, aes(x, y)) +
    geom_density_2d_filled_interactive(
      aes(
        fill = after_stat(nlevel),
        tooltip = paste("nlevel:", after_stat(nlevel))
      ),
      extra_interactive_params = "info"
    ) +
    facet_grid(. ~ cut) +
    scale_fill_viridis_c_interactive(
      data_id = function(breaks) {
        as.character(breaks)
      },
      tooltip = function(breaks) {
        as.character(breaks)
      },
      info = "scale",
      extra_interactive_params = "info",
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          onclick = paste0("alert(\"", as.character(breaks), "\")"),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      },
      name = label_interactive("nlevel",
        data_id = "nlevel", tooltip = "nlevel",
        info = "title", extra_interactive_params = "info"
      ),
      guide = guide_legend(reverse = TRUE)
    )
  girafe(ggobj = p)
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("0.25", "0.5", "0.75", "1")), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 4, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("0.25", "0.5", "0.75", "1")), info = "legend labels tooltips")
})

# values whose length differs from the breaks ----
test_that("legend warns when the values do not match the breaks", {
  dat <- data.frame(x = 1:3, y = 1:3, z = c("a", "b", "c"))
  p <- ggplot(dat, aes(x, y, colour = z)) +
    geom_point_interactive() +
    scale_colour_manual_interactive(
      values = c("red", "green", "blue"),
      data_id = c("a", "b")
    )
  expect_warning(doc <- dsvg_plot(p), "differs from the number of breaks")
  expect_length(xml_find_all(doc, "//*[@key-id]"), 0)
})

# a function receives the breaks in data space, as `labels` ----
test_that("a function receives dates and untransformed breaks, as labels", {
  dat <- data.frame(x = 1:91, y = 1, z = as.Date("2024-01-01") + 0:90, w = 10^seq(0, 3, length.out = 91))
  ids <- function(b) paste0("id_", b)
  key_ids <- function(p) unique(xml_attr(xml_find_all(dsvg_plot(p), "//*[@key-id]"), "key-id"))
  label_texts <- function(p) unique(ggplot_build(p)$plot$guides$params[[1]]$key$.label)

  p <- ggplot(dat, aes(x, y, colour = z)) + geom_point_interactive(aes(data_id = 1))
  expect_equal(
    key_ids(p + scale_colour_date_interactive(data_id = ids, guide = "legend")),
    label_texts(p + scale_colour_date(labels = ids, guide = "legend"))
  )
  p <- ggplot(dat, aes(x, y, colour = w)) + geom_point_interactive(aes(data_id = 1))
  expect_equal(
    key_ids(p + scale_colour_continuous_interactive(transform = "log10", data_id = ids, guide = "legend")),
    c("id_1", "id_10", "id_100", "id_1000")
  )
  # binned guides: the lower bound of each class
  expect_equal(
    key_ids(p + scale_colour_binned_interactive(transform = "log10", data_id = ids, guide = "bins")),
    c("id_1", "id_10", "id_100")
  )
  expect_equal(
    key_ids(p + scale_colour_binned_interactive(transform = "log10", data_id = ids)),
    c("id_1", "id_10", "id_100")
  )
})

# named vectors ----
test_that("the breaks without a name keep their value, unknown names warn", {
  key_ids <- function(p) unique(xml_attr(xml_find_all(dsvg_plot(p), "//*[@key-id]"), "key-id"))
  d <- data.frame(x = 1:3, y = 1, g = c("a", "b", "c"))
  p <- ggplot(d, aes(x, y, colour = g)) + geom_point_interactive(aes(data_id = g))
  # as the labels of ggplot2
  expect_no_warning(
    ids <- key_ids(p + scale_colour_discrete_interactive(data_id = c(a = "id_a", c = "id_c")))
  )
  expect_equal(ids, c("id_a", "b", "id_c"))
  expect_warning(
    ids <- key_ids(p + scale_colour_discrete_interactive(data_id = c(A = "id_a", c = "id_c"))),
    "\"A\""
  )
  expect_equal(ids, c("a", "b", "id_c"))
})

test_that("names are matched with dates and untransformed breaks", {
  key_ids <- function(p) unique(xml_attr(xml_find_all(dsvg_plot(p), "//*[@key-id]"), "key-id"))
  dat <- data.frame(x = 1:91, y = 1, z = as.Date("2024-01-01") + 0:90, w = 10^seq(0, 3, length.out = 91))
  p <- ggplot(dat, aes(x, y, colour = z)) + geom_point_interactive(aes(data_id = 1))
  expect_no_warning(
    ids <- key_ids(p + scale_colour_date_interactive(data_id = c("2024-01-15" = "mid"), guide = "legend"))
  )
  expect_equal(ids[1:3], c("2024-01-01", "mid", "2024-02-01"))
  p <- ggplot(dat, aes(x, y, colour = w)) + geom_point_interactive(aes(data_id = 1))
  ids <- key_ids(p + scale_colour_continuous_interactive(transform = "log10", data_id = c("100" = "hundred"), guide = "legend"))
  expect_equal(ids, c("1", "10", "hundred", "1000"))
})
