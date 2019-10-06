library(ggplot2)
library(ggiraph)

gg <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point_interactive( size = 3 ) +
  theme_minimal() +
  scale_colour_manual_interactive(
    data_id = c("setosa" = "setosa", "versicolor" = "versicolor", "virginica" = "virginica"),
    tooltip = c("setosa" = "setosa", "versicolor" = "versicolor", "virginica" = "virginica"),
    values = c("setosa" = "red", "versicolor" = "blue", "virginica" = "darkgreen")) +
  theme(legend.position = "top")


shinyServer(function(input, output, session) {

  selected_keys <- reactive({
    input$plot_key_selected
  })

  output$plot <- renderggiraph({
    x <- girafe(code = print(gg), width_svg = 6, height_svg = 8)
    x <- girafe_options(x, opts_selection_key(css = "stroke:black;r:5pt;"),
                        opts_hover(css = "fill:wheat;stroke:black;stroke-width:3px;cursor:pointer;"),
                        opts_hover_key(css = "stroke:black;r:5pt;cursor:pointer;")
                        )
    x
  })

  output$datatab <- renderTable({
    print(selected_keys())
    out <- iris[iris$Species %in% selected_keys(), ]
    if( nrow(out) < 1 ) return(NULL)
    row.names(out) <- NULL
    out
  })

})
