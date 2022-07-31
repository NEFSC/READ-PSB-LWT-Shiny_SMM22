#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny);library(leaflet);library(leaflet.esri);library(lubridate);library(dplyr)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Read in data and filter"),

    # Select species
    sidebarLayout(
        sidebarPanel(
            radioButtons("species_select",
                        "Select species:",
                        choices = c("FIWH", "HUWH", "RIWH"), selected = "RIWH", inline = FALSE),
            radioButtons("datatype", "Data:", choices = c("Default", "Custom"), selected = "Default", inline = FALSE),
            #textInput("filepathinput", (HTML(paste("Data filename:", '<br/>', "Example, './data/Custom_f_210307.csv'")))),
            actionButton("rawupload", "Upload data")
        ),

        # Show a map of the generated distribution
        mainPanel(
          leafletOutput("data_map")
        )
    )
)

# Define server logic required to render to a leaflet map
server <- function(input, output) {

  observeEvent(input$rawupload,{
    
  
    #path to default data
    if (input$datatype == 'Default'){
      path<-'./data/Default_f_220529.csv'
      #path to custom data detailed by user input  
    } else if (input$datatype == 'Custom'){
      path<-input$filepathinput
    }
    print(path)
    
    #check that "path" has been defined so that the app doesn't crash on start 
    if (exists("path")) {
      print("exists")
      #check that path is valid    
      if (!file.exists(path)) {
        output$error<-renderText({"File not found"})
      } else {
        
        #read in data
        upload_data<-read.csv(path, header = T, stringsAsFactors = F)
        upload_data$DATETIME_ET<-ymd_hms(upload_data$DATETIME_ET) #declare datetime format for data
        
      }
    }
    
    print(input$species_select)
    
    species_filter<-upload_data%>%
      filter(SPCODE == input$species_select)
    
    data_map<-leaflet(data = species_filter) %>% 
      addEsriBasemapLayer(esriBasemapLayers$Oceans, autoLabels=TRUE) %>%
      addCircleMarkers(lng = ~LONGITUDE, lat = ~LATITUDE, color = ~SPCODE, stroke = FALSE, fillOpacity = 2, radius = 5)
    
    output$data_map = renderLeaflet({print(data_map)})
    
  })
  }

# Run the application 
shinyApp(ui = ui, server = server)
