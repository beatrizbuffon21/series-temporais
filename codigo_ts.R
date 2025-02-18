# Carregar pacotes necessários
library(dplyr)
library(lubridate)
library(readr)
library(ggplot2)
library(forecast)


data<-read.csv(file="kalimati_tarkari_dataset.csv",dec = ".")

# Filtrar o dataset para a commodity "Tomato Big(Nepali)"
tomato_big_nepali <- data %>%
  filter(Commodity == "Tomato Big(Nepali)")

# Converter a coluna 'Date' para o formato Date
tomato_big_nepali$Date <- ymd(tomato_big_nepali$Date)

# Calcular a média mensal
monthly_avg <- tomato_big_nepali %>%
  group_by(year = year(Date), month = month(Date)) %>%
  summarise(monthly_average = mean(Average, na.rm = TRUE))

# Exibir o resultado
print(monthly_avg)


tomato<-ts(monthly_avg$monthly_average,start=c(2013,6),frequency = 12)
autoplot(tomato)

# Decomposição pelo modelo ADITIVO

decompa_tomato=decompose(tomato,type = "additive")
plot(decompa_tomato)

decompa_tomato$trend
decompa_tomato$seasonal
decompa_tomato$random

# Decomposição pelo modelo MULTIPLICATIVO

decompa_tomato=decompose(tomato,type = "multiplicative")
plot(decompa_tomato)

decompa_tomato$trend
decompa_tomato$seasonal
decompa_tomato$random

# Criar o modelo de suavização exponencial e fazer previsão de 3 passos à frente
modeloses <- ses(tomato)
forecasted <- forecast(modeloses, h = 3)

# Exibir os valores previstos
print(forecasted)

# Visualizar os dados e as previsões com intervalos de confiança
autoplot(forecasted)

# holt
modeloholt =holt(tomato,h=3)

# valores previstos

modeloholt

# modelo gerado
modeloholt$model

# valores estimados

modeloholt$fitted

# visualização dos dados e das previ?es com intervalos de confiança

autoplot(modeloholt)
