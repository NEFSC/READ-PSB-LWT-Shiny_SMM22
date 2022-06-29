######################################
## App file for Example App SMM2022 ##
##   Leah Crowe & Hansen Johnson    ##
######################################

####################
## User interface ##
####################

#if cred file exists, then use shiny manager for username and password, otherwise, just start the app
if (file.exists('./scripts/creds.R') == TRUE){
  ui = shinymanager::secure_app(source('./scripts/example_ui.R', local = TRUE)$value)
} else {
  ui = source('./scripts/example_ui.R', local = TRUE)$value
}

############
## Server ##
############

	## Define server logic 
	server = function(input, output, session) {
	  
	  #### if credentials are used
	  res_auth <- shinymanager::secure_server(
	    check_credentials = shinymanager::check_credentials(credentials),
	    timeout = 120
	  )

	  output$auth_output <- renderPrint({
	    reactiveValuesToList(res_auth)})
	  ####
	  
	  ## server file
	  source('./scripts/example_server.R', local = TRUE)$value
		
	}

#########################
## Create Shiny object ##
#########################

	shinyApp(ui = ui, server = server, options = list(height = 1080))
