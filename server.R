
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# https://github.com/daattali/advanced-shiny/tree/master/url-inputs
# http://127.0.0.1:5026/?name=ramon&age=30
# http://127.0.0.1:5026/?1=2.6&2=4.5&3=2.5&4=4.5&5=5&6=1.25&7=5&8=5&9=2&10=2&11=2&12=4&13=1.4&14=4&15=5&16=3.8&17=3&18=3&19=5&20=3.6&21=2.3&22=5

library(shiny)

shinyServer(function(input, output, session) {
  
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['name']])) {
      updateTextInput(session, "name", value = query[['name']])
    }
    if (!is.null(query[['age']])) {
      updateNumericInput(session, "age", value = query[['age']])
    }
  })

  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })

})