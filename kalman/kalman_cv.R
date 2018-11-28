library(data.table)
library(tidyverse)
library(lubridate)
library(forecast)


hur <- fread(file.path("hurricane.csv"),na.strings = c("PrivacySuppressed", "NULL"))
hur<-data.frame(hur)
hur$Date<-ymd(hur$Date)


hur$Latitude<-as.numeric(unlist(strsplit(hur$Latitude, split='N', fixed=TRUE)))
hur$Longitude<-as.numeric(unlist(strsplit(hur$Longitude, split='W', fixed=TRUE)))
hur$Longitude<-(-1)*hur$Longitude

hur_min_pressure <- hur %>% select("Date", "Time", "Minimum.Pressure")
# hur_min_pressure %>% View()
# 
# 


# modelcv <- CVar(lynx, k=5, lambda=0.15)
# print(modelcv)
# 
# 
# str(lynx)
# plot(lynx)
# 
# 
# library(fpp)
# e <- tsCV(dj, rwf, drift=TRUE, h=1)
# sqrt(mean(e^2, na.rm=TRUE))
# ## [1] 22.68249
# sqrt(mean(residuals(rwf(dj, drift=TRUE))^2, na.rm=TRUE))
# ## [1] 22.49681
# ## 
# ## 
# ## 
# ## 
# ## 

library(dlm)


library(imputeTS)
# data(tsAirgap)
str(tsAirgap)
plot(tsAirgap)
plot(tsAirgapComplete)

# cool this fills in the gaps
plot(na.kalman(tsAirgap))


# that's cool and all but I don't feel confident about using dlm here..  
# 
# 


df <- read_csv("hurricanes_augmented.csv")

# hur <- fread(file.path("hurricane.csv"), na.strings = c("PrivacySuppressed", "NULL"))
# hur<-data.frame(hur)
# View(hur)
# # ggplot(hur, aes(hur$Date[hur$ID=="AL031861"], hur$`Maximum Wind`[hur$ID=="AL031861"]))
# # ggplot(hur[hur$ID=="AL031861",], aes(Date,Maximum.Wind))+geom_point()
# # ggplot(hur, aes(Date,Maximum.Wind))+geom_point() + ylim(0,200)
# as.Date(hur$Date, "%y %m %d")
# hur$Date<-ymd(hur$Date)
# 
plot(df$Date)

# range is from 2007 to 2017 in this new hurricanes augmented data set
head(df$Date)
tail(df$Date)

z <- df$MinimumPressure
# twice a day seasonality
seasonality <- 24 * 60
y <- ts(z, start=2007, frequency=seasonality)
str(y)






