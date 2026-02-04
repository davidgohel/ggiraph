# Get girafe defaults formatting properties

The current formatting properties are automatically applied to every
girafe you produce. These default values are returned by this function.

## Usage

``` r
girafe_defaults(name = NULL)
```

## Arguments

- name:

  optional, option's name to return, one of 'fonts', 'opts_sizing',
  'opts_tooltip', 'opts_hover', 'opts_hover_key', 'opts_hover_inv',
  'opts_hover_theme', 'opts_selection', 'opts_selection_inv',
  'opts_selection_key', 'opts_selection_theme', 'opts_zoom',
  'opts_toolbar'.

## Value

a list containing default values or an element selected with argument
`name`.

## See also

Other girafe animation options:
[`girafe_options()`](https://davidgohel.github.io/ggiraph/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/reference/opts_toolbar.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/reference/opts_tooltip.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/reference/opts_zoom.md),
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/set_girafe_defaults.md)

## Examples

``` r
girafe_defaults()
#> $fonts
#> $fonts$sans
#> [1] "DejaVu Sans"
#> 
#> $fonts$serif
#> [1] "DejaVu serif"
#> 
#> $fonts$symbol
#> [1] "DejaVu Sans"
#> 
#> $fonts$mono
#> [1] "DejaVu Sans"
#> 
#> 
#> $opts_sizing
#> $rescale
#> [1] TRUE
#> 
#> $width
#> [1] 1
#> 
#> attr(,"class")
#> [1] "opts_sizing"
#> attr(,"explicit_args")
#> [1] "width"
#> 
#> $opts_tooltip
#> $css
#> [1] ".tooltip_SVGID_ { padding:5px;background:black;color:white;border-radius:2px;text-align:left; ; position:absolute;pointer-events:none;z-index:9999;}"
#> 
#> $placement
#> [1] "doc"
#> 
#> $opacity
#> [1] 0.9
#> 
#> $offx
#> [1] 10
#> 
#> $offy
#> [1] 10
#> 
#> $use_cursor_pos
#> [1] TRUE
#> 
#> $use_fill
#> [1] FALSE
#> 
#> $use_stroke
#> [1] FALSE
#> 
#> $delay_over
#> [1] 200
#> 
#> $delay_out
#> [1] 500
#> 
#> attr(,"class")
#> [1] "opts_tooltip"
#> attr(,"explicit_args")
#> [1] "css"  "offx" "offy"
#> 
#> $opts_hover
#> $css
#> [1] ".hover_data_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_data_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_data_SVGID_ { fill:orange;stroke:black; }\nline.hover_data_SVGID_, polyline.hover_data_SVGID_ { fill:none;stroke:orange; }\nrect.hover_data_SVGID_, polygon.hover_data_SVGID_, path.hover_data_SVGID_ { fill:orange;stroke:none; }\nimage.hover_data_SVGID_ { stroke:orange; }"
#> 
#> $reactive
#> [1] TRUE
#> 
#> $nearest_distance
#> NULL
#> 
#> attr(,"class")
#> [1] "opts_hover"
#> attr(,"explicit_args")
#> [1] "css"      "reactive"
#> 
#> $opts_hover_key
#> $css
#> [1] ".hover_key_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_key_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_key_SVGID_ { fill:orange;stroke:black; }\nline.hover_key_SVGID_, polyline.hover_key_SVGID_ { fill:none;stroke:orange; }\nrect.hover_key_SVGID_, polygon.hover_key_SVGID_, path.hover_key_SVGID_ { fill:orange;stroke:none; }\nimage.hover_key_SVGID_ { stroke:orange; }"
#> 
#> $reactive
#> [1] TRUE
#> 
#> attr(,"class")
#> [1] "opts_hover_key"
#> attr(,"explicit_args")
#> [1] "css"      "reactive"
#> 
#> $opts_hover_theme
#> $css
#> [1] ".hover_theme_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_theme_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_theme_SVGID_ { fill:orange;stroke:black; }\nline.hover_theme_SVGID_, polyline.hover_theme_SVGID_ { fill:none;stroke:orange; }\nrect.hover_theme_SVGID_, polygon.hover_theme_SVGID_, path.hover_theme_SVGID_ { fill:orange;stroke:none; }\nimage.hover_theme_SVGID_ { stroke:orange; }"
#> 
#> $reactive
#> [1] TRUE
#> 
#> attr(,"class")
#> [1] "opts_hover_theme"
#> attr(,"explicit_args")
#> [1] "css"      "reactive"
#> 
#> $opts_hover_inv
#> $css
#> [1] ""
#> 
#> attr(,"class")
#> [1] "opts_hover_inv"
#> attr(,"explicit_args")
#> [1] "css"
#> 
#> $opts_selection
#> $css
#> [1] ".select_data_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_data_SVGID_ { stroke:none;fill:red; }\ncircle.select_data_SVGID_ { fill:red;stroke:black; }\nline.select_data_SVGID_, polyline.select_data_SVGID_ { fill:none;stroke:red; }\nrect.select_data_SVGID_, polygon.select_data_SVGID_, path.select_data_SVGID_ { fill:red;stroke:none; }\nimage.select_data_SVGID_ { stroke:red; }"
#> 
#> $type
#> [1] "multiple"
#> 
#> $only_shiny
#> [1] TRUE
#> 
#> $selected
#> character(0)
#> 
#> attr(,"class")
#> [1] "opts_selection"
#> attr(,"explicit_args")
#> [1] "css"
#> 
#> $opts_selection_inv
#> $css
#> [1] ""
#> 
#> attr(,"class")
#> [1] "opts_selection_inv"
#> 
#> $opts_selection_key
#> $css
#> [1] ".select_key_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_key_SVGID_ { stroke:none;fill:red; }\ncircle.select_key_SVGID_ { fill:red;stroke:black; }\nline.select_key_SVGID_, polyline.select_key_SVGID_ { fill:none;stroke:red; }\nrect.select_key_SVGID_, polygon.select_key_SVGID_, path.select_key_SVGID_ { fill:red;stroke:none; }\nimage.select_key_SVGID_ { stroke:red; }"
#> 
#> $type
#> [1] "single"
#> 
#> $only_shiny
#> [1] TRUE
#> 
#> $selected
#> character(0)
#> 
#> attr(,"class")
#> [1] "opts_selection_key"
#> attr(,"explicit_args")
#> [1] "css"
#> 
#> $opts_selection_theme
#> $css
#> [1] ".select_theme_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_theme_SVGID_ { stroke:none;fill:red; }\ncircle.select_theme_SVGID_ { fill:red;stroke:black; }\nline.select_theme_SVGID_, polyline.select_theme_SVGID_ { fill:none;stroke:red; }\nrect.select_theme_SVGID_, polygon.select_theme_SVGID_, path.select_theme_SVGID_ { fill:red;stroke:none; }\nimage.select_theme_SVGID_ { stroke:red; }"
#> 
#> $type
#> [1] "single"
#> 
#> $only_shiny
#> [1] TRUE
#> 
#> $selected
#> character(0)
#> 
#> attr(,"class")
#> [1] "opts_selection_theme"
#> attr(,"explicit_args")
#> [1] "css"
#> 
#> $opts_zoom
#> $min
#> [1] 1
#> 
#> $max
#> [1] 1
#> 
#> $duration
#> [1] 300
#> 
#> $default_on
#> [1] FALSE
#> 
#> attr(,"class")
#> [1] "opts_zoom"
#> 
#> $opts_toolbar
#> $position
#> [1] "topright"
#> 
#> $pngname
#> [1] "diagram"
#> 
#> $tooltips
#> NULL
#> 
#> $fixed
#> [1] FALSE
#> 
#> $hidden
#> character(0)
#> 
#> $delay_over
#> [1] 200
#> 
#> $delay_out
#> [1] 500
#> 
#> attr(,"class")
#> [1] "opts_toolbar"
#> attr(,"explicit_args")
#> logical(0)
#> 
```
