
# This is the server logic for a Shiny web application.
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