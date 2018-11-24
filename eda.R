library(data.table)
library(ggplot2)
library(lubridate)


library(maps)
library(sp)
library(ggmap)
library(plotly)
library(dplyr)


## Cleaning the Data

hur <- fread(file.path("hurricane.csv"), na.strings = c("PrivacySuppressed", "NULL"))
hur<-data.frame(hur)
View(hur)
# ggplot(hur, aes(hur$Date[hur$ID=="AL031861"], hur$`Maximum Wind`[hur$ID=="AL031861"]))
# ggplot(hur[hur$ID=="AL031861",], aes(Date,Maximum.Wind))+geom_point()
# ggplot(hur, aes(Date,Maximum.Wind))+geom_point() + ylim(0,200)
# as.Date(hur$Date, "%y %m %d")
hur$Date<-ymd(hur$Date)
