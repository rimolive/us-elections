library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

set.seed(100)
counties.data <- rgdal::readOGR("data/us-elections.geojson", "OGRGeoJSON")
pal <- colorNumeric("plasma", 1:1000000)

function(input, output, session) {

  # Create the map
  output$map <- renderLeaflet({
    leaflet(counties.data) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
      addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                  fillColor = ~pal(total_2008),
                  label = ~paste0(NAME, ": ", formatC(total_2008, big.mark = ","))) %>%
      addLegend(pal = pal, values = ~total_2008, opacity = 1.0,
                labFormat = labelFormat(transform = function(x) x))
  })
  
  
  
  
}

