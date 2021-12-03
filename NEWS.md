# ggiraph 0.8.0

## Enhancement
* Updated DSVG device version to 14
* Added support for clipping paths, masks, gradients and patterns
* Implemented new version of internal DSVG device
* Refactored cpp code, to smaller files per context
* Added tests for tinytest & improved coverage
* New geom functions: `geom_violin_interactive`, `geom_label_repel_interactive`, `geom_text_repel_interactive`, `geom_contour_filled_interactive`, `geom_hex_interactive`, `geom_spoke_interactive`, `geom_curve_interactive`, `geom_count_interactive`, `geom_bin_2d_interactive`, `geom_density_2d_filled_interactive`.
* New grob functions: `interactive_curve_grob`.
* New scale functions: `scale_alpha_binned_interactive`.
* Added `outputArgs` argument to `renderGirafe`, for controlling svg dimensions in rmarkdown 
* Demote to warning the error case of setting svg attributes because of mismatched id's.
* Added support for custom interactive parameters via `extra_interactive_params` argument
* Miscellaneous refactorings & improvements to internal code

## Changes
* Updated `tinyxml2` to version `9.0.0`
* Switched to `tinytest` for testing
* Updated dependency for `ggplot2` to version `3.3.5`.
* Updated libs for Windows build (thanks to Jeroen Ooms)

## Issues
* Fixed `interactive_text_grob` when check.overlap = TRUE
* Fixed `interactive_points_grob` interactive attributes when shapes with lines are used
* Fixed issues for `geom_errorbar_interactive`
* Fixed some typos in documentation
* Handle NA's in `GeomInteractiveTile`

# ggiraph 0.7.10

## Enhancement

* Make sure that parameters for panel_draw|group are the same as in ggplot2
* Updated labeller_interactive so that its usage is more intuitive
* Updated geoms and utils from latest ggplot2

## Issues

* drop configure script and mimic svglite way of integrating libpng

# ggiraph 0.7.9

## Enhancement

* New function `geom_dotplot_interactive`.
* New function `labeller_interactive` to make strip labels interactive.

## Changes

* Improved tooltip positioning and added 'placement' parameter
* Added 'tooltip_fill' interactive attribute
* move font management from gdtools to systemfonts, also libpng
is now required as gdtools/cairo is not used anymore. It comes also
with functions `validated_fonts()` and also `match_family()` and
`font_family_exists()` that have been copied from package gdtools.
* Updated some geometries from latest ggplot2

## Issues

* Fixed issue with tooltip fill color in geom_label_interactive
* Fixed tooltip issues (scaling and markup decoding) in xaringan
* Fixed issue with tooltip css missing zindex and pointer-events

# ggiraph 0.7.8

## Changes

* update for changes in the R graphics engine (thanks to Dr Paul Murrell)

## Issues

* set max size in shiny to shinyOutput size

# ggiraph 0.7.7

## Enhancement

* Updated geoms to ggplot2 v3.3.0
* Added new scales and guides from ggplot2 v3.3.0

# ggiraph 0.7.5

## Enhancement

* Using tinyxml2 for creating the svg doc

# ggiraph 0.7.1

## Enhancement

* Refactoring of ggiraphjs, with separate modules for each action context
* Added shiny messaging for hovered elements
* Added opts_hover_inv for inverted hover effect
* Added parameter for exported png filename and set png quality to 1

## Bug fixes

* misc fixes in interactive geom internals

## Documentation

* Added a complete shiny example (gender) for selection/hover options/tricks

# ggiraph 0.7.0

## Enhancement

* refactoring of internals
* new function `girafe_css()` to define individual css properties per type of elements
* ability to add interactivity to panel as usual but also theme and scales now
* Upgrade geoms to ggplot2 v3.2.0 (thanks for this huge work kindly made by Panagiotis Skintzos)

# ggiraph 0.6.2

## Enhancement

* tooltip will always be displayed inside the SVG area (for small devices)
* Upgrade geoms to ggplot2 v3.2.0 (thanks for this huge work kindly made by Panagiotis Skintzos)

## Bug fixes

* Handle html entities in tooltip
* fix some differences of rendering between ggplot2 pure graphs
  and girafe output (#125)

# ggiraph 0.6.1

## Enhancement

* new `annotate_interactive` function.

## Changes

* improving sizing with shiny.

# ggiraph 0.6.0

## Changes

* The package is no more importing rvg and now need a compiler to install
  the package from source. The dsvg function will be then removed from rvg.

# ggiraph 0.5.0

## Changes

* the package offers now new functions `girafe()` and `girafe_options()` to
  be used instead of function `ggiraph()`. It is more
  convenient to use when customization is needed.

## Enhancement

* add a 'download as png' button
* usage of d3 version 5.7.0

## Bug fixes

* responsive behaviour when rendered in IE <= 12 is now fixed

# ggiraph 0.4.4

## Enhancement

* new functions `geom_sf_interactive`

# ggiraph 0.4.3

## Enhancement

* new functions `geom_hline_interactive` and `geom_vline_interactive`
implemented by Eric Book.
* all element with the same data_id are highlighted when mouse is over one of these elements.
* ggproto `GeomInteractive` are exported.

# ggiraph 0.4.2

## Changes

* ggiraph has a new argument `dep_dir` that controls the location of the output files.
* deprecation of argument `use_widget_size` and `flexdashboard`. I hope this is the
  last mention to theses in the NEWS file.


# ggiraph 0.4.1

## Changes

* argument `flexdashboard` and `width` are no more deprecated...
* ggiraph gains a new argument `use_widget_size` that force usage of htmlwidget size and
  block the responsive behavior.

# ggiraph 0.4.0

## Enhancement

* lasso selection has been implemented in Shiny context
* a toolbar for zooming and selecting elements has been implemented.

## Changes

* zoom is disabled by default and can be activated via a button in the toolbar. It prevents scrooling issue (mouse over a zoomable svg steals scroll ability within the document).
* ggiraph arguments `flexdashboard` and `width` are now deprecated and have no effects

# ggiraph 0.3.3

## Enhancement

* widget sizing has been improved and ggiraph function gains new argument
  `flexdashboard` to make sure the graph fits available room.

## Bug fixes

* warnings did occur because some default_aes of ggproto were missing
* slow zoom pan effect is now solved

# ggiraph 0.3.2

## New features

* new geometry: geom_tile_interactive

## Bug fixes

* fix for element selection: svg elements with same id were not all selected
  but the only element that was clicked
* fix css issues that occured when several ggiraph were on the same page and their tooltip did not
  share the same css attributes.

## Enhancement

* link to the online documentation.
* usage of d3.js V4

# ggiraph 0.3.1

## New features

* size management has been improved
* there are 3 new geometries: geom_boxplot_interactive, geom_line_interactive
  and geom_bar_interactive.

## Bug fixes

* addCustomMessageHandler has to be called once to avoid a javascript exception
* fix display issue in RStudio viewer for Windows

# ggiraph 0.3.0

## Enhancement

* Allow zooming & panning to be turned off
* clicked elements can now be tracked from shiny

# ggiraph 0.2.0

## Enhancement

* Migration to d3.js
* Update to htmlwidgets 0.6
