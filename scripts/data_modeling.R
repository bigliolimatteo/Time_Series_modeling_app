n <- 2000
m <- 200
y <- ts(rnorm(n) + (1:n)%%102/30, f=m)
plot(y)

library(forecast)
fit <- Arima(y, order=c(2,0,1), xreg=fourier(y, K=4))
fit <- auto.arima(y, seasonal=FALSE, xreg=fourier(y, K=4))
plot(forecast(fit, h=2*m, xreg=fourier(y, K=4, h=2*m)))




library(forecast)
data = na.omit(read.csv('NTBL_datasets/cleaned_for_modeling.csv'))
my_ts = ts(data$value, frequency = 1)
my_ts[1:4000]
length(my_ts)/24
min(my_ts)

plot(my_ts[1:4000],col="green", type='l')
lines(2000+102*sin(6.28/24*c(1:length(my_ts[1:102]))), type='l',col="red")
lines(2000+102*cos(6.28/24*c(1:length(my_ts[1:102]))), type='l',col="red")
lines(2000+102*sin(6.28/12*c(1:length(my_ts[1:102]))), type='l',col="blue")
lines(2000+102*cos(6.28/12*c(1:length(my_ts[1:102]))), type='l',col="blue")
lines(2000+102*sin(6.28/8*c(1:length(my_ts[1:102]))), type='l',col="orange")
lines(2000+102*cos(6.28/8*c(1:length(my_ts[1:102]))), type='l',col="orange")
lines(2000+102*sin(6.28/6*c(1:length(my_ts[1:102]))), type='l',col="purple")
lines(2000+102*cos(6.28/6*c(1:length(my_ts[1:102]))), type='l',col="purple")


fourier = cbind(
sin(6.28/24*c(1:length(my_ts[1:4000]))),
cos(6.28/24*c(1:length(my_ts[1:4000]))),
sin(6.28/12*c(1:length(my_ts[1:4000]))),
cos(6.28/12*c(1:length(my_ts[1:4000]))),
sin(6.28/8* c(1:length(my_ts[1:4000]))),
cos(6.28/8* c(1:length(my_ts[1:4000]))),
sin(6.28/6* c(1:length(my_ts[1:4000]))),
cos(6.28/6* c(1:length(my_ts[1:4000])))
)


library(forecast)
fit <- auto.arima(my_ts[1:4000], seasonal=FALSE, xreg=fourier)
fit <- Arima(my_ts[1:4000], order=c(1,0,3), xreg=fourier)
plot(forecast(fit, h=10, xreg=fourier))

fourier
fit
coeff = c(111.2092,  -719.7914,  -216.9563,  -429.2404,  -54.3504,  -28.3631,  43.5980,  115.3842)

plot(fourier[,1] * coeff[1], type='l',col="blue")
for (j in 2:length(coeff)){
  lines(fourier[,j] * coeff[j], type='l',col=j)
}

ff_pred = fourier[,1] * coeff[1]
for (j in 2:length(coeff)){
  ff_pred = ff_pred + fourier[,j] * coeff[j]
}
k = 2000
plot(my_ts[1:k], type='l',col="blue")
lines(fit$fitted[1:k], type='l',col="red")
lines(ff_pred + 3014.2009, type='l',col="red")

plot(fit$residuals, type='l',col="blue")


fit <- auto.arima(my_ts, seasonal=FALSE, xreg=fourier(my_ts, K=1))
plot(forecast(fit, xreg=fourier(my_ts, K=1)))

my_ts


aic_vals_temp = NULL
aic_vals = NULL
for(i in 1:5)
{
  for (j in 1:5)
  {
    xreg1 = fourier(ts(1:length(NumEvents), frequency = 24), i, 24)
    xreg2 = fourier(ts(1:length(NumEvents), frequency = 24), j, 24*7)
    xtrain = cbind(xreg1, xreg2)
    fitma1 = auto.arima(NumEvents, D=0, max.P=0, max.Q=0, xreg=xtrain)
    aic_vals_temp = cbind(i,j,fitma1$aic)
    aic_vals = rbind(aic_vals, aic_vals_temp)
  }
}

colnames(aic_vals) = c('FourierTerms24', 'FourierTerms168', 'AICValue')
aic_vals = data.frame(aic_vals)
minAICVal = min(aic_vals$AICValue)
minvals = aic_vals[which(aic_vals$AICValue == minAICVal),]

xreg1 = fourier(751:760, 1, 24)
xreg2 = fourier(751:760, 2, 24*7)
xtest = cbind(xreg1, xreg2)
predict(fitma1, newxreg=xtest)