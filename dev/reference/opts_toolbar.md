# Toolbar settings

Allows customization of the toolbar

## Usage

``` r
opts_toolbar(
  position = c("topright", "top", "bottom", "topleft", "bottomleft", "bottomright"),
  saveaspng = TRUE,
  pngname = "diagram",
  tooltips = NULL,
  hidden = NULL,
  fixed = FALSE,
  delay_mouseover = 200,
  delay_mouseout = 500,
  bg_color = NULL,
  icon_color = NULL,
  icon_active_color = NULL,
  icon_hover_color = NULL
)
```

## Arguments

- position:

  Position of the toolbar relative to the plot. One of 'top', 'bottom',
  'topleft', 'topright', 'bottomleft', 'bottomright'

- saveaspng:

  Show (TRUE) or hide (FALSE) the 'download png' button.

- pngname:

  The default basename (without .png extension) to use for the png file.

- tooltips:

  A named list with tooltip labels for the buttons, for adapting to
  other language. Passing NULL will use the default tooltips:

  list( lasso_select = 'lasso selection', lasso_deselect = 'lasso
  deselection', zoom_on = 'activate pan/zoom', zoom_off = 'deactivate
  pan/zoom', zoom_rect = 'zoom with rectangle', zoom_reset = 'reset
  pan/zoom', saveaspng = 'download png', fullscreen = 'fullscreen' )

- hidden:

  A character vector with the names of the buttons or button groups to
  be hidden from the toolbar. This allows full customization of which
  buttons appear.

  Valid button groups: 'selection', 'zoom', 'misc'

  Valid button names: 'lasso_select', 'lasso_deselect', 'zoom_onoff',
  'zoom_rect', 'zoom_reset', 'saveaspng', 'fullscreen'

- fixed:

  if FALSE (default), the toolbar will float above the graphic, if TRUE,
  the toolbar will be fixed and always visible.

- delay_mouseover:

  The duration in milliseconds of the transition associated with toolbar
  display.

- delay_mouseout:

  The duration in milliseconds of the transition associated with toolbar
  end of display.

- bg_color, icon_color, icon_active_color, icon_hover_color:

  Colors of the toolbar, as CSS color values (e.g. `"#333333"`,
  `"white"` or `"rgba(0, 0, 0, 0.5)"`): the background of the toolbar,
  the color of the icons, the color of the icons of active buttons (zoom
  activated, lasso deselection) and the color of the hovered icon. If
  `NULL` (default), the default colors are used.

## Note

`saveaspng` relies on JavaScript promises, so any browsers that don't
natively support the standard Promise object will need to have a
polyfill (e.g. Internet Explorer with version less than 11 will need
it).

## Toolbar colors

The toolbar colors are defined by CSS variables, which `bg_color`,
`icon_color`, `icon_active_color` and `icon_hover_color` set for one
graphic. To set them for all the graphics of a document or of an
application, define these variables in a stylesheet:

    .ggiraph-toolbar {
      --ggiraph-toolbar-bg: #222222;
      --ggiraph-toolbar-icon-color: #f0f0f0;
      --ggiraph-toolbar-icon-active-color: #ffb000;
      --ggiraph-toolbar-icon-hover-color: #ffffff;
    }

In R Markdown or Quarto, this rule can be written in a `css` chunk;
prefix the selector with a class (e.g. `.my-class .ggiraph-toolbar`) to
apply it only to the graphics inside an element of that class.

## See also

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_defaults.md),
[`girafe_options()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_sizing.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_tooltip.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_zoom.md),
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/set_girafe_defaults.md)

## Examples

``` r
library(ggiraph)
library(ggplot2)

dataset <- mtcars
dataset$carname <- row.names(mtcars)

gg <- ggplot(
  data = dataset,
  mapping = aes(
    x = wt, y = qsec, color = disp,
    tooltip = carname, data_id = carname
  )
) +
  geom_point_interactive() +
  theme_minimal()

x <- girafe(
  ggobj = gg,
  options = list(
    opts_zoom(max = 5),
    opts_selection(only_shiny = FALSE),
    opts_toolbar(position = "top")
  )
)
if (interactive()) print(x)

# Hide lasso selection tools (useful in Shiny when selections
# are controlled by other app interactions)
x <- girafe(
  ggobj = gg,
  options = list(
    opts_zoom(max = 5),
    opts_selection(only_shiny = FALSE),
    opts_toolbar(
      position = "top",
      hidden = c("lasso_select", "lasso_deselect")
    )
  )
)
if (interactive()) print(x)


# Keep only zoom/pan and reset, hide rectangular zoom
x <- girafe(
  ggobj = gg,
  options = list(
    opts_zoom(max = 5),
    opts_selection(only_shiny = FALSE),
    opts_toolbar(
      position = "top",
      hidden = c("selection", "zoom_rect", "saveaspng")
    )
  )
)
if (interactive()) print(x)

# Change the toolbar colors
x <- girafe(
  ggobj = gg,
  options = list(
    opts_zoom(max = 5),
    opts_toolbar(
      fixed = TRUE,
      bg_color = "#222222",
      icon_color = "#f0f0f0",
      icon_active_color = "#ffb000",
      icon_hover_color = "white"
    )
  )
)
if (interactive()) print(x)
```
