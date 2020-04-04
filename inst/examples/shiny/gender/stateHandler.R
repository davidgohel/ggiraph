library(shiny)

StateHandlerUI <- function(id, label, choices) {
  ns <- NS(id)

  checkboxGroupInput(inputId = ns("chk"),
                     label = label,
                     choices = choices)
}

StateHandler <- function(input,
                         output,
                         session,
                         plotInput,
                         messageId) {
  plot_data <- reactive({
    v <- do.call(plotInput, list())
    if (is.null(v)) {
      character(0)
    } else
      v
  })

  chk_data <- debounce(reactive({
    if (is.null(input$chk)) {
      character(0)
    } else
      input$chk
  }), 200)

  ignore_plot_data <- FALSE

  ignore_chk_data <- FALSE

  observeEvent(plot_data(), {
    if (!ignore_plot_data) {
      # message(session$ns(" "), "Updating check")
      ignore_chk_data  <<- TRUE
      updateCheckboxGroupInput(session,
                               'chk',
                               selected = plot_data())
    }
    ignore_plot_data <<- FALSE

  })

  observeEvent(chk_data(), {
    if (!ignore_plot_data) {
      # message(session$ns(" "), "Updating plot")
      ignore_chk_data  <<- TRUE
      session$sendCustomMessage(type = messageId, message = chk_data())
    }
    ignore_chk_data <<- FALSE
  })

  return(list(plot_data, chk_data))
}
