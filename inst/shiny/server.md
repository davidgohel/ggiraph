    library(shiny)
    shinyServer(function(input, output) {
    
      state <- reactive({
        input$state
      })
    
      output$plot <- renderggiraph({
        ggiraph(fun=print, x = gg_map, width = 8, height = 6)
      })
    
      output$datatab <- renderDataTable({
        out <- crimes
        if(!is.null( sel <- state()) )
          out <- crimes[crimes$state==sel,]
        out
        })
    
    })
