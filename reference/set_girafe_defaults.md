# Modify defaults girafe animation options

girafe animation options (see
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/girafe_defaults.md))
are automatically applied to every girafe you produce. Use
`set_girafe_defaults()` to override them. Use
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/init_girafe_defaults.md)
to re-init all values with the package defaults.

## Usage

``` r
set_girafe_defaults(
  fonts = NULL,
  opts_sizing = NULL,
  opts_tooltip = NULL,
  opts_hover = NULL,
  opts_hover_key = NULL,
  opts_hover_inv = NULL,
  opts_hover_theme = NULL,
  opts_selection = NULL,
  opts_selection_inv = NULL,
  opts_selection_key = NULL,
  opts_selection_theme = NULL,
  opts_zoom = NULL,
  opts_toolbar = NULL
)
```

## Arguments

- fonts:

  default values for `fonts`, see argument `fonts` of
  [`dsvg()`](https://davidgohel.github.io/ggiraph/reference/dsvg.md)
  function.

- opts_sizing:

  default values for
  [`opts_sizing()`](https://davidgohel.github.io/ggiraph/reference/opts_sizing.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_tooltip:

  default values for
  [`opts_tooltip()`](https://davidgohel.github.io/ggiraph/reference/opts_tooltip.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_hover:

  default values for
  [`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_hover_key:

  default values for
  [`opts_hover_key()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_hover_inv:

  default values for
  [`opts_hover_inv()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_hover_theme:

  default values for
  [`opts_hover_theme()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_selection:

  default values for
  [`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_selection_inv:

  default values for
  [`opts_selection_inv()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_selection_key:

  default values for
  [`opts_selection_key()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_selection_theme:

  default values for
  [`opts_selection_theme()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_zoom:

  default values for
  [`opts_zoom()`](https://davidgohel.github.io/ggiraph/reference/opts_zoom.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

- opts_toolbar:

  default values for
  [`opts_toolbar()`](https://davidgohel.github.io/ggiraph/reference/opts_toolbar.md)
  used in argument `options` of
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  function.

## See also

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/girafe_defaults.md),
[`girafe_options()`](https://davidgohel.github.io/ggiraph/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/reference/opts_toolbar.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/reference/opts_tooltip.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/reference/opts_zoom.md)

## Examples

``` r
library(ggplot2)

set_girafe_defaults(
  opts_hover = opts_hover(css = "r:10px;"),
  opts_hover_inv = opts_hover_inv(),
  opts_sizing = opts_sizing(rescale = FALSE, width = .8),
  opts_tooltip = opts_tooltip(opacity = .7,
                              offx = 20, offy = -10,
                              use_fill = TRUE, use_stroke = TRUE,
                              delay_mouseout = 1000),
  opts_toolbar = opts_toolbar(position = "top", saveaspng = FALSE),
  opts_zoom = opts_zoom(min = .8, max = 7)
)

init_girafe_defaults()
```
