######################################
## App file for Example App SMM2022 ##
## Leah Crowe & Hansen Johnson      ##
######################################


#############
##  Global ##
#############

source('./scripts/global_libraries.R', local = TRUE)$value

# if (file.exists('./scripts/creds.R') == TRUE){
#   source('./scripts/creds.R', local = TRUE)$value}

####################
## User interface ##
####################

ui <- dashboardPage(
  dashboardHeader(title = "SMM 'shiny' 2022"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem(icon = icon("fish"),"Example App", tabName = "Example_App_tab"),
      menuItem(icon = icon("question-circle"),text = "Wiki", href = "https://github.com/NEFSC/READ-PSB-LWT-Shiny_SMM21/wiki"),
      menuItem(icon = icon("icons"), text = "Icons", href = "https://fontawesome.com/icons")
    )
  ),
  ## Body content
  dashboardBody(tagList(img(src = 'SMM2022-Logo-1500px-1024x591.PNG', width = "50%",),br()),
    tabItems(
      # First tab content
      tabItem(tabName = "Example_App_tab",
              source('./scripts/example_app.R', local = TRUE)$value
      )
      #,
      # 
      # # Second tab content
      # tabItem(tabName = "DMA",
      #         source('./scripts/DMAapp.R', local = TRUE)$value
      # ),
      
    )
  )
)

#################
## Call server ##
#################

server = function(input, output, session) {}

################
## Launch app ##
################

shinyApp(ui, server)
