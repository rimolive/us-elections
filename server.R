library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(jsonlite)

set.seed(100)

#states.data = readLines("data/us-states.geojson") %>% paste(collapse = "\n") %>% fromJSON(simplifyVector = FALSE)
counties.data <- rgdal::readOGR("data/us-counties.geojson", "OGRGeoJSON")

pal <- colorQuantile("plasma", 1:100)

function(input, output, session) {

  # Create the map
  output$map <- renderLeaflet({
    leaflet(counties.data) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
      # If using readLines()
      # addGeoJSON(counties.data)
      # If using rgdal
      addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                  fillColor = ~pal(CENSUSAREA),
                  label = ~paste0(NAME, ": ", formatC(CENSUSAREA, big.mark = ","))) %>%
      addLegend(pal = pal, values = ~CENSUSAREA, opacity = 1.0,
                labFormat = labelFormat(transform = function(x) x))
  })

}

