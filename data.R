require("data.table")
require("ggplot2")
require('lubridate')
require('maps')
require('sp')
require('ggmap')
require('plotly')
require('dplyr')

## Cleaning the Data

hur <- fread(file.path("hurricane.csv"),na.strings = c("PrivacySuppressed", "NULL"))
hur<-data.frame(hur)
# ggplot(hur, aes(hur$Date[hur$ID=="AL031861"], hur$`Maximum Wind`[hur$ID=="AL031861"]))
# ggplot(hur[hur$ID=="AL031861",], aes(Date,Maximum.Wind))+geom_point()
# ggplot(hur, aes(Date,Maximum.Wind))+geom_point() + ylim(0,200)
# as.Date(hur$Date, "%y %m %d")
hur$Date<-ymd(hur$Date)

#ggplot(hur, aes(factor(Status)))+geom_bar()
#gp<-qplot(x=Longitude, y=Latitude, data=hur[hur$ID=="AL122005",], color=Status)
#ggplot(hur[hur$Date >= "2005-01-01" & hur$Date <= "2006-02-01",], aes(Date,Maximum.Wind), color=Maximum.Wind)+geom_point()

#mp <- NULL
#mapWorld <- borders("florida", colour="gray50", fill="gray50") # create a layer of borders
#mp<-gp+mapWorld

#mp <- mp+ geom_point(aes(x=Longitude, y=Latitude) ,color="blue", size=3) 

hur$Latitude<-as.numeric(unlist(strsplit(hur$Latitude, split='N', fixed=TRUE)))
hur$Longitude<-as.numeric(unlist(strsplit(hur$Longitude, split='W', fixed=TRUE)))
hur$Longitude<-(-1)*hur$Longitude

#mapgilbert <- get_map(location=c(-65.280479, 24.923566), zoom = 4,
#                      maptype = "satellite", scale = 2)

#gg<-ggmap(mapgilbert)+geom_point(data = hur[hur$ID=="AL122005",], aes(x = Longitude, y = Latitude, color=Maximum.Wind, alpha = 1), size = 5, shape = 20)+scale_colour_gradient(low='green', high='red')

#g <- list(
#  scope = 'usa',
#  projection = list(type = 'albers usa'),
#  showland = TRUE,
#  landcolor = toRGB("gray95"),
#  subunitcolor = toRGB("gray85"),
#  countrycolor = toRGB("gray85"),
#  countrywidth = 0.5,
#  subunitwidth = 0.5
#)

# p <- plot_geo(hur[hur$Date >= "2005-01-01" & hur$Date <= "2006-02-01",], lat = ~Latitude, lon = ~Longitude) %>%
#   add_markers(text = ~paste(Maximum.Wind, Name, Minimum.Pressure, sep = "<br />"), color = ~Maximum.Wind, symbol = I("square"), size = I(8), hoverinfo = "text"
#   ) %>%
#   colorbar(title = "Incoming flights<br />February 2011") %>%
#   layout(
#     title = 'Most trafficked US airports<br />(Hover for airport)', geo = g
#   )
# ggplotly(ggmap()+geom_point(data = hur[hur$ID=="AL122005",], aes(x = Longitude, y = Latitude, color=Maximum.Wind, alpha = 1), size = 5, shape = 20)+scale_colour_gradient(low='green', high='red'))
# 
# dat <- map_data("world", "canada") %>% group_by(group)
# p <- plot_mapbox(hur[hur$Date >= "2005-01-01" & hur$Date <= "2006-02-01",], x = ~Longitude, y = ~Latitude) %>%
#   add_paths(size = I(2)) %>%
#   add_segments(x = -100, xend = -50, y = 50, 75) %>%
#   layout(mapbox = list(zoom = 0,
#                        center = list(lat = ~median(lat),
#                                      lon = ~median(long))
#   ))
# 
# pk.eyJ1Ijoic3VzbWFuaSIsImEiOiJjamFhZnJlb3YwczdmMzJxaXlmcHJ0ZGZ2In0.vdCC--CzL7cM-XsG8yCrFw

#Plotting Data using Plotly and Mapbox

Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1Ijoic3VzbWFuaSIsImEiOiJjamFhZnJlb3YwczdmMzJxaXlmcHJ0ZGZ2In0.vdCC--CzL7cM-XsG8yCrFw')

# p <- hur[hur$Date >= "2005-01-01" & hur$Name == 'KATRINA',]  %>%
#   plot_mapbox(lat = ~Latitude, lon = ~Longitude,
#               mode = 'scattermapbox', color = I('red'), size = ~Maximum.Wind, hovertext=~paste("Max Wind: ", Maximum.Wind, '<br>Name:', Name))%>%
#   layout(title = 'Hurricane Katrina Track',
#          font = list(color='white'),
#          plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
#          mapbox = list(style = 'dark'),
#          legend = list(orientation = 'h',
#                        font = list(size = 8)),
#          margin = list(l = 25, r = 25,
#                        b = 25, t = 25,
#                        pad = 2))

#2005 Interactive Graph

p <- plot_mapbox(mode = 'scattermapbox') %>%
  add_markers(
    data = hur[hur$Date >= "2005-01-01" & hur$Name=='KATRINA',], x = ~Longitude, y = ~Latitude, text=~paste('Name: ', Name, '<br>Max Wind:', Maximum.Wind, '<br>Date: ', Date), split=~Name,
    size = ~Maximum.Wind, alpha = 0.5, color=~Date) %>%
  layout(
    plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
    mapbox = list(style = 'dark',
                  zoom = 3,
                  center = list(lat = median(hur$Latitude),
                                lon = median(hur$Longitude))),
    margin = list(l = 0, r = 0,
                  b = 0, t = 0,
                  pad = 0),
    showlegend=FALSE)


# Switch between September and October Major Hurricanes
p2 <- plot_mapbox(mode = 'scattermapbox') %>%
  add_markers(
    data = hur[format.Date(hur$Date, "%m")=="09" & hur$Maximum.Wind>=96,], x = ~Longitude, y = ~Latitude, text=~paste('Name: ', Name, '<br>Max Wind:', Maximum.Wind, '<br>Date: ', Date), color=~Name,
    size = ~Maximum.Wind, alpha = 0.5) %>%
  layout(
    plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
    mapbox = list(style = 'dark',
                  zoom = 3,
                  center = list(lat = median(hur$Latitude),
                                lon = median(hur$Longitude))),
    margin = list(l = 0, r = 0,
                  b = 0, t = 0,
                  pad = 0),
    showlegend=FALSE)

(p3 <- plot_ly(alpha = 0.6) %>%
  add_histogram(x = hur$Maximum.Wind[format.Date(hur$Date, "%m")=="09" & hur$Maximum.Wind>0], name = 'September', autobinx=TRUE) %>%
  add_histogram(x = hur$Maximum.Wind[format.Date(hur$Date, "%m")=="06" & hur$Maximum.Wind>0], name = 'June') %>%
  add_histogram(x = hur$Maximum.Wind[format.Date(hur$Date, "%m")=="07" & hur$Maximum.Wind>0], name = 'July') %>%
  add_histogram(x = hur$Maximum.Wind[format.Date(hur$Date, "%m")=="08" & hur$Maximum.Wind>0], name = 'August') %>%
  layout(barmode = "stack"))

p4<-plot_ly(x = hur$Maximum.Wind[format.Date(hur$Date, "%m")=="09"], type = "histogram")

max_winds<-data.frame(hur) %>%
  group_by(ID) %>%
  dplyr::summarise(Maximum.Wind = max(Maximum.Wind))

full_join(max_winds, hur, by = c('ID', 'Maximum.Wind'))

#Max Winds for Each Tropical Cyclone
max_winds<-data.frame(hur) %>%
  group_by(ID) %>%
  filter(Maximum.Wind == max(Maximum.Wind)) %>%
  filter(row_number() <= 1) 

#First Location of Maximum Wind for Major Hurricane
plot_mapbox(mode = 'scattermapbox') %>%
  add_markers(
    data = max_winds[max_winds$Maximum.Wind>115,], x = ~Longitude, y = ~Latitude, text=~paste('Name: ', Name, '<br>Max Wind:', Maximum.Wind, '<br>Date: ', Date), split=~Name,
    size = ~Maximum.Wind, alpha = 0.5) %>%
  layout(
    plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
    mapbox = list(style = 'dark',zoom = 1.5, center = list(lat = median(hur$Latitude), lon = median(hur$Longitude))),
    margin = list(l = 0, r = 0, b = 0, t = 0, pad = 0),
    showlegend=FALSE)

p5<-plot_ly(x = format.Date(max_winds$Date, "%m"), type = "histogram")
p6<-plot_ly(x = format.Date(max_winds$Date, "%Y"), type = "histogram")
p7<-plot_ly(x = format.Date(max_winds$Date, "%m%d"), type = "histogram")

major_winds<-data.frame(hur[hur$Maximum.Wind>96,]) %>%
  group_by(ID) %>%
  filter(Maximum.Wind == max(Maximum.Wind)) %>%
  filter(row_number() <= 1) 

mj.plot<-plot_ly(x = format.Date(major_winds$Date, "%Y"), type = "histogram")
mj.plot2<-plot_ly(x = format.Date(major_winds$Date, "%m%d"), type = "histogram")

## This script looks at origin of specificed system and finds first 10 nearest tracks
## within +/- 1 Lat/Lng of origin. 

hur_start<-hur[!duplicated(hur$ID), ] #Dataset of only origin of systems.



example<-hur %>%
  filter(Date >= "2004-01-01" & Date <= "2005-02-01" & Name == 'CHARLEY',)%>%
  select(Latitude, Longitude) %>%
  top_n(1)
range1<-example$Latitude-1 >= example$Latitude & example$Latitude <= example$Latitude+1
range2<-example$Longitude-1 >= example$Longitude & example$Longitude <= example$Longitude+1
example1<-hur_start %>%
  filter((Latitude >= as.numeric(example$Latitude-1) & as.numeric(Latitude<=example$Latitude+1)) & 
           (Longitude >= as.numeric(example$Longitude-1) & as.numeric(Longitude<=example$Longitude+1)))%>%
  top_n(10,ID)
full<-semi_join(hur, example1, by = "ID")

p6 <- plot_mapbox(mode = 'scattermapbox') %>%
  add_markers(
    data = full, x = ~Longitude, y = ~Latitude, text=~paste('Name: ', Name, '<br>Max Wind:', Maximum.Wind, '<br>Date: ', Date), color=~Name,
    size = ~Maximum.Wind, alpha = 0.5) %>%
  layout(
    plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
    mapbox = list(style = 'dark',
                  zoom = 1.5,
                  center = list(lat = median(hur$Latitude),
                                lon = median(hur$Longitude))),
    margin = list(l = 0, r = 0,
                  b = 0, t = 0,
                  pad = 0),
    showlegend=FALSE)
p6

## Script for finding closest tracks. 

example2<-hur %>%
  filter(Date >= "2005-01-01" & Date <= "2006-02-01" & Name == 'EMILY',)
ex<-hur%>%
  filter(Latitude >= (example2$Latitude-1) &
           Latitude<=example2$Latitude+1 &
           Longitude >= (example2$Longitude-1) &
           Longitude<=example2$Longitude+1,) %>%
  count(ID) %>%
  arrange(desc(n)) %>%
  top_n(3)
ex_join<-semi_join(hur,ex)

p7 <- plot_mapbox(mode = 'scatterbox') %>%
  add_markers(
    data = ex_join, x = ~Longitude, y = ~Latitude, text=~paste('Name: ', Name, '<br>Max Wind:', Maximum.Wind, '<br>Date: ', Date), color=~ID,
    size = ~Maximum.Wind, alpha = 0.5) %>%
  layout(
    plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
    mapbox = list(style = 'dark',
                  zoom = 1.5,
                  center = list(lat = median(hur$Latitude),
                                lon = median(hur$Longitude))),
    margin = list(l = 0, r = 0,
                  b = 0, t = 0,
                  pad = 0),
    showlegend=FALSE)
p7


##Creating a heatmap of origin of all hurricane data
atlantic_map<-get_map(location = "puerto rico", zoom = 4)

#first, plotting the points
ggmap(florida, extent = "device") + geom_point(aes(x = Longitude, y = Latitude), colour = "red", 
                                                 alpha = 0.1, size = 2, data = hur_start)

#second, plotting density maps across the
ggmap(florida, extent = "device") + geom_density2d(data = hur_start, 
                                                   aes(x = Longitude, y = Latitude), size = 0.3) + stat_density2d(data = hur_start, 
                                                                                                               aes(x = Longitude, y = Latitude, fill = ..level.., alpha = ..level..), size = 0.01, 
                                                                                                               bins = 16, geom = "polygon") + scale_fill_gradient(low = "green", high = "red") + 
  scale_alpha(range = c(0, 0.3), guide = FALSE)

#Picking a latitude and longitude
input<-c(28.0,-94.8)
max1<-75
input.lat<- hur[hur$Latitude >= (input[1]-1) & hur$Latitude <= (input[1]+1),]
input.lng<-hur[hur$Longitude >= (input[2]-1) & hur$Longitude <= (input[2]+1),]
input.max<-hur[hur$Maximum.Wind>=(max1-5) & hur$Maximum.Wind <= (max1+5),]
full_input<-hur[hur$Latitude >= (input[1]-1) & hur$Latitude <= (input[1]+1) & hur$Longitude >= (input[2]-1) & hur$Longitude <= (input[2]+1) & hur$Maximum.Wind>=(max1-5) & hur$Maximum.Wind <= (max1+5),]
full_join<-arrange(count(group_by(full_input, ID), Maximum.Wind), desc(Maximum.Wind))[1:5,]
full_join2<-semi_join(hur, full_join, by = "ID")
p7 <- plot_mapbox(mode = 'scatterbox') %>%
  add_markers(
    data = full_join2, x = ~Longitude, y = ~Latitude, text=~paste('Name: ', Name, '<br>Max Wind:', Maximum.Wind, '<br>Date: ', Date), color=~ID,
    size = ~Maximum.Wind, alpha = 0.5) %>%
  layout(
    plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
    mapbox = list(style = 'dark',
                  zoom = 1.5,
                  center = list(lat = median(hur$Latitude),
                                lon = median(hur$Longitude))),
    margin = list(l = 0, r = 0,
                  b = 0, t = 0,
                  pad = 0),
    showlegend=FALSE)
