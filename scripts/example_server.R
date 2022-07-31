#########################################
## server file for Example App SMM2022 ##
## Leah Crowe & Hansen Johnson         ##
#########################################

#disable some buttones to begin
disable("export_map")
disable("report")

#create blank reactive lists to move between actions
source('./scripts/reactive.R', local = TRUE)$value

#"Upload data" button is pressed
observeEvent(input$rawupload,{
  
  #clear r hands on table if button pressed again
  output$upload_data_table = NULL
  
  #path to default data
  if (input$datatype == 'Default'){
    reactive_values$path<-'./data/Default_f_220529.csv'
  #path to custom data detailed by user input  
  } else if (input$datatype == 'Custom'){
    reactive_values$path<-input$filepathinput
  }
  print(reactive_values$path)
  
#check that "path" has been defined so that the app doesn't crash on start 
  if (!is.null(reactive_values$path)) {
    print("exists")
  
      #read in data
      upload_data<-read.csv(reactive_values$path, header = T, stringsAsFactors = F)
      upload_data$DATETIME_ET<-ymd_hms(upload_data$DATETIME_ET) #declare datetime format for data
      
      #options for dropdowns in rHOT
      vis = 0:35
      beau = seq(0, 12, by = 0.1)
      cloud = c(1:4,9)
      glare = 0:3
      qual = c("e","g","m","p","x")
      ahead = 0:360
      obspos = c("L","C","R")
      ang = c(0:89,89.1,89.2,89.3,89.4,89.5,89.6,89.7,89.8,89.9,90)
      cue = c(1:5,8,9)
      
      upload_data[is.na(upload_data)] <- ""
      
      #make all columns character type for rHOT
      upload_data<-upload_data %>%
        mutate(across(everything(), as.character))
      
      #convert data table to rHOT, only including columns that differ from default declared below
      upload_data_table<-rhandsontable(upload_data, readOnly = TRUE)%>% #default columns to read only
        hot_table(highlightCol = TRUE, highlightRow = TRUE)%>%
        hot_cols(columnSorting = TRUE)%>%
        hot_col("DATETIME_ET", width = 150)%>%
        ##format only allows up to 4 decimal places
        hot_col("LATITUDE", format = "00.00000")%>% 
        hot_col("LONGITUDE", format = "00.00000")%>%
        hot_col("ALTITUDE", format = "0")%>%
        hot_col("HEADING", format = "000")%>%
        hot_col("SPEED", format = "000")%>%
        hot_col("VISIBILTY_NM",format = "0",readOnly = FALSE, type = "dropdown", source = vis)%>%
        hot_col("BEAUFORT",format = "0.0",readOnly = FALSE, type = "dropdown", source = beau)%>%
        hot_col("CLOUD_CODE",format = "0",readOnly = FALSE, type = "dropdown", source = cloud)%>%
        hot_col("GLARE_L",format = "0",readOnly = FALSE, type = "dropdown", source = glare)%>%
        hot_col("GLARE_R",format = "0",readOnly = FALSE, type = "dropdown", source = glare)%>%
        hot_col("QUALITY_L",readOnly = FALSE, type = "dropdown", source = qual)%>%
        hot_col("QUALITY_R",readOnly = FALSE, type = "dropdown", source = qual)%>%
        hot_col("SIGHTING_NUMBER",format = "0",readOnly = FALSE)%>%
        hot_col("SPCODE",readOnly = FALSE)%>%
        hot_col("GROUP_SIZE",format = "0",readOnly = FALSE)%>%
        hot_col("CALVES",readOnly = FALSE)%>%
        hot_col("ACTUAL_HEADING", readOnly = FALSE, format = "000", type = "dropdown", source = ahead)%>%
        hot_col("OBSERVER",readOnly = FALSE)%>%
        hot_col("OBS_POSITION",readOnly = FALSE, type = "dropdown", source = obspos)%>%
        hot_col("ANGLE",readOnly = FALSE, type = "dropdown", source = ang)%>%
        hot_col("CUE",readOnly = FALSE, type = "dropdown", source = cue)%>%
        hot_col("B1_FINAL_CODE",format = "00",readOnly = FALSE)%>%
        hot_col("B2_FINAL_CODE",format = "00",readOnly = FALSE)%>%
        hot_col("B3_FINAL_CODE",format = "00",readOnly = FALSE)%>%
        hot_col("B4_FINAL_CODE",format = "00",readOnly = FALSE)%>%
        hot_col("B5_FINAL_CODE",format = "00",readOnly = FALSE)%>%
        hot_col("PHOTOS",format = "0",readOnly = FALSE)%>%
        hot_col("EFFORT_COMMENTS",readOnly = FALSE)%>%
        hot_col("SIGHTING_COMMENTS",readOnly = FALSE)%>%
        hot_col("EDIT1",readOnly = FALSE)%>%
        hot_col("EDIT2",readOnly = FALSE)%>%
        hot_col("EDIT3",readOnly = FALSE)
      
      output$upload_data_table = renderRHandsontable({upload_data_table})
      #enable button for map generation and data export
      enable("export_map")  
   
} else if (is.null(reactive_values$path)) {  #check that path is valid 
  output$error<-renderText({"File not found"})
} 


})

#"Export & Map" button is pressed
observeEvent(input$export_map,{
  
  #read in any edits from rHOT in app
  edited_data = hot_to_r(input$upload_data_table)
  #write edited data to output file
  write.csv(edited_data, paste0('./output/edit_',basename(reactive_values$path)), na = "", row.names = FALSE)
  
  edited_data$LATITUDE<-as.numeric(edited_data$LATITUDE)
  edited_data$LONGITUDE<-as.numeric(edited_data$LONGITUDE)
  
  sightings<-edited_data%>%
    filter(SPCODE != '')
  
  #summarise counts of species sighted
  sig_table<-sightings%>%
    dplyr::select("SPCODE","GROUP_SIZE")%>%
    group_by(SPCODE)%>%
    dplyr::summarise(GROUP_SIZE = sum(as.numeric(GROUP_SIZE)))%>%
    dplyr::rename("Species" = "SPCODE", "Total number" = "GROUP_SIZE")%>%
    as.data.frame()
  print(sig_table)
  
  #declare a static legend so that species are always the same color
  factpal <- colorFactor(palette = "Set1", domain = sightings$SPCODE)
  
  data_map<-leaflet(data = edited_data) %>% 
    addEsriBasemapLayer(esriBasemapLayers$Oceans, autoLabels=TRUE) %>%
    addPolylines(lng=~LONGITUDE, lat = ~LATITUDE, weight = 2, color = "black") %>%
    addCircleMarkers(lng = ~sightings$LONGITUDE, lat = ~sightings$LATITUDE, color = ~factpal(sightings$SPCODE), stroke = FALSE, fillOpacity = 2, radius = 5) %>%
    addLegend(pal = factpal, values = sightings$SPCODE, opacity = 1)
  
  output$data_map = renderLeaflet({print(data_map)})
  #save leaflet map to html file that gets rewritten each run of the app
  htmlwidgets::saveWidget(data_map, "temp.html", selfcontained = FALSE)
  enable("report")
  
  #Report output
  output$report<-downloadHandler(
    #name of output report file
    filename = paste0("Report_",Sys.Date(),".pdf"),
    content = function(file) {
        #report template
        tempReport<-file.path("./scripts/example_report.Rmd")
        #save leaflet map as static png
        webshotpath<-paste0(getwd(),"/data_map.png")
        webshot::webshot("temp.html", file = webshotpath)
        print("webshot")
        #copy report template
        file.copy("example_report.Rmd", tempReport, overwrite = FALSE)
        #render copy of report template as r markdown file
        rmarkdown::render(tempReport, output_file = file,
                          params = list(sig_table = sig_table, webshotpath = webshotpath), #pass parameters from shiny into report
                          envir = new.env(parent = globalenv()))
    })
})

