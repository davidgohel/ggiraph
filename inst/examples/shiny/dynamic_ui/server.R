library(ggplot2)
library(ggiraph)

max_plots <- 5


pts <- 1:10
server <- function(input, output) {

  # Insert the right number of plot output objects into the web page
  output$plots <- renderUI({
    plot_output_list <- lapply(seq_len(input$n), function(i) {
      plotname <- paste("plot", i, sep = "")
      div(
        girafeOutput(plotname, width = "100%", height = "450px"),
        hr()
      )
    })

    # Convert the list to a tagList - this is necessary for the list of items
    # to display properly.
    do.call(tagList, plot_output_list)
  })

  # Call renderPlot for each one. Plots are only actually generated when they
  # are visible on the web page.
  for (i in seq_len(max_plots)) {
    # Need local so that each item gets its own number. Without it, the value
    # of i in the renderPlot() will be the same across all instances, because
    # of when the expression is evaluated.
    local({
      my_i <- i
      plotname <- paste("plot", my_i, sep = "")

      output[[plotname]] <- renderGirafe({
        plotdata <- data.frame(x = pts, y = pts, label = letters[pts])
        g <- ggplot(plotdata, aes(x = x, y = y, data_id = label)) +
          geom_point_interactive(size = 4)
        x <- girafe(
          ggobj = g,
          options = list(opts_sizing(rescale = TRUE ))
        )
        x
      })

    })
  }
}
