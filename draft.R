########################################################################################
#                                                                                      #
#                                                                                      #
#                                                                                      #
#                                                                                      #
########################################################################################

# Libraries required
library(jsonlite)
library(dplyr)
library(stringr)
library(ggplot2)

# Load basic datasets to get all geographic data
states.data = read.csv('data/us-states.csv')
counties.data = read.csv('data/us-counties.csv')

# Convert FIPS code for State and County to a supported format
counties.data$fips_state  <- str_pad(as.character(counties.data$fips_state),  2, "left", "0")
counties.data$fips_county <- str_pad(as.character(counties.data$fips_county), 3, "left", "0")

# Remove the ' County' suffix
counties.data$county_name <- str_replace(counties.data$county_name, " County", "")

# Join the two datasets and get the right columns
counties.data <- inner_join(states.data, counties.data, "state_code") %>%
  mutate(fips_code = str_c(fips_state, fips_county)) %>%
  select(state_code, state_name, capital, fips_code, county_name, fips_class)

# Remove States data. We don't need it anymore.
rm(states.data)

# Load US Elections datasets
us.elections.0816 = read.csv('data/US_County_Level_Presidential_Results_08-16.csv')

# Convert FIPS code to reflect the Counties dataset
us.elections.0816$fips_code <- str_pad(as.character(us.elections.0816$fips_code), 5, "left", "0")

us.elections0812.data = inner_join(counties.data, us.elections.0816, "fips_code")

rm(counties.data)
rm(us.elections.0816)

write.csv(us.elections0812.data, 'data/us-elections.csv')

counties.geo = readLines('data/us-counties.geojson') %>%
  paste(collapse = '\n') %>%
  fromJSON(simplifyVector = FALSE)

counties_list <- unlist(lapply(counties.geo[['features']], function(feat) {
  unlist(lapply(feat[['counties']], function(county) {
    county[['name']]
  }))
})) %>%
  sort()

for(state in counties.geo[['features']]) {
  state_name <- state[['properties']][['state']]

  for(county in state[['counties']]) {
    county_name <- county[['name']]
    
    county.info <- us.elections0812.data[
        which(us.elections0812.data$state_code == state_name &
              us.elections0812.data$county_name == county_name), ]
    
    
  }
}

which(us.elections0812.data$state_code == 'AL' & us.elections0812.data$county_name == "Autauga")

counties.data <- rgdal::readOGR("data/us-elections.geojson", "OGRGeoJSON")

counties.geo <- data.frame(geo_id = counties.data$GEO_ID,
                           state_fips = counties.data$STATE,
                           county_fips = counties.data$COUNTY,
                           county_name = counties.data$NAME,
                           lsad = counties.data$LSAD,
                           fips_code = counties.data$FIPSCODE)
  counties.geo$fips_code <- str_pad(as.character(counties.geo$fips_code), 5, "left", "0")

final.data <- right_join(counties.geo, us.elections0812.data, "fips_code")

write.csv(geo.data, "data/full.csv")

geojson <- readLines("data/us-elections.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

plot.data <- us.elections0812.data %>%
  group_by(state_name) %>%
  summarise(total_2008 = sum(total_2008)) %>%
  arrange(desc(total_2008))

plot.data$state_name <- factor(plot.data$state_name, levels = plot.data$state_name)

ggplot(plot.data, aes(state_name, total_2008)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_bar(stat='identity')
