# Run this script to setup user-specified parameters before uploading to shinyapps.io

# If you haven't already, install the required packages using the code below:
install.packages("shiny")
install.packages("shinyjs")
install.packages("knitr")
install.packages("rmarkdown")
install.packages("mailR")
install.packages("googlesheets")

# Authenticate with google to enable logging (make sure you use a google account that has write access to the logging document)
library(googlesheets)
token <- gs_auth(cache = FALSE)
gd_token()
saveRDS(token, file = "googlesheets_token.rds")

# If you haven't connected your Rstudio to Shinyapps.io, use the following commands
# You should only have to do this once
require('devtools')
devtools::install_github('rstudio/shinyapps')
require('shinyapps')
shinyapps::setAccountInfo(name='yourUserNameHere', token='yourTokenHere', secret='yourSecretHere')

# Deploy the application
library(rsconnect)
deployApp()
