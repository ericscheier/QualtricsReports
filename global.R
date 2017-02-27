
library(shiny)
library(shinyjs)
library(knitr)
library(rmarkdown)
library(mailR)
library(googlesheets)

source("settings.txt")
source("helpers.R")
log.spreadsheet.id <- app.settings$log.spreadsheet.id
# options(timeout = 90)
# For RStudio debugging only, in order to prevent logging via gsheets which takes time
offline <<- app.settings$offline.for.debugging #TRUE #FALSE

if(!offline){
  suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))
}

shiny::addResourcePath("shinyjs", system.file("srcjs", package = "shinyjs"))