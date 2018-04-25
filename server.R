library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)

set.seed(100)
counties.data <- rgdal::readOGR("data/us-elections.geojson", "OGRGeoJSON")
pal <- colorNumeric(c('#543005','#8c510a','#bf812d','#dfc27d','#f6e8c3','#f5f5f5','#c7eae5','#80cdc1','#35978f','#01665e','#003c30'), 1:3000000)


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
      addLegend("bottomright", pal = pal, values = ~total_2008, opacity = 1.0,
                labFormat = labelFormat(transform = function(x) x))
  })
  
  observe({
    counties <- if (is.null(input$states)) character(0) else {
      filter(us_elections_history, state_code %in% input$states) %>%
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
        is.null(input$states) | state_code %in% input$states,
        is.null(input$counties) | county_name %in% input$counties
      ) %>%
      select(state_name, county_name, party, total_votes_2008, total_votes_2012, total_votes_2016)
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
  
  plot_data <- reactive({
    if(input$elections == "2008") {
      plot.data <- us_elections_history %>%
        group_by(state_name, party) %>%
        summarise(total_votes_2008 = sum(total_votes_2008)) %>%
        mutate(elections_total = total_votes_2008) %>%
        arrange(desc(elections_total))  
    } else if(input$elections == "2012") {
      plot.data <- us_elections_history %>%
        group_by(state_name, party) %>%
        summarise(total_votes_2012 = sum(total_votes_2012)) %>%
        mutate(elections_total = total_votes_2012) %>%
        arrange(desc(elections_total))  
    } else if(input$elections == "2016") {
      plot.data <- us_elections_history %>%
        group_by(state_name, party) %>%
        summarise(total_votes_2016 = sum(total_votes_2016)) %>%
        mutate(elections_total = total_votes_2016) %>%
        arrange(desc(elections_total))  
    }
    
    plot.data$state_name <- as.factor(plot.data$state_name)

    if(input$byparty == TRUE) {
      ggplot(plot.data, aes(state_name, elections_total, fill = party)) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(x="State", y="Votes", title=paste("Votes by State in", input$elections, "grouped by party", sep=" ")) +
        geom_bar(stat='identity')
    } else {
      ggplot(plot.data, aes(state_name, elections_total)) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(x="State", y="Votes", title=paste("Votes by State in", input$elections, sep=" ")) +
        geom_bar(stat='identity')
    }
    
    
  })
  
  output$plot <- renderPlot(
    plot_data()
  )
  
}