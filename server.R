
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# https://github.com/daattali/advanced-shiny/tree/master/url-inputs
# http://127.0.0.1:5026/?name=ramon&age=30
# http://127.0.0.1:5026/?1=2.6&2=4.5&3=2.5&4=4.5&5=5&6=1.25&7=5&8=5&9=2&10=2&11=2&12=4&13=1.4&14=4&15=5&16=3.8&17=3&18=3&19=5&20=3.6&21=2.3&22=5

library(shiny)
library(knitr)
library(rmarkdown)

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
  
  renderMyDocument <- function(name, age, mdType) {
    rmarkdown::render("report.Rmd", params = list(
      name = name,
      age = age
    ), switch(mdType, 
              PDF = pdf_document(), HTML = html_document(), Word = word_document(), Markdown = md_document()))
  }
  
  output$markdown <- renderUI({
    includeMarkdown(renderMyDocument(name=input$name, age=input$age, mdType = "Markdown"))
    # HTML(markdown::markdownToHTML(knit('report.Rmd', quiet = TRUE)))
    # includeMarkdown('report.Rmd')
  })
  
  
  output$report = downloadHandler(
    filename = function() {"survey_report.docx"},
    content = function(file) {
      src <- normalizePath('report.Rmd')
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd')
      out <- renderMyDocument(name=input$name, age=input$age, mdType = "Word")# "PDF")
      file.rename(out, file)
    }#,
    #contentType = "application/docx"
    
  )

})