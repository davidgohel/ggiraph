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

  selected_car <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderggiraph({
    ggiraph(code = print(gg), width_svg = 6, height_svg = 4,
            zoom_max = 3,
            hover_css = "fill:#666666;cursor:pointer;",
            selection_type = "multiple",
            selected_css = "fill:orange;")
  })

  observe( {
    value <- selected_car()
    updateTextInput(session = session, "sel", value = paste0(value, collapse = ",") )
  })

})
