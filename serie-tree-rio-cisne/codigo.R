# ---- pacotes ----
library(dplyr)
library(lubridate)
library(psych)
library(knitr)
library(ggplot2)
library(ggfortify)
library(forecast)
library(lmtest)
library(broom)
library(ggpubr)

# ---- tema ----
tema_personalizado <- theme_minimal() +
  theme(
    text = element_text(family = "sans", color = "#317eac"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    panel.grid.major = element_line(color = "#ced4da"),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#ced4da"),
    panel.background = element_rect(fill = "white")
  )

# ---- dados e série temporal ----

dados <- read.delim("C:/Users/Cliente/Downloads/Time-Series-main/Time-Series-main/TREE_RIO_CISNE.txt")

dados <- dados[order(dados$age_CE), ]

d1 <- ts(dados$trsgi, start = 441, frequency = 1)

# ---- análise descritiva ----
summary(d1)
desc <- describe(as.numeric(d1))
desc <- desc[, !(names(desc) %in% c("vars", "trimmed", "skew", "se"))]
kable(desc, digits=4, caption="Resumo da Série")


# ---- gráfico da série -----
forecast::autoplot(d1)+labs(x="Tempo (meses)",y="Preços das exportações")+ tema_personalizado

# ---- gráfico da Função de Autocorrelação (FAC) ----
forecast::ggAcf(d1,lag.max = 100, type = c("correlation"))+labs(y = "FAC",title="")+
  tema_personalizado

# ---- gráfico da Função de Autocorrelação Parcial (FACP) ----
forecast::ggAcf(d1,lag.max = 100,type = c("partial"))+labs(y = "FACP",title="")+
  tema_personalizado

# ---- análise de tendência determinística ----
tend_determ<-function(ts){
  CS<-suppressWarnings(randtests::cox.stuart.test(ts,c("two.sided"))) #H0: NAO existe tendencia
  CeST<-suppressWarnings(trend::cs.test(ts)) #H0: NAO existe tendencia
  # Runs<-suppressWarnings(randtests::runs.test(ts)) #H0: NAO existe tendencia
  # WaldW<-suppressWarnings(trend::ww.test(ts)) #H0: NAO existe tendencia
  MannKT<-suppressWarnings(trend::mk.test(ts,continuity = TRUE)) #H0: a serie eh i.i.d. / NAO existe tendencia
  MannK<-suppressWarnings(Kendall::MannKendall(ts)) #H0: NAO existe tendencia
  KPSST<-suppressWarnings(tseries::kpss.test(ts, null = c("Trend"))) #H0: NAO existe tendencia
  #
  p_value<-c(CS$p.value,CeST$p.value,MannKT$p.value,MannK$sl,KPSST$p.value)
  p_value1<-p_value
  p_value1[p_value>=0.05]<-"NAO tendencia"
  p_value1[p_value<0.05]<-"Tendencia"
  tabela<-data.frame(Testes=c("Cox Stuart","Cox and Stuart Trend",
                              "Mann-Kendall Trend","Mann-Kendall","KPSS Test for Trend"),
                     H0=c(rep("NAO tendencia",5)),
                     p_valor=round(p_value,4),
                     Conclusao=c(p_value1))
  list(CS=CS,CeST=CeST,MannKT=MannKT,MannK=MannK,KPSST=KPSST,Tabela=tabela)
}

tend_determ(ts = d1)$Tabela

# ---- teste de raiz unitária ----

raiz_unit<-function(ts){
  ADF<-suppressWarnings(tseries::adf.test(ts,alternative = c("stationary"))) #H0: raiz unitaria
  PP<-suppressWarnings(tseries::pp.test(ts,alternative = c("stationary"))) #H0: raiz unitaria
  KPSSL<-suppressWarnings(tseries::kpss.test(ts, null = c("Level"))) #H0: nao existe tendencia
  #
  p_value<-c(ADF$p.value,PP$p.value,KPSSL$p.value)
  p_value1<-p_value[1:2]
  p_value1[p_value[1:2]>=0.05]<-"Tendencia"
  p_value1[p_value[1:2]<0.05]<-"NAO tendencia"
  p_value2<-p_value[3]
  p_value2[p_value[3]>=0.05]<-"NAO tendencia"
  p_value2[p_value[3]<0.05]<-"Tendencia"
  tabela<-data.frame(Testes=c("Augmented Dickey-Fuller","Phillips-Perron Unit Root","KPSS Test for Level"),
                     H0=c(rep("Tendencia",2),"NAO tendencia"),
                     p_valor=round(p_value,4),
                     Conclusao=c(p_value1,p_value2))
  list(ADF=ADF,PP=PP,KPSSL=KPSSL,Tabela=tabela)
}


raiz_unit(ts=d1)$Tabela

# ---- teste de sazonalidade ----

sazonalidade<-function(ts,diff=0,freq){
  KrusW<-suppressWarnings(seastests::kw((ts),diff = diff, freq=12)) #H0: NAO Sazonal
  Fried<-suppressWarnings(seastests::fried((ts),diff = diff, freq=12)) #H0: NAO Sazonal
  #
  p_value<-c(KrusW$Pval,Fried$Pval)
  p_value1<-p_value
  p_value1[p_value>=0.05]<-"NAO Sazonal"
  p_value1[p_value<0.05]<-"Sazonal"
  tabela<-data.frame(Testes=c("Kruskall Wallis","Friedman rank"),
                     H0=c(rep("NAO Sazonal",2)),
                     p_valor=round(p_value,4),
                     Conclusao=c(p_value1))
  list(KrusW=KrusW,Fried=Fried,Tabela=tabela)
}

sazonalidade(ts = d1,diff = 1,freq = 12)$Tabela


# ---- modelagem da série temporal ----
mod_sarima <- Arima(d1, order = c(2, 0, 3), seasonal = list(order = c(2, 0, 0), period = 10))
summary(mod_sarima)

lmtest::coeftest(mod_sarima)

# ---- análise resíduo ----
res.mod<-mod_sarima$residuals
ggtsdisplay(res.mod,plot.type="histogram", theme=tema_personalizado)

# ---- teste de independência ----
teste_lb <- Box.test(res.mod, lag = 15, type = "Ljung")

kable(tidy(teste_lb), digits = 4, caption = "Teste de Ljung-Box para resíduos")

# ---- teste de normalidade ----
test_n <- nortest::ad.test(res.mod) # H0: Normalidade

kable(tidy(test_n), digits = 4, caption = "Teste de Anderson-Darling ")

# ---- teste de raiz unitária ----
raiz_unit(ts = res.mod)$Tabela |> kable()

ggqqplot(res.mod)+tema_personalizado

# ---- previsão ----

forecast_sarima <- forecast(mod_sarima, h = 12)
autoplot(forecast_sarima) +
  autolayer(forecast_sarima$fitted, series = "Ajustado", color = "blue") +
  labs(title = "Previsão SARIMA(2,0,3)(2,0,0)[10]",
       x = "Tempo", y = "Índice de Crescimento") +
  tema_personalizado

forecast_sarima
