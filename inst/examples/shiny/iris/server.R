library(ggplot2)
library(ggiraph)

shinyServer(function(input, output, session) {

  selected_car <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderggiraph({
    p <- ggplot(aes(x=Sepal.Length,y=Petal.Length, data_id = Species ),data=iris) +
      geom_point_interactive(size = 3) + theme_minimal()
    ggiraph(code = print(p),
            hover_css = "fill:red;cursor:pointer;",
            selection_type = "single",
            selected_css = "fill:orange;", width = 1)
  })

  observe( {
    value <- selected_car()
    updateTextInput(session = session, "selpoint", value = paste0(value, collapse = ",") )
  })

})
