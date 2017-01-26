
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

shinyUI(fluidPage(theme = "lfp_style.css",
                  
                  fluidRow(
                    column(2,
                           fluidRow(img(src='LFP_vertical_tagline.png')),
                           fluidRow("Contents")
                           ),
                    column(10,
                           # Application title
                           h1("Your Personal Report"),
                           fluidRow(
                             column(6,
                                    #sidebarPanel(
                                    textInput("email", label=NULL, placeholder = "your@email.com", width='100%')#,
                                    #offset=3
                             ),
                             column(3,
                                    actionButton("email.button",label = "Email me a copy", width='100%'),
                                    # This makes web page load the JS file in the HTML head.
                                    # The call to singleton ensures it's only included once
                                    # in a page. It's not strictly necessary in this case, but
                                    # it's good practice.
                                    singleton(
                                      tags$head(tags$script(src = "message-handler.js"))
                                    )
                             ),
                             column(3,
                                    downloadButton('report', label="Download PDF")
                           )
                           )
                    ),
                    column(10,
                           # img(src='LFP_horizontal_tagline.png', align = "right"),
                           uiOutput('markdown')
                    )
                  ),
                  fluidRow(
                    # column(3,
                    #        ""
                    # ),
                    
                           #)
                  ),
                  fluidRow(
                    
                  )
  )
)