library(leaflet)

navbarPage("US Elections", id="nav",

  tabPanel("Interactive Map",
    div(class="outer",
      tags$head(
        includeCSS("css/styles.css"),
        includeScript("js/gomap.js")
      ),
      
      leafletOutput("map", width="100%", height="100%"),
      
      absolutePanel(id="controls", class="panel panel-default", fixed=TRUE,
          draggable=TRUE, top=60, left="auto", right=20, bottom="auto",
          width=330, height="auto",
        
        h2("US Elections")
        
      ),
      tags$div(id="cite",
        'Data compiled for ', tags$em('US election 2016: How to download county-level results data'), ' by Simon Rogers.'
      )
    )
  ),
  
  tabPanel("Data Explorer",
    hr(),
    DT::datatable(us_elections_history)
  ),
  
  conditionalPanel("false", icon("crosshair"))
)
