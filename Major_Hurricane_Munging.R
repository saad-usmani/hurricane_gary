require("data.table")
require("ggplot2")
require('lubridate')
require('maps')
require('sp')
require('ggmap')
require('plotly')
require('dplyr')

setwd('C:/Users/susmani/Documents/Year 6/Time Series/Project/hurricane_gary')
hur <- fread(file.path("hurricane.csv"),na.strings = c("PrivacySuppressed", "NULL"))
hur<-data.frame(hur)
hur$Date<-ymd(hur$Date)
hur$Latitude<-as.numeric(unlist(strsplit(hur$Latitude, split='N', fixed=TRUE)))
hur$Longitude<-as.numeric(unlist(strsplit(hur$Longitude, split='W', fixed=TRUE)))
hur$Longitude<-(-1)*hur$Longitude

hur_2005 <- hur[hur$Date >= "2005-01-01" & hur$Date <= "2005-12-31",]
hur_2005 <- hur_2005 %>%
  group_by(Name)
  
katrina_hur <- hur %>%
  filter(year(Date) == 2005) %>%
  filter(Name == 'KATRINA')
p<-plot_ly(data = katrina_hur, x = c(1:nrow(katrina_hur)), y = ~Minimum.Pressure, mode = 'lines')
major_winds<-data.frame(hur[hur$Maximum.Wind>96,]) %>%
  group_by(ID) %>%
  filter(Maximum.Wind == max(Maximum.Wind)) %>%
  filter(row_number() <= 1) 
major_winds_hur<-inner_join(hur, major_winds, by = 'ID') 
major_winds_hur <- major_winds_hur %>%
  select(c('Minimum.Pressure.x'))

# If hurricane has > 96

p<-plot_ly(data = hur[38000:50301,], x = c(1:12302), y = ~Minimum.Pressure, mode = 'lines')
pressure_cycles <- major_winds_hur[9987:14700,]
write.csv(pressure_cycles, 'pressure_cycles.csv', row.names = FALSE)  

major_winds_hur <- major_winds_hur[10000:14700,]

HoltWinters(major_winds_hur)

