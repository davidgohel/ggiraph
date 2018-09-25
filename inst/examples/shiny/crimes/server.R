library(ggplot2)
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
    x <- girafe(code = print(gg_crime), width_svg = 6, height_svg = 8)
    x <- girafe_options(x, opts_selection(
      type = "multiple", css = "fill:#FF3333;stroke:black;"),
      opts_hover(css = "fill:#FF3333;stroke:black;cursor:pointer;"))
    x
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
