parseURL <- function(query, variable, parameters){
  if (!is.null(query[[variable]])) {
    print(paste0("reassigning ",variable," to be ",query[[variable]]))
    parameters[[variable]] <<- as.numeric(query[[variable]])
  }
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

renderMyDocument <- function(variables, mdType) { #, r_env=parent.frame()
  rmarkdown::render("report.Rmd", params = variables, 
                    # envir = r_env, 
                    switch(mdType, 
            PDF = pdf_document(), HTML = html_document(), Word = word_document(), Markdown = md_document()))
}

source(".email")
emailReport <- function(email.params){
  send.mail(from = "eric.scheier.test@gmail.com",
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
  
  # "eric.scheier.test@gmail.com"
  # "_+XXk^3BJxQ=_3eM"
  # https://www.google.com/settings/security/lesssecureapps
}