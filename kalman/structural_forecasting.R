library(fpp)

# Exercise 1

plot(eggs)
fit <- StructTS(eggs)
plot(forecast(fit,h=10))

fit2 <- ets(eggs)
plot(forecast(fit2,h=10))

Acf(residuals(fit))
Acf(residuals(fit2))


# Exercise 2
# Updating regression using Kalman filter

# time-series with two time series
# consumption, income
# index is year & quarter 
str(usconsumption)
head(usconsumption)

# consumption
z = usconsumption[,1]

# income
y = usconsumption[,2]

yhat = v = e = numeric(165)


xtt = matrix(0,nrow=2,ncol=164)

xtt1 = matrix(0,nrow=2,ncol=165)

Ptt = Ptt1 = matrix(0,2,2)
n <- nrow(usconsumption)
s2 <- 1
Ptt1[1,1] = Ptt1[2,2] = 1e9
for(i in 1:n)
{
  f <- matrix(c(1,z[i]),ncol=1)
  yhat[i] = t(f) %*% xtt1[,i]
  v[i] = t(f) %*% Ptt1 %*% f + s2
  e[i] = y[i] - yhat[i]
  xtt[,i] = xtt1[,i] + Ptt1 %*% f * e[i] / v[i]
  Ptt = Ptt1 - Ptt1 %*% f %*% t(f) %*% Ptt1 / v[i]
  xtt1[,i+1] = xtt[,i]
  Ptt1 = Ptt
}

# (c) Value of sigma2 is cancelled as it is a nuisance parameter
# So set to 1 above arbitrarily

# (d)
coefficients(lm(y ~ z))
xtt[,n]

# (e)
#These are stored in xtt

# (f)
par(mfrow=c(1,1))
plot.ts(xtt[1,],ylab="a")
plot.ts(xtt[2,],ylab="b")
# No evidence of much change over time from plots

#(g)
# It can be estimated using the variance of the residuals



library(fpp)

(fit <- StructTS(oil, type="level"))
ets(oil, "ANN")
fc <- forecast(fit,h=3)
plot(fc)

(fit2 <- StructTS(ausair, type="trend"))
ets(oil, 'AAN')
fc <- forecast(fit2, h=5)
plot(fc)

(fit3 <- StructTS(austourists, type="BSM"))
ets(austourists,'AAA')
fc <- forecast(fit3, h=8)
plot(fc)
summary(fit3)


## Decomposition
fit <- StructTS(austourists, type = "BSM")
decomp <- cbind(austourists,fitted(fit))
colnames(decomp) <- c("data","level","slope","seasonal")
plot(decomp,main="Decomposition of International visitor nights")

fit2 <- ets(austourists,"AAA")
plot(fit2)

# Smoothing
fit <- StructTS(austourists, type = "BSM")
plot(austourists)
lines(tsSmooth(fit)[,1],col='blue')
lines(fitted(fit)[,1],col='red')
legend("topleft",col=c('blue','red'),lty=1,
       legend=c("Filtered level","Smoothed level"))

# Seasonal adjustment
fit <- StructTS(austourists, type = "BSM")
sm <- tsSmooth(fit)
plot(austourists)
aus.sa <- austourists - sm[,3]
lines(aus.sa,col='blue')

x <- austourists
x[sample(1:length(x), 5)] <- NA
fit <- StructTS(x, type = "BSM")
sm <- tsSmooth(fit)
estim <- sm[,1]+sm[,3]

plot(x,ylim=range(austourists))
points(time(x)[is.na(x)],estim[is.na(x)],col='red',pch=1)
points(time(x)[is.na(x)],austourists[is.na(x)],col='black',pch=1)
legend("topleft",pch=1,col=c(2,1),legend=c("Estimate","Actual"))



library(forecast)
library(ggplot2)

# ETS forecasts
USAccDeaths %>%
  ets() %>%
  forecast() %>%
  autoplot()

# Automatic ARIMA forecasts
WWWusage %>%
  auto.arima() %>%
  forecast(h=20) %>%
  autoplot()

# ARFIMA forecasts
library(fracdiff)
x <- fracdiff.sim( 100, ma=-.4, d=.3)$series
arfima(x) %>%
  forecast(h=30) %>%
  autoplot()

# Forecasting with STL
USAccDeaths %>%
  stlm(modelfunction=ar) %>%
  forecast(h=36) %>%
  autoplot()

AirPassengers %>%
  stlf(lambda=0) %>%
  autoplot()

USAccDeaths %>%
  stl(s.window='periodic') %>%
  forecast() %>%
  autoplot()

# TBATS forecasts
USAccDeaths %>%
  tbats() %>%
  forecast() %>%
  autoplot()

taylor %>%
  tbats() %>%
  forecast() %>%
  autoplot()


