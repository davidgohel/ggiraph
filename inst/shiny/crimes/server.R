library(ggiraph)
library(maps)

mytheme <- theme(axis.line = element_line(colour = NA),
                 axis.ticks = element_line(colour = NA),
                 axis.title = element_text(colour = NA),
                 axis.text = element_text(colour = NA))

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)

states_map <- map_data("state")
gg_map <- ggplot(crimes, aes(map_id = state))
gg_map <- gg_map + geom_map_interactive(aes(
  fill = Murder,
  tooltip = state,
  data_id = state
),
map = states_map) + coord_map() +
  expand_limits(x = states_map$long, y = states_map$lat) +
  labs(title = "interactive ggplot2 map") +
  theme_minimal() + mytheme

shinyServer(function(input, output, session) {

  selected_state <- reactive({
    input$plot_selected
  })

  output$plot <- renderggiraph({
    ggiraph(code = print(gg_map + labs(title = input$title)),
            zoom_max = 1,
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
