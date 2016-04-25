library(ggiraph)

mytheme <- theme(axis.line = element_line(colour = NA),
                 axis.ticks = element_line(colour = NA),
                 panel.grid.major = element_line(linetype = "blank"),
                 panel.grid.minor = element_line(linetype = "blank"),
                 axis.title = element_text(colour = NA),
                 axis.text = element_text(colour = NA),
                 panel.background = element_rect(fill = NA))

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)

if (require("maps") ) {
  states_map <- map_data("state")
  gg_map <- ggplot(crimes, aes(map_id = state))
  gg_map <- gg_map + geom_map_interactive(aes(
    fill = Murder,
    tooltip = state,
    data_id = state
  ),
  map = states_map) + coord_map() +
    expand_limits(x = states_map$long, y = states_map$lat) +
    labs(subtitle = "interactive ggplot2 map",
         caption = "made with ggiraph") + mytheme
}


shinyServer(function(input, output, session) {

  selected_state <- reactive({
    input$plot_selected
  })

  output$plot <- renderggiraph({
    ggiraph(code = print(gg_map), width = 8, height = 6, zoom_max = 4,
            hover_css = "stroke:#ffd700;cursor:pointer;",
            selected_css = "fill:#fe4902;stroke:#ffd700;")
  })

  observeEvent(input$reset, {
    session$sendCustomMessage(type = 'plot_set', message = character(0))
  })

  output$datatab <- renderDataTable({
    crimes[crimes$state %in% selected_state(),]
  })

})
