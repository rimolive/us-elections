library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)

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
  
  observe({
    counties <- if (is.null(input$states)) character(0) else {
      filter(us_elections_history, state_name %in% input$states) %>%
        `$`('county_name') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$counties[input$counties %in% counties])
    updateSelectInput(session, "counties", choices = counties,
                      selected = stillSelected)
  })
  
  output$us_elections_history <- DT::renderDataTable({
    df <- us_elections_history %>%
      filter(
        is.null(input$states) | state_name %in% input$states,
        is.null(input$counties) | county_name %in% input$counties
      ) %>%
      select(state_name, county_name, total_2008, dem_2008, gop_2008, oth_2008, total_2012, dem_2012, gop_2012, oth_2012, total_2016, dem_2016, gop_2016, oth_2016)
    #%>%
    #  mutate(Action = paste('<a class="go-map" href="" data-lat="', Lat, '" data-long="', Long, '" data-zip="', Zipcode, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
  
  plot_data <- reactive({
    if(input$elections == "2008") {
      plot.data <- us_elections_history %>%
        group_by(state_name) %>%
        summarise(total_2008 = sum(total_2008)) %>%
        mutate(elections_total = total_2008) %>%
        arrange(desc(total_2008))  
    } else if(input$elections == "2012") {
      plot.data <- us_elections_history %>%
        group_by(state_name) %>%
        summarise(total_2012 = sum(total_2012)) %>%
        mutate(elections_total = total_2012) %>%
        arrange(desc(total_2012))  
    } else if(input$elections == "2016") {
      plot.data <- us_elections_history %>%
        group_by(state_name) %>%
        summarise(total_2016 = sum(total_2016)) %>%
        mutate(elections_total = total_2016) %>%
        arrange(desc(total_2016))  
    }
    
    plot.data$state_name <- factor(plot.data$state_name, levels = plot.data$state_name)
    
    ggplot(plot.data, aes(state_name, elections_total)) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      geom_bar(stat='identity')
  })
  
  output$plot <- renderPlot(
    plot_data()
  )
  
}