## app.R ##
# simple shiny app for mapping example survey data from Leah
# modified from: https://rstudio.github.io/leaflet/shiny.html

# setup -------------------------------------------------------------------

library(shiny)
library(leaflet)
library(tidyverse)

# global variables --------------------------------------------------------

# list species codes
species_list <- c("Right whale" = "RIWH", "Fin whale" = "FIWH", "Humpback whale" = "HUWH")

# list species colors
species_colors <- c('RIWH' = 'red', 'FIWH' = 'blue', 'HUWH' = 'grey')

# set up color palette plotting
pal <- colorFactor(levels = species_list, palette = species_colors)

# ui ----------------------------------------------------------------------

ui <- bootstrapPage(

  # fill entire page
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),

  # leaflet map
  leafletOutput("map", width = "100%", height = "100%"),

  # input panel
  absolutePanel(top = 10, right = 10,
                fileInput("file", label = "File input"),
                selectInput("species", "Species",
                            choices = species_list,
                            selected = species_list,
                            multiple = TRUE),
                checkboxInput("effort", "Show effort", TRUE),
                plotOutput("plot")
  )
)

# server ------------------------------------------------------------------

server <- function(input, output, session) {

  # read in data
  d <- reactive({
    req(input$file)
    file <- input$file
    read_csv(file$datapath, show_col_types = FALSE)
  })

  # extract sightings
  sig <- reactive({
    d() %>% filter(SPCODE %in% input$species)
  })

  # make basemap
  output$map <- renderLeaflet({

    leaflet(d()) %>%
      addTiles() %>%
      fitBounds(~min(LONGITUDE), ~min(LATITUDE), ~max(LONGITUDE), ~max(LATITUDE)) %>%
      addLegend(position = "bottomright",
                pal = pal,
                values = species_list)
  })

  # trackline observer
  observe({

    # define proxy and remove effort group
    proxy <- leafletProxy("map")
    proxy %>% clearGroup("effort")

    # add effort if selected
    if (input$effort) {
      proxy %>% addPolylines(data=d(),
                             group = 'effort',
                             lng=~LONGITUDE,
                             lat=~LATITUDE,
                             weight = 2,
                             smoothFactor = 1,
                             color = 'black')
    }
  })

  # species observer
  observe({

    # define proxy and clear group
    proxy <- leafletProxy("map")
    proxy %>% clearGroup('sightings')

    # add sightings markers
    proxy %>%
      addCircleMarkers(
        data = sig(),
        ~LONGITUDE,
        ~LATITUDE,
        group = 'sightings',
        radius = 4,
        fillOpacity = 0.9,
        stroke = TRUE,
        col = 'black',
        weight = 0.5,
        fillColor = ~pal(SPCODE),
        popup = ~paste(sep = "<br/>" ,
                       paste0("Species: ", SPCODE),
                       paste0("Time: ", as.character(format(DATETIME_ET, '%H:%M:%S ET'))),
                       paste0("Position: ", as.character(LATITUDE), ', ', as.character(LONGITUDE)))
      )
  })

  # barplot -----------------------------------------------------------------

  # make simple histogram
  output$plot <- renderPlot({
    ggplot(sig())+
      geom_bar(aes(x = SPCODE, fill = SPCODE)) +
      scale_fill_manual(values = species_colors) +
      theme_bw()
  })

}

# run shiny app
shinyApp(ui, server)
