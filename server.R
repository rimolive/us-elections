library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(jsonlite)

set.seed(100)

#states.data = readLines("data/us-states.geojson") %>% paste(collapse = "\n") %>% fromJSON(simplifyVector = FALSE)
states.data <- rgdal::readOGR("data/us-states.geojson", "OGRGeoJSON")

pal <- colorQuantile("plasma", 1:100)

function(input, output, session) {

  # Create the map
  output$map <- renderLeaflet({
    leaflet(states.data) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
      # If using readLines()
      # addGeoJSON(states.data)
      # If using rgdal
      addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                  fillColor = ~pal(density),
                  label = ~paste0(name, ": ", formatC(density, big.mark = ","))) %>%
      addLegend(pal = pal, values = ~density, opacity = 1.0,
                labFormat = labelFormat(transform = function(x) x))
  })

}

