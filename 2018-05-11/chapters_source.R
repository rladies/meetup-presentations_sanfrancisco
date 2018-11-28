library(rvest)
library(tidyverse)
library(meetupr)
library(lubridate)
# library(rtweet)
# library(dplyr)
# library(lubridate)
library(stringr)
library(ggmap)
library(purrr)
library(tidyr)
library(tibble)
library(maps)
library(ggthemes)
library(plotly)
library(gganimate)
library(readr)


# meetup groups
api_key <- readRDS("meetup_key.RDS")
all_rladies_groups <- find_groups(text = "r-ladies", api_key = api_key)

# Cleanup
rladies_groups <- all_rladies_groups[grep(pattern = "rladies|r-ladies|rug", 
                                          x = all_rladies_groups$urlname,
                                          ignore.case = TRUE), ]


rladies_groups %>% 
  group_by(substr(created, 1, 7)) %>% 
  count() %>% 
  arrange()



library(ggplot2)
library(maps)
library(ggthemes)

#··················
# plotly

world <- ggplot() +
  borders("world", colour = "gray85", fill = "gray80") + 
  theme_map()

map <- world +
  geom_point(
    aes(
      x = lon, y = lat,
      text = paste('city: ', city,
                   '<br /> created : ', created
      ),
      size = members
    ),
    data = rladies_groups, 
    colour = 'purple', alpha = .5
    ) +
  scale_size_continuous(range = c(1, 9), breaks = c(250, 500, 750, 1000)) +
  labs(size = 'members')

plotly::ggplotly(map, tooltip = c('text', 'size'))

#··············
# static map 

plotly::ggplotly(map2012, tooltip = c('text', 'size'))

map2012 <- world +
  geom_point(
    aes(
      x = lon, y = lat,
      # text = paste('city: ', city,
      #              '<br /> created : ', created),
      # ),
      # size = members
      size = 1
    ),
    data = rladies_groups %>% 
      filter(year(created) == 2018),
             # , city != "London",
             # city != "Taipei"), 
      # filter(city == "London", year(created) <= 2016),
    colour = 'purple', alpha = .5
  ) 
# +
#   scale_size_continuous(range = c(1, 9), breaks = c(250, 500, 750, 1000)) +
#   labs(size = 'members')

plotly::ggplotly(map2012, tooltip = c('text', 'size'))



map2012 <- world +
  geom_point(
    aes(x = lon, y = lat),    # add the size aes for later gganimate
    data = 
      rladies_groups %>% 
      filter(year(created) == 2012), 
    colour = 'purple', alpha = .5) 

map2015 <- world +
  geom_point(
    aes(x = lon, y = lat),    # add the size aes for later gganimate
    data = 
      rladies_groups %>% 
      filter(year(created) <= 2015), 
    colour = 'purple', alpha = .5) 

map2016 <- world +
  geom_point(
    aes(x = lon, y = lat),    # add the size aes for later gganimate
    data = 
      rladies_groups %>% 
      filter(year(created) <= 2016), 
    colour = 'purple', alpha = .5) 

map2017 <- world +
  geom_point(
    aes(x = lon, y = lat),    # add the size aes for later gganimate
    data = 
      rladies_groups %>% 
      filter(year(created) <= 2017), 
    colour = 'purple', alpha = .5) 

map2018 <- world +
  geom_point(
    aes(x = lon, y = lat),    # add the size aes for later gganimate
    data = 
      rladies_groups %>% 
      filter(year(created) <= 2018), 
    colour = 'purple', alpha = .5) 







# +
  # scale_size_continuous(range = c(1, 8), 
  #                       breaks = c(250, 500, 750, 1000)) +
  # labs(size = 'members')

#··············
# gganimate map 

rladies_groups_sub <- rladies_groups %>% 
  select(name, created, members, lat, lon, city)

# init point to show empty map in the beggining
ghost_point <- rladies_groups_sub %>%
  add_row(
    created = as.Date('2011-09-01'),
    members = 0,
    lon = 0,
    lat = 0,
    .before = 1) %>%
  slice(1) %>% 
  mutate(date = format(created, format = '%Y-%m-%d'),
         est_followers = 0)

dates <- as_tibble(seq(floor_date(as.Date(min(rladies_groups_sub$created)), 
                                  unit = "month"),
                       today(),
                       by = 'days')) %>%
  filter(day(value) %in% c(1, 10, 20))

rladies_frames <- rladies_groups_sub %>%
  select(name, created) %>%
  expand(name, date = dates$value)
  # right_join(rladies, by = 'screen_name') %>%
  # filter(date > created) %>%
  # mutate(date = format(date, format = '%Y-%m-%d'),
  #        age_total = as.numeric(age_days, units = 'days'),
  #        age_at_date = as.numeric(difftime(date, created, units = 'days'),
  #                                 units = 'days'),
  #        est_followers = ((followers - 1) / age_total) * age_at_date)

rladies_less_frames <- rladies_frames 
# %>%
  # filter((day(as.Date(date)) == 1 & month(as.Date(date)) %% 6 == 0) |
  #          as.Date(date) >= rladies$account_created_at[rladies$screen_name == 'RLadiesLondon'])



map_less_frames <- world +
  geom_point(
    aes(x = lon, y = lat,
        size = members,
        frame = created
        ),
    data = rladies_groups_sub, 
    colour = 'purple', alpha = .5) 
  # geom_point(aes(x = lon, y = lat,
  #                size = members
  #                # ,
  #                # frame = created
  #                ),
  #            data = ghost_point, alpha = 0) +
  # scale_size_continuous(range = c(1, 13), breaks = c(250, 500, 750, 1000)) +
  # labs(size = 'Followers')

# animation::ani.options(ani.width = 1125, ani.height = 675)
animation::ani.options(ani.width = 800, ani.height = 480)
gganimate(map_less_frames, interval = .15, "rladies_growth.gif")
gganimate(map_less_frames)




p <- world + geom_point(aes(lon,lat,frame=year(created)),
                        rladies_groups_sub,color="red",size=5)
gganimate(p, width=2, height=2)









# Each country/continent





groups_usa <- rladies_groups %>% 
  filter(country == "US")
created_usa <- groups_usa %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")

# Canada
canada <- sort(unique(rladies_groups[grep("Canada", rladies_groups$timezone),]$country))
groups_canada <- rladies_groups %>% 
  filter(country %in% canada)
created_canada <- groups_canada %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")


# Latin America (AR, BR, CL, CO, "CR" "EC" "MX" "PE" "UY" )  
latam <- sort(unique(rladies_groups[grep("America", rladies_groups$timezone),]$country))
groups_latam <- rladies_groups %>% 
  filter(country %in% latam)
created_latam <- groups_latam %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")

# Europe
europe <- sort(unique(rladies_groups[grep("Europe", rladies_groups$timezone),]$country))
groups_europe <- rladies_groups %>% 
  filter(country %in% europe)
created_europe <- groups_europe %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")

# Africa
africa <- sort(unique(rladies_groups[grep("Africa", rladies_groups$timezone),]$country))
groups_africa <- rladies_groups %>% 
  filter(country %in% africa)
created_africa <- groups_africa %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")

# Asia
asia <- sort(unique(rladies_groups[grep("Asia", rladies_groups$timezone),]$country))
groups_asia <- rladies_groups %>% 
  filter(country %in% asia)
created_asia <- groups_asia %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")

# Australia
australia <- sort(unique(rladies_groups[grep("Australia", rladies_groups$timezone),]$country))
groups_australia <- rladies_groups %>% 
  filter(country %in% australia)
created_australia <- groups_australia %>% 
  mutate(dt_created = substr(created, 1, 10)) %>% 
  arrange(desc(dt_created)) %>% 
  select("city", "state", "country", "dt_created", "members")
