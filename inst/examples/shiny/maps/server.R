library(ggplot2)
library(ggiraph)
library(maps)

us <- map_data("state")

gg <- ggplot()
gg <- gg + geom_map_interactive(data=us, map=us,
                    aes(long, lat, map_id=region, data_id=region, tooltip = region),
                    color="white", fill = "gray90")
gg <- gg + coord_map() + theme_void()

shinyServer(function(input, output, session) {

  selected_states <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderGirafe({
    girafe(
      ggobj = gg, width_svg = 6, height_svg = 4,
      options = list(
        opts_hover(css = "fill:#666666;cursor:pointer;"),
        opts_selection(css = "fill:orange;", type = "multiple"),
        opts_zoom(max = 3)
      )
    )
  })

  output$seltext <- renderUI({
    value <- selected_states()
    if( !isTruthy(value) )
      value <- "<none>"
    value <- paste0(value, collapse = ", ")
    tags$div(
      tags$caption("Selected states are:"),
      tags$strong(value)
    )
  })


})
