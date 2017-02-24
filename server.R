
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

# sudo apt-get install r-cran-rjava

# https://github.com/daattali/advanced-shiny/tree/master/url-inputs
# http://127.0.0.1:5026/?name=ramon&age=30
# http://127.0.0.1:5026/?1=2.6&2=4.5&3=2.5&4=4.5&5=5&6=1.25&7=5&8=5&9=2&10=2&11=2&12=4&13=1.4&14=4&15=5&16=3.8&17=3&18=3&19=5&20=3.6&21=2.3&22=5

# /?survey=report&one=10&two=20&three=30&four=40&five=50
# https://github.com/rpremraj/mailR


library(shiny)
library(shinyjs)
library(knitr)
library(rmarkdown)
library(mailR)
library(googlesheets)
# library(sysfonts)

# font.add.google("Montserrat", "Montserrat")
# dir.create('fonts') 
# http://fonts.googleapis.com/css?family=Montserrat
# download.file("http://fonts.gstatic.com/s/montserrat/v9/zhcz-_WihjSQC0oHJ9TCYPk_vArhqVIZ0nv9q090hN8.woff2",'fonts/Montserrat')
# system('fc-cache -f fonts')

source("helpers.R")
# options(timeout = 90)
# For RStudio debugging only, in order to prevent logging via gsheets which takes time
offline <<- TRUE #FALSE

if(!offline){
  suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))
}




shinyServer(function(input, output, session) {
  
  useShinyjs(html = TRUE)
  hide(id = "emailing-content")
  
  parameters <- reactiveValues()
  
  observe({
    # parameters <<- list()#one=1,two=1,three=1,four=1)
    query <- parseQueryString(session$clientData$url_search)
    print("reevaluating URL")
    for(variable in names(query)){
      parameters <- parseURL(variable=variable, query=query, parameters=parameters)
    }
    logEvent(session=session, url.parameters=reactiveValuesToList(parameters), event.variables=list(event="visit",notes=""))
    print(reactiveValuesToList(parameters))
    # parseURL(query=query, parameters=parameters, variable="one", session=session)

  })
  
  output$markdown <- renderUI({
    md <- includeMarkdown(renderMyDocument(variables=reactiveValuesToList(parameters), mdType = "Markdown"))
    hide(id = "loading-content")
    return(md)
  })
  
  output$report = downloadHandler(
    filename = function() {"survey_report.pdf"},
    content = function(file) {
      # src <- normalizePath('report.Rmd')
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      # owd <- setwd(tempdir())
      # on.exit(setwd(owd))
      # file.copy(src, 'report.Rmd')
      # file.copy('report.Rmd')
      logEvent(session=session, url.parameters=reactiveValuesToList(parameters), event.variables=list(event="download",notes=""))
      out <- renderMyDocument(variables=reactiveValuesToList(parameters), mdType = "PDF")
      file.rename(out, file)
    },
    contentType = "application/pdf"
    
  )
  
  observe({
    # Take a dependency on input$email.button
    if (input$email.button == 0)
      return(NULL)
    # Use isolate() to avoid dependency on input$email.button
    isolate({
      show(id = "emailing-content")
      # validate(
      #   need(try(emailMyDocument(parameters=parameters, email.address=input$email)),
      #        'Error sending email, please try again.')
      # )
      tryCatch(emailMyDocument(parameters=reactiveValuesToList(parameters), email.address=input$email),
               error=function(e) {
                 print("Email unsuccessful")
                 session$sendCustomMessage(type = 'testmessage',
                                           message = 'Error sending email, please try again.')
                 },
               finally = {hide(id = "emailing-content")}
               )
      
      logEvent(session=session, url.parameters=reactiveValuesToList(parameters), event.variables=list(event="email",notes=input$email))
    })
  })

})