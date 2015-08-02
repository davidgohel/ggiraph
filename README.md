[![Travis-CI Build Status](https://travis-ci.org/davidgohel/ggiraph.svg?branch=master)](https://travis-ci.org/davidgohel/ggiraph)
[![Build status](https://ci.appveyor.com/api/projects/status/github/davidgohel/ggiraph?branch=master)](https://ci.appveyor.com/project/davidgohel/ggiraph/branch/master)


# ggiraph

> Make 'ggplot' Graphics Interactive
    
`ggiraph` lets you create interactive ggplot graphics that are usable in the 
'RStudio' viewer pane, in 'R Markdown' documents, and in 'Shiny' apps. Options 
are:
- tooltips
- javascript click action
- javascript double click action

For now, 5 *geom* are existing:

- `geom_path_interactive`
- `geom_rect_interactive`
- `geom_point_interactive`
- `geom_segment_interactive`
- `geom_polygon_interactive`

# Installation 

You will need the latest ggplot2 version (>= 1.0.1.9002) and the lastes version of 
ReporteRs (>= 0.8.2).

    devtools::install_github('davidgohel/ReporteRsjars')
    devtools::install_github('davidgohel/ReporteRs')
    devtools::install_github('hadley/ggplot2')
    devtools::install_github('davidgohel/ggiraph')

