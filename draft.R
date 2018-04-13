library(jsonlite)
library(dplyr)
library(stringr)

#states.data = readLines('data/us-states.geojson') %>% paste(collapse = '\n') %>% fromJSON(simplifyVector = FALSE)
counties.geo = readLines('data/us-counties.geojson') %>% paste(collapse = '\n') %>% fromJSON(simplifyVector = FALSE)

states.data = read.csv('data/us-states.csv')
counties.data = read.csv('data/us-counties.csv')

#us.elections.0816 = read.csv('data/US_County_Level_Presidential_Results_08-16.csv')
#us.elections.1216 = read.csv('data/US_County_Level_Presidential_Results_12-16.csv')

#counties_list <- unlist(lapply(counties.data[['features']], function(feat) { feat$properties$name })) %>%
#  unique() %>% sort()

counties.data$fips_state  <- str_pad(as.character(counties.data$fips_state),  2, "left", "0")
counties.data$fips_county <- str_pad(as.character(counties.data$fips_county), 3, "left", "0")

counties.data <- inner_join(states.data, counties.data, "state_code") %>%
  mutate(fips_code = str_c(fips_state, fips_county)) %>%
  select(state_code, state_name, capital, fips_code, county_name, fips_class)
  

counties.data$county_name <- str_replace(counties.data$county_name, " County", "")
