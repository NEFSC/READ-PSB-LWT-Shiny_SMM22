#################################################
## User Interface file for Example App SMM2022 ##
## Leah Crowe & Hansen Johnson                 ##
#################################################

fluidPage(
  useShinyjs(),
  titlePanel("Example App landing page"),
  splitLayout(radioButtons("datatype", "Data:", choices = c("Default", "Custom"), selected = "Default", inline = FALSE),
              textInput("filepathinput", (HTML(paste("Data filename:", '<br/>', "Example, './data/Custom_f_210307.csv'")))),
              actionButton("rawupload", "Upload data"),
              width = 3),
              br(),
              textOutput("error"),
              br(),
  tabsetPanel(type = "tabs",
              tabPanel("Data table",
                       br(),
                       wellPanel(
                         div(rHandsontableOutput("upload_data_table", height = 500), style = "font-size:80%")),
                       actionButton("export_map", "Export & Map")),
              tabPanel("Map",
                       splitLayout(uiOutput("species")),
                       tableOutput("speciestab"),
                       leafletOutput("data_map"),
                       downloadButton("report", "Download Report")
              )
  )
)