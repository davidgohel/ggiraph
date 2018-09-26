library(ggplot2)
library(ggiraph)
library(stringr)
library(dplyr)
library(DT)
library(ggraph)
library(flextable)

ggg <- ggraph(g, layout = 'lgl') +
  geom_edge_fan(alpha = 0.1, edge_width = .2) +
  geom_point_interactive(aes(x, y,
                             tooltip = Name, data_id = Name,
                             size = Package), alpha = .7, color = "#006699" ) +
  theme_graph() +
  theme(legend.position = "bottom")


shinyServer(function(input, output, session) {

  output$plot <- renderggiraph({
    tooltip_css <- "background-color:white;color:#333333;font-style:italic;padding:5px;border-radius:3px 4px;border: 1pt #333333 solid;"
    hover_css <- "stroke:#333333;stroke-width:1pt;cursor:pointer;"
    selected_css <- "stroke:#333333;fill-opacity=1;fill:red;stroke-width:1pt;"

    ggiraph(ggobj = ggg, width_svg = 8, height_svg = 6,
            tooltip_extra_css = tooltip_css,
            hover_css = hover_css,
            selection_type = "multiple",
            selected_css = selected_css, width = 1, zoom_max = 4)
  })

  subset_data <- reactive({
    shiny::req(input$plot_selected)
    auth_rexp <- sprintf( "(%s)", paste(input$plot_selected, collapse = "|") )
    tab <- pdb %>% filter(str_detect(Author, pattern = auth_rexp ))
    tab
  })
  observe({
    tab <- subset_data()
    updateSliderInput(session = session, inputId = "rowsel_max", min = 1, max = nrow(tab), value = min( 20, nrow(tab) ) )
    updateSliderInput(session = session, inputId = "rowsel_min", min = 1, max = nrow(tab), value = 1 )
  })

  output$subset <- renderUI({
    shiny::req(subset_data())
    tab <- subset_data() %>%
      mutate(Author = str_trunc(Author, width = 150) )
    if( input$rowsel_min > 0 && input$rowsel_max > 0 && input$rowsel_min <= input$rowsel_max){
      tab <- tab[input$rowsel_min:input$rowsel_max, , drop = FALSE]
    }

    tab %>%
      regulartable() %>% theme_vanilla() %>% autofit() %>%
      width(j = c("Title", "Author"), width = 3) %>%
      htmltools_value()
  })

  observeEvent(input$selpoint, {

    auth_rexp <- sprintf( "(%s)", paste(input$selpoint, collapse = "|") )
    sel <- pdb %>% filter(str_detect(Author, pattern = auth_rexp ))

    if( nrow(sel) > 0 ){
      if( is.null(input$plot_selected) || !all( input$plot_selected %in% input$selpoint ) ){
        session$sendCustomMessage(type = 'plot_set',
                                  message = as.list(c(input$plot_selected, input$selpoint)))
        }
    }
  })

})
