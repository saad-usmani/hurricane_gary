library(data.table)
library(tidyverse)
library(lubridate)
library(ggfortify)
theme_set(theme_light())

hur <- fread(file.path("hurricane.csv"),na.strings = c("PrivacySuppressed", "NULL"))
hur<-data.frame(hur)
hur$Date<-ymd(hur$Date)


hur$Latitude<-as.numeric(unlist(strsplit(hur$Latitude, split='N', fixed=TRUE)))
hur$Longitude<-as.numeric(unlist(strsplit(hur$Longitude, split='W', fixed=TRUE)))
hur$Longitude<-(-1)*hur$Longitude

hur_3years <- hur %>% 
  filter(year(Date) %in% c(1999, 2005, 2015)) %>%
  filter(Status == 'HU') 
  
  
  
# %>% 
  # select(Date, Minimum.Pressure) %>% 
  
ggplot(hur_3years, aes(x=Date, y=Minimum.Pressure)) + 
  geom_line(aes(color=Date), size=1) +
  scale_color_manual(values = c("#00AFBB", "#E7B800", "#E7B900"))


  









