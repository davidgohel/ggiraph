library(shiny)
library(ggiraph)


mytheme <- theme(axis.line = element_line(colour = NA),
        axis.ticks = element_line(colour = NA),
        panel.grid.major = element_line(linetype = "blank"),
        panel.grid.minor = element_line(linetype = "blank"),
        axis.title = element_text(colour = NA),
        axis.text = element_text(colour = NA),
        panel.background = element_rect(fill = NA))

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)

onclick <- "{var dataid = d3.select(this).attr(\"data-id\");Shiny.onInputChange(\"state\", dataid);}"

dataset <- crimes
dataset$onclick = onclick

if (require("maps") ) {
  states_map <- map_data("state")
  gg_map <- ggplot(dataset, aes(map_id = state))
  gg_map <- gg_map + geom_map_interactive(aes(
    fill = Murder,
    tooltip = state,
    onclick = onclick,
    data_id = state
  ),
  map = states_map) +
    expand_limits(x = states_map$long, y = states_map$lat) +
    labs(subtitle = "interactive ggplot2 map",
         caption = "made with ggiraph") + mytheme
}


shinyServer(function(input, output) {

  state <- reactive({
    input$state
  })

  output$plot <- renderggiraph({
    ggiraph(code = print(gg_map), width = 8, height = 6, hover_css = "fill:orange;stroke-width:1px;stroke:wheat;cursor:pointer;")
  })

  output$datatab <- renderDataTable({
    out <- crimes
    if(!is.null( sel <- state()) )
      out <- crimes[crimes$state==sel,]
    out
    })

})
