    library(shiny)
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
