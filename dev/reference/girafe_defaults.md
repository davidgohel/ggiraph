# Get girafe defaults formatting properties

The current formatting properties are automatically applied to every
girafe you produce. These default values are returned by this function.

## Usage

``` r
girafe_defaults(name = NULL)
```

## Arguments

- name:

  optional, option's name to return, one of 'opts_sizing',
  'opts_tooltip', 'opts_hover', 'opts_hover_key', 'opts_hover_inv',
  'opts_hover_theme', 'opts_selection', 'opts_selection_inv',
  'opts_selection_key', 'opts_selection_theme', 'opts_zoom',
  'opts_toolbar'.

## Value

a list containing default values or an element selected with argument
`name`.

## See also

Other girafe animation options:
[`girafe_options()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_toolbar.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_tooltip.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_zoom.md),
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/set_girafe_defaults.md)

## Examples

``` r
girafe_defaults()
#> $opts_sizing
#> <opts_sizing>
#>  $ rescale: logi TRUE
#>  $ width  : num 1
#> 
#> $opts_tooltip
#> <opts_tooltip>
#>  $ css            : chr "padding:5px;background:black;color:white;border-radius:2px;text-align:left;"
#>  $ offx           : num 10
#>  $ offy           : num 10
#>  $ use_cursor_pos : logi TRUE
#>  $ opacity        : num 0.9
#>  $ use_fill       : logi FALSE
#>  $ use_stroke     : logi FALSE
#>  $ delay_mouseover: num 200
#>  $ delay_mouseout : num 500
#>  $ placement      : chr "auto"
#>  $ zindex         : num 9999
#> 
#> $opts_hover
#> <opts_hover>
#>  $ css             : chr "/*GIRAFE CSS*/._CLASSNAME_ { fill:orange;stroke:black;cursor:pointer; }\ntext._CLASSNAME_ { stroke:none;fill:or"| __truncated__
#>  $ reactive        : logi TRUE
#>  $ nearest_distance: NULL
#>  $ linked          : logi FALSE
#> 
#> $opts_hover_key
#> <opts_hover_key>
#>  $ css     : chr "/*GIRAFE CSS*/._CLASSNAME_ { fill:orange;stroke:black;cursor:pointer; }\ntext._CLASSNAME_ { stroke:none;fill:or"| __truncated__
#>  $ reactive: logi TRUE
#> 
#> $opts_hover_theme
#> <opts_hover_theme>
#>  $ css     : chr "/*GIRAFE CSS*/._CLASSNAME_ { fill:orange;stroke:black;cursor:pointer; }\ntext._CLASSNAME_ { stroke:none;fill:or"| __truncated__
#>  $ reactive: logi TRUE
#> 
#> $opts_hover_inv
#> <opts_hover_inv>
#>  $ css: chr ""
#> 
#> $opts_selection
#> <opts_selection>
#>  $ css       : chr "/*GIRAFE CSS*/._CLASSNAME_ { fill:red;stroke:black;cursor:pointer; }\ntext._CLASSNAME_ { stroke:none;fill:red; "| __truncated__
#>  $ type      : chr "multiple"
#>  $ only_shiny: logi TRUE
#>  $ selected  : chr(0) 
#>  $ linked    : logi FALSE
#> 
#> $opts_selection_inv
#> <opts_selection_inv>
#>  $ css: NULL
#> 
#> $opts_selection_key
#> <opts_selection_key>
#>  $ css       : chr "/*GIRAFE CSS*/._CLASSNAME_ { fill:red;stroke:black;cursor:pointer; }\ntext._CLASSNAME_ { stroke:none;fill:red; "| __truncated__
#>  $ type      : chr "single"
#>  $ only_shiny: logi TRUE
#>  $ selected  : chr(0) 
#> 
#> $opts_selection_theme
#> <opts_selection_theme>
#>  $ css       : chr "/*GIRAFE CSS*/._CLASSNAME_ { fill:red;stroke:black;cursor:pointer; }\ntext._CLASSNAME_ { stroke:none;fill:red; "| __truncated__
#>  $ type      : chr "single"
#>  $ only_shiny: logi TRUE
#>  $ selected  : chr(0) 
#> 
#> $opts_zoom
#> <opts_zoom>
#>  $ min       : num 1
#>  $ max       : num 1
#>  $ duration  : num 300
#>  $ default_on: logi FALSE
#> 
#> $opts_toolbar
#> <opts_toolbar>
#>  $ position         : chr "topright"
#>  $ saveaspng        : logi TRUE
#>  $ pngname          : chr "diagram"
#>  $ tooltips         : NULL
#>  $ hidden           : NULL
#>  $ fixed            : logi FALSE
#>  $ delay_mouseover  : num 200
#>  $ delay_mouseout   : num 500
#>  $ bg_color         : NULL
#>  $ icon_color       : NULL
#>  $ icon_active_color: NULL
#>  $ icon_hover_color : NULL
#> 
```
