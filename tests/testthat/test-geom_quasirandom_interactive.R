skip_if_not_installed("ggbeeswarm")

# geom_quasirandom_interactive ----
test_that("geom_quasirandom_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_quasirandom_interactive"))
})

test_that("geom_quasirandom_interactive gives each point the attributes of its row", {
  dat <- mtcars
  dat$name <- rownames(mtcars)
  dat$am <- factor(dat$am)
  dat$gear <- factor(dat$gear)
  p <- ggplot(dat, aes(am, disp, fill = gear, group = interaction(am, gear))) +
    geom_quasirandom_interactive(
      aes(tooltip = name, data_id = name),
      shape = 21,
      dodge.width = .8
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//circle[@data-id]")
  expect_length(nodes, nrow(dat))
  ids <- xml_attr(nodes, "data-id")
  expect_setequal(ids, dat$name)
  expect_equal(xml_attr(nodes, "title"), ids)
  # each circle is drawn at the height of its own row: the higher the
  # disp, the smaller the svg y coordinate
  cy <- as.numeric(xml_attr(nodes, "cy"))
  disp <- dat$disp[match(ids, dat$name)]
  expect_equal(cor(cy, disp, method = "spearman"), -1)
})
