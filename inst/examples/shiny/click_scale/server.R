library(ggplot2)
library(ggiraph)

gg <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point_interactive( size = 3 ) +
  theme_minimal() +
  scale_colour_manual_interactive(
    data_id = c("setosa" = "setosa", "versicolor" = "versicolor", "virginica" = "virginica"),
    tooltip = c("setosa" = "setosa", "versicolor" = "versicolor", "virginica" = "virginica"),
    values = c("setosa" = "#E41A1C", "versicolor" = "#377EB8", "virginica" = "#4DAF4A")) +
  theme(legend.position = "top")


shinyServer(function(input, output, session) {

  selected_keys <- reactive({
    input$plot_key_selected
  })

  output$plot <- renderGirafe({
    x <- girafe(
      code = print(gg), width_svg = 5, height_svg = 5,
      options = list(
        opts_toolbar(saveaspng = FALSE),
        opts_selection(type = "single"),
        opts_selection_key(css = "stroke:black;r:5pt;"),
        opts_hover(css = "fill:wheat;stroke:black;stroke-width:3px;cursor:pointer;"),
        opts_hover_key(css = "stroke:black;r:5pt;cursor:pointer;")
      )
    )
    x
  })

  output$datatab <- renderTable({
    out <- iris[iris$Species %in% selected_keys(), -5]
    if( nrow(out) < 1 ) return(NULL)
    row.names(out) <- NULL
    data.frame( variable = colnames(out),
                min = apply(out, 2, min),
                mean = colMeans(out),
                sd = apply(out, 2, sd),
                max = apply(out, 2, max)
                )
  })

})
