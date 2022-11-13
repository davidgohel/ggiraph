library(ggplot2)
library(ggiraph)

p1 <- ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point_interactive(aes(tooltip = row.names(mtcars)))

# Always remember to set the theme's strip texts as interactive
# no need to set any interactive parameters, they'll be assigned from the labels
p1 <- p1 +
  theme(
    strip.text.x = element_text_interactive(),
    strip.text.y = element_text_interactive()
  )

# simple facet
p <- p1 + facet_wrap_interactive(
  vars(gear),
  labeller = labeller_interactive(aes(tooltip = paste("Gear:", gear)))
)
x <- girafe(ggobj = p)
if (interactive()) print(x)

# With two vars. When the .multi_line labeller argument is TRUE (default),
# supply a different labeller for each var
p <- p1 + facet_wrap_interactive(
  vars(gear, vs),
  labeller = labeller_interactive(
    gear = labeller_interactive(aes(tooltip = paste("Gear:", gear))),
    vs = labeller_interactive(aes(tooltip = paste("VS:", vs)))
  )
)
x <- girafe(ggobj = p)
if (interactive()) print(x)

# When the .multi_line argument is FALSE, the labels are joined and
# the same happens with the data, so we can refer to both variables in the aesthetics!
p <- p1 + facet_wrap_interactive(
  vars(gear, vs),
  labeller = labeller_interactive(
    aes(tooltip = paste0("Gear: ", gear, "\nVS: ", vs)),
    .multi_line = FALSE
  )
)
x <- girafe(ggobj = p)
if (interactive()) print(x)

# Example with facet_grid:
p <- p1 + facet_grid_interactive(
  vs + am ~ gear,
  labeller = labeller(
    gear = labeller_interactive(aes(
      tooltip = paste("gear:", gear), data_id = paste0("gear_", gear)
    )),
    vs = labeller_interactive(aes(
      tooltip = paste("VS:", vs), data_id = paste0("vs_", vs)
    )),
    am = labeller_interactive(aes(
      tooltip = paste("AM:", am), data_id = paste0("am_", am)
    ))
  )
)
x <- girafe(ggobj = p)
if (interactive()) print(x)

# Same with .rows and .cols and .multi_line = FALSE
p <- p1 + facet_grid_interactive(
  vs + am ~ gear,
  labeller = labeller(
    .cols = labeller_interactive(
      .mapping = aes(tooltip = paste("gear:", gear))
    ),
    .rows = labeller_interactive(
      aes(tooltip = paste0("VS: ", vs, "\nAM: ", am)),
      .multi_line = FALSE
    )
  )
)
x <- girafe(ggobj = p)
if (interactive()) print(x)

# a more complex example
p2 <- ggplot(msleep, aes(x = sleep_total, y = awake)) +
  geom_point_interactive(aes(tooltip = name)) +
  theme(
    strip.text.x = element_text_interactive(),
    strip.text.y = element_text_interactive()
  )

# character vector as lookup table
conservation_status <- c(
  cd = "Conservation Dependent",
  en = "Endangered",
  lc = "Least concern",
  nt = "Near Threatened",
  vu = "Vulnerable",
  domesticated = "Domesticated"
)

# function to capitalize a string
capitalize <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

# function to cut a string and append an ellipsis
cut_str <- function(x, width = 10) {
  ind <- !is.na(x) & nchar(x) > width
  x[ind] <- paste0(substr(x[ind], 1, width), "...")
  x
}

replace_nas <- function(x) {
  ifelse(is.na(x), "Not available", x)
}

# in this example we use the '.label' variable to access the produced label
# and we set the 'label' aesthetic to modify the label
p <- p2 + facet_grid_interactive(
  vore ~ conservation,
  labeller = labeller(
    vore = labeller_interactive(
      aes(tooltip = paste("Vore:", replace_nas(.label))),
      .default = capitalize
    ),
    conservation = labeller_interactive(
      aes(
        tooltip = paste("Conservation:\n", replace_nas(.label)),
        label = cut_str(.label, 3)
      ),
      .default = conservation_status
    )
  )
)

x <- girafe(ggobj = p)
if (interactive()) print(x)
