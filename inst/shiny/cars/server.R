library(ggiraph)
library(maps)


shinyServer(function(input, output, session) {

  selected_car <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderggiraph({
    p <- ggplot(aes(x=wt,y=mpg, data_id = row.names(mtcars) ),data=mtcars) +
      geom_point_interactive() + theme_bw()
    ggiraph(code = print(p),
            hover_css = "fill:orange;r:4pt;cursor:pointer;",
            selection_type = "single",
            zoom_max = 6,
            selected_css = "fill:red;r:4pt;")
  })

  observe( {
    value <- selected_car()
    updateTextInput(session = session, "title", value = paste0(value, collapse = ",") )
  })
})
