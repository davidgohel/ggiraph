library(ggplot2)
library(ggiraph)
library(maps)


shinyServer(function(input, output, session) {

  selected_car <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderGirafe({
    p <- ggplot(aes(x=wt,y=mpg, data_id = row.names(mtcars) ),data=mtcars) +
      geom_point_interactive(size = 3) + theme_minimal()
    ggiraph(code = print(p),
            hover_css = "fill:red;cursor:pointer;",
            selection_type = "single",
            selected_css = "fill:red;")
  })

  observe( {
    value <- selected_car()
    updateTextInput(session = session, "selpoint", value = paste0(value, collapse = ",") )
  })

})