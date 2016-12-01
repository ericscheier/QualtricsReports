
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# features to add:
#   - email form
#   - download button
#   - report visualization

library(shiny)

shinyUI(fluidPage(
  
  # error handling
  # tags$head(
  #   tags$style(HTML("
  #   .shiny-output-error-validation {
  #   color: red;
  #   }
  #   "))
  # ),

  # Application title
  titlePanel("Survey Report"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      textInput("email", "Email", placeholder = "your@email.com"),
      actionButton("email.button",label = "Email me a copy"),
      downloadButton('report', label="Download PDF"),
      # This makes web page load the JS file in the HTML head.
      # The call to singleton ensures it's only included once
      # in a page. It's not strictly necessary in this case, but
      # it's good practice.
      singleton(
        tags$head(tags$script(src = "message-handler.js"))
      )
      # textOutput('parameters')
    ),

    # Show a plot of the generated distribution
    mainPanel(
      uiOutput('markdown')
    )
  )
))
