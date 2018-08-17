library(leaflet)

navbarPage("US Elections", id="nav",

  tabPanel("Interactive Map",
    div(class="outer",
      tags$head(
        includeCSS("css/styles.css"),
        includeScript("js/gomap.js")
      ),
      
      leafletOutput("map", width="100%", height="100%"),
      
      #absolutePanel(id="controls", class="panel panel-default", fixed=TRUE,
      #      draggable=TRUE, top=60, left="auto", right=20, bottom="auto",
      #      width=330, height="auto",
      #  h2("US Elections")
      #),
      tags$div(id="cite",
        'Data compiled for ', tags$a('US election 2016: How to download county-level results data',
                                     href='https://simonrogers.net/2016/11/16/us-election-2016-how-to-download-county-level-results-data/'),
        ' by Simon Rogers.'
      )
    )
  ),
  
  tabPanel("Data Explorer",
    fluidRow(
      column(3,
        selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
      ),
      column(3,
        conditionalPanel("input.states",
          selectInput("counties", "Counties", c("All counties"=""), multiple=TRUE)
        )
      )
    ),
    
    hr(),
    DT::dataTableOutput("us_elections_history")
  ),
  
  tabPanel("Visualizations",
    fluidRow(
      column(3,
             selectInput("elections", "Election Year", c("2008"="2008", "2012"="2012", "2016"="2016"))),
      column(3,
             checkboxInput("byparty", "Color by Party", FALSE))
    ),
    plotOutput("plot", height = 600)
  ),
  
  conditionalPanel("false", icon("crosshair"))
)
