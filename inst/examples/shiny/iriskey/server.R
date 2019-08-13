library(ggplot2)
library(ggiraph)

gg <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species, data_id = Species)) +
  geom_point_interactive( size = 3 ) +
  theme_minimal() +
  scale_colour_manual_interactive(
    data_id = c("setosa" = "setosa", "versicolor" = "versicolor", "virginica" = "virginica"),
    tooltip = c("setosa" = "setosa", "versicolor" = "versicolor", "virginica" = "virginica"),
    values = c("setosa" = "red", "versicolor" = "blue", "virginica" = "darkgreen")) +
  theme(legend.position = "top")


shinyServer(function(input, output, session) {

  selected_points <- reactive({
    input$plot_selected
  })
  selected_keys <- reactive({
    input$plot_key_selected
  })

  output$plot <- renderggiraph({
    x <- girafe(code = print(gg), width_svg = 6, height_svg = 8)
    x <- girafe_options(x, opts_selection(
      type = "multiple", css = "fill:#FF3333;stroke:black;"),
      opts_hover(css = "fill:#FF3333;stroke:black;cursor:pointer;"))
    x
  })

  output$datatab <- renderTable({
    out <- iris[iris$Species %in% selected_keys(), ]
    if( nrow(out) < 1 ) return(NULL)
    row.names(out) <- NULL
    out
  })

})
