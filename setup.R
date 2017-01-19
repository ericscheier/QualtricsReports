# Run this script to setup user-specified parameters before uploading to shinyapps.io
library(googlesheets)
token <- gs_auth(cache = FALSE)
gd_token()
saveRDS(token, file = "googlesheets_token.rds")

# If you haven't connected your Rstudio to Shinyapps.io, use the following commented commands
# require('devtools')
# devtools::install_github('rstudio/shinyapps')
# require('shinyapps')
# shinyapps::setAccountInfo(name='yourUserNameHere', token='yourTokenHere', secret='yourSecretHere')

library(rsconnect)
deployApp()
