blankIfNull <- function(log.entry){
  if(!length(log.entry)){
    log.entry <- NULL
  }
  if(is.null(log.entry)){
    log.entry <- NA
  }
  if(is.na(log.entry)){
    log.entry <- ""
  }
  log.entry <- as.character(log.entry)
  return(log.entry)
}

logEvent <- function(session, url.parameters, event.variables,
                     log.spreadsheet=gs_key("1oIjzlDp8j617Ngqo9BCJtkrL192OzgTzPdwFDH34rqM")){
  
  if(offline){
    return()
  }
  params <- url.parameters[names(url.parameters)!="survey"]
  redirect.url = blankIfNull(paste(lapply(names(params), function(x, params) paste(c(x,params[x]), collapse = "="), params=params), collapse="&"))
  survey = blankIfNull(url.parameters$survey)
  event = blankIfNull(event.variables$event)
  notes = blankIfNull(event.variables$notes)
  time = blankIfNull(Sys.time())
  log.row = c(time, survey, event, notes, redirect.url)
  print(log.row)
  gs_add_row(ss=log.spreadsheet, ws="Log", input=log.row)
}

parseURL <- function(query, variable, parameters){
  if (!is.null(query[[variable]])) {
    print(paste0("reassigning ",variable," to be ",query[[variable]]))
    parameters[[variable]] <- ifelse(variable != "survey", as.numeric(query[[variable]]), query[[variable]])
  }
  return(parameters)
}

# parseURL = function(variable, parameters, query, session){
#   if (!is.null(query[[variable]])) {
#     if (parameters[[variable]] != as.numeric(query[[variable]])){
#       # updateNumericInput(session, variable, value = query[[variable]])
#       print(paste0("reassigning ",parameters[[variable]]," to be ",query[[variable]]))
#       parameters[[variable]] <<- as.numeric(query[[variable]])
#     }
#   }
#   # return(parameters)
# }

renderMyDocument <- function(variables, mdType, 
                             log.spreadsheet=gs_key("1oIjzlDp8j617Ngqo9BCJtkrL192OzgTzPdwFDH34rqM")) { #, r_env=parent.frame()
  if(is.null(variables$survey)){
    print("survey is null")
    survey.name <- "ExampleReport"
  } else {
    survey.name <- variables$survey
  }
  
  if(!offline){
    reference.data <- data.frame(gs_read(ss=log.spreadsheet, ws = "Reference"))
    dd <- reference.data[reference.data$Survey==survey.name,c("Parameter","Value")]
    if(nrow(dd)){
      ref.variables <- setNames(dd$Value, paste0("ref.",as.character(dd$Parameter)))
      variables <- c(variables, ref.variables)
    }
  }
  
  report.name = paste0(survey.name,".Rmd")
  src <- normalizePath(report.name)
  # temporarily switch to the temp dir, in case you do not have write
  # permission to the current working directory
  # file.copy(from, to, overwrite = recursive, recursive = FALSE,
  #           copy.mode = TRUE, copy.date = FALSE)
  tempReport <- file.path(tempdir(), report.name)
  file.copy(report.name, tempReport, overwrite = TRUE)
  template.name <- "lfp_template.tex"
  if(mdType=="PDF"){
    tempTemplate <- file.path(tempdir(), template.name)
    file.copy(template.name, tempTemplate, overwrite = TRUE)
    logo.name <- "LFP_vertical_tagline.png"
    tempLogo <- file.path(tempdir(), logo.name)
    file.copy(logo.name, tempLogo, overwrite = TRUE)
    
    if(!dir.exists(file.path(tempdir(),'fonts'))){
      dir.create(file.path(tempdir(),'fonts'))
    }
    font.path = "fonts/Montserrat-Regular.otf"
    file.copy(from=font.path, #paste0("/fonts/",list.files(path="./fonts"))
              to=file.path(tempdir(),font.path),
              overwrite = TRUE)
    
  }
  # owd <- setwd(tempdir())
  # on.exit(setwd(owd))
  # file.copy(src, report.name)
  # file.copy('report.Rmd')
  # out <- renderMyDocument(variables=parameters, mdType = "PDF")
  # file.rename(out, file)
  # http://stackoverflow.com/questions/37018983/how-to-make-pdf-download-in-shiny-app-response-to-user-inputs
  # https://shiny.rstudio.com/articles/generating-reports.html
  # rmarkdown::render(tempReport, output_file = file,
  #                   params = params,
  #                   envir = new.env(parent = globalenv())
  # )
  rmarkdown::render(tempReport, params = variables, 
                    envir = new.env(parent = globalenv()), 
                    switch(mdType, 
            PDF = pdf_document(latex_engine = "lualatex", template=tempTemplate), HTML = html_document(), Word = word_document(), Markdown = md_document()))
  # return(doc)
}

source(".email")
emailReport <- function(email.params){
  send.mail(from = email.credentials$email.address,
            to = email.params$to,
            subject <- "Survey Report",
            body <- "Please see attached for a copy of your survey report.",
            smtp = list(host.name = "smtp.gmail.com", port = 465, user.name = email.credentials$user.name, passwd = email.credentials$passwd, ssl = TRUE),
            authenticate = TRUE,
            html = TRUE,
            send = TRUE,
            attach.files = c(email.params$report),
            file.names = c("Survey_Report.pdf"), # optional parameter
            file.descriptions = c("Your Survey Report"), # optional parameter
            debug = TRUE
            )
}

emailMyDocument <- function(parameters, email.address){
  out <- renderMyDocument(variables=parameters, mdType = "PDF")
  email.params <- list(to=email.address, report=out)
  emailReport(email.params)
}