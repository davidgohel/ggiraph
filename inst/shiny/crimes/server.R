library(ggiraph)
library(maps)

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)

gg_crime <- ggplot(crimes, aes(x = Murder, y = Assault, color = UrbanPop )) +
  geom_point_interactive(
    aes( data_id = state, tooltip = state), size = 3 ) +
  scale_colour_gradient(low = "#999999", high = "orange") +
  theme_minimal()


shinyServer(function(input, output, session) {

  selected_state <- reactive({
    input$plot_selected
  })

  output$plot <- renderggiraph({
    ggiraph(code = print(gg_crime),
            width = 1,
            hover_css = "fill:#FF3333;stroke:black;cursor:pointer;",
            selected_css = "fill:#FF3333;stroke:black;")
  })

  observeEvent(input$reset, {
    session$sendCustomMessage(type = 'plot_set', message = character(0))
  })

  output$datatab <- renderTable({
    out <- crimes[crimes$state %in% selected_state(), ]
    if( nrow(out) < 1 ) return(NULL)
    row.names(out) <- NULL
    out
  })

})
