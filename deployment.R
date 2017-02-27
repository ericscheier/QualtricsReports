source("settings.txt")
library(rsconnect)
setAccountInfo(name=app.settings$shiny.username, token=app.settings$shiny.token, secret=app.settings$shiny.secret)
deployApp(appName=app.settings$app.name, account=app.settings$shiny.username)
