# ---- pacotes ----
library(kableExtra)
library(tidyverse)
library(forecast)
library(plotly)
library(ggpubr)
library(fpp)
library(qcc)
library(ggplot2)
library(broom)

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

dados <- read.delim("C:/Users/Cliente/Downloads/ARIMA-master/ARIMA-master/dados/MA.txt")
head(dados)

# extrair mês e ano
dados$Mes <- substr(dados$Meses, 1, 3)  # pega as 3 primeiras letras (abrev. do mês)
dados$Ano <- substr(dados$Meses, 5, 6)  # pega os 2 últimos dígitos do ano

# criar um vetor de correspondência para meses
meses_pt <- c("jan", "fev", "mar", "abr", "mai", "jun", 
              "jul", "ago", "set", "out", "nov", "dez")

# converter para numérico (1-12)
dados$Mes_num <- match(tolower(dados$Mes), tolower(meses_pt))

# criar data completa (assumindo século 21 para anos de 2 dígitos)
dados$Data <- as.Date(paste0("20", dados$Ano, "-", dados$Mes_num, "-01"))

head(dados)

dados <- dados |> 
  mutate(
    Year = year(Data),      
    Month = month(Data)      
  )

# ---- criando a série temporal ----
serie_temporal <- ts(dados$MA, start=c(2007,1), frequency=12)

# ---- estatísticas descritivas ----
desc <- describe(as.numeric(serie_temporal))
desc <- desc[, !(names(desc) %in% c("vars", "trimmed", "skew", "se"))]
kable(desc, digits=4, caption="Resumo da Série MA")


# ---- gráfico da série temporal ----
autoplot(serie_temporal) + 
  labs(
    title="Série Temporal MA",
    x="Tempo (meses)",
    y="Valor MA"
  ) +
  tema_personalizado +
  scale_color_manual(values=c("#1f77b4"))

# ---- análise mensal ----
dados_mensais <- data.frame(
  Mes=cycle(serie_temporal),                
  Ano=floor(time(serie_temporal)),
  Valor=as.numeric(serie_temporal)        
) %>%
  group_by(Mes) %>%
  summarise(
    Media=mean(Valor, na.rm=TRUE),          
    Desvio=sd(Valor, na.rm=TRUE)            
  )

dados_mensais$Mes_Label <- factor(
  dados_mensais$Mes, 
  levels=1:12, 
  labels=c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun", 
           "Jul", "Ago", "Set", "Out", "Nov", "Dez")
)

# ---- gráfico de médias mensais ----
ggplot(dados_mensais, aes(x=Mes_Label, y=Media)) +
  geom_bar(stat="identity", fill="#3a506b", alpha=0.7) +
  geom_errorbar(aes(ymin=Media-Desvio, ymax=Media+Desvio), 
                width=0.3, color="black") +
  labs(
    title="Médias Mensais - MA",
    x="Mês",
    y="Valor Médio MA"
  ) +
  tema_personalizado +
  theme(
    plot.title=element_text(size=14, face="bold", hjust=0.5),
    axis.text.x=element_text(angle=45, hjust=1)
  )

# ---- ACF e PACF ----
ggAcf(serie_temporal, lag.max=36) + 
  labs(title="Função de Autocorrelação (ACF) - MA") +
  tema_personalizado

ggPacf(serie_temporal, lag.max=36) + 
  labs(title="Função de Autocorrelação Parcial (PACF) - MA") +
  tema_personalizado

# ---- decomposição aditiva ----
decomposicao_aditiva <- decompose(serie_temporal, type="additive")
autoplot(decomposicao_aditiva) + 
  labs(title="Decomposição Aditiva da Série MA") +
  tema_personalizado


# ---- teste Ljung-Box ----
ljung_box_test <- Box.test(serie_temporal, type = "Ljung-Box")
print(ljung_box_test)

# ---- teste White (heterocedasticidade) ----
white_test <- lmtest::bptest(serie_temporal ~ stats::lag(serie_temporal, -1))
print(white_test)

# ---- teste de normalidade (Anderson-Darling) ----
ad_test <- nortest::ad.test(serie_temporal)
print(ad_test)


# ---- testes de tendência determinística ----
tend_determ <- function(ts) {
  # aplicação dos testes de tendência
  CS <- suppressWarnings(randtests::cox.stuart.test(ts, c("two.sided")))  # H0: NAO existe tendência
  CeST <- suppressWarnings(trend::cs.test(ts))                            # H0: NAO existe tendência
  MannKT <- suppressWarnings(trend::mk.test(ts, continuity = TRUE))       # H0: a série é i.i.d. / NAO existe tendência
  MannK <- suppressWarnings(Kendall::MannKendall(ts))                     # H0: NAO existe tendência
  KPSST <- suppressWarnings(tseries::kpss.test(ts, null = c("Trend")))    # H0: NAO existe tendência
  
  # extração dos valores-p e conclusões
  p_value <- c(CS$p.value, CeST$p.value, MannKT$p.value, MannK$sl, KPSST$p.value)
  p_value1 <- ifelse(p_value >= 0.05, "Não Tendência", "Tendência")
  
  # tabela com os resultados dos testes
  tabela <- data.frame(
    Testes = c("Cox Stuart", "Cox and Stuart Trend", "Mann-Kendall Trend", "Mann-Kendall", "KPSS Test for Trend"),
    H0 = rep("Não tendência", 5),
    p_valor = round(p_value, 4),
    Conclusao = p_value1
  )
  
  # retornar os resultados em lista
  list(CS = CS, CeST = CeST, MannKT = MannKT, MannK = MannK, KPSST = KPSST, Tabela = tabela)
}

tend_determ(ts = serie_temporal)$Tabela |> kable()

# ---- testes de raiz unitária ----
raiz_unit <- function(ts) {
  # aplicação dos testes de raiz unitária
  ADF <- suppressWarnings(tseries::adf.test(ts, alternative = "stationary"))  # H0: raiz unitária
  PP <- suppressWarnings(tseries::pp.test(ts, alternative = "stationary"))    # H0: raiz unitária
  KPSSL <- suppressWarnings(tseries::kpss.test(ts, null = "Level"))           # H0: NAO existe tendência
  
  # extração dos valores-p e conclusões
  p_value <- c(ADF$p.value, PP$p.value, KPSSL$p.value)
  p_value1 <- ifelse(p_value[1:2] >= 0.05, "Tendência", "NAO tendência")
  p_value2 <- ifelse(p_value[3] >= 0.05, "NAO tendência", "Tendência")
  
  # tabela com os resultados dos testes
  tabela <- data.frame(
    Testes = c("Augmented Dickey-Fuller", "Phillips-Perron Unit Root", "KPSS Test for Level"),
    H0 = c("Tendência", "Tendência", "NAO tendência"),
    p_valor = round(p_value, 4),
    Conclusao = c(p_value1, p_value2)
  )
  # retornar os resultados em lista
  list(ADF = ADF, PP = PP, KPSSL = KPSSL, Tabela = tabela)
}
raiz_unit(ts=serie_temporal)$Tabela |> kable()

# ---- testes de sazonalidade ----
sazonalidade <- function(ts, diff = 0, freq = 12) {
  # aplicação dos testes de sazonalidade
  KrusW <- suppressWarnings(seastests::kw(ts, diff = diff, freq = freq))   # H0: NAO sazonal
  Fried <- suppressWarnings(seastests::fried(ts, diff = diff, freq = freq)) # H0: NAO sazonal
  
  # extração dos valores-p e conclusões
  p_value <- c(KrusW$Pval, Fried$Pval)
  p_value1 <- ifelse(p_value >= 0.05, "NAO sazonal", "Sazonal")
  
  # tabela com os resultados dos testes
  tabela <- data.frame(
    Testes = c("Kruskal-Wallis", "Friedman rank"),
    H0 = rep("NAO sazonal", 2),
    p_valor = round(p_value, 4),
    Conclusao = p_value1
  )
  
  # retornar os resultados em lista
  list(KrusW = KrusW, Fried = Fried, Tabela = tabela)
}

sazonalidade(ts = serie_temporal)$Tabela |> kable()

# ajuste modelo

attach(dados) #tranformando em objeto

MA <- ts(MA, start = 2007, frequency = 12) #tranformando em Séries Temporal

# ---- ajuste de modelo ----
ARIMA_fit <- auto.arima(MA)
ARIMA_fit 


# ---- teste independência ----
teste_lb <- Box.test(res.mod, lag = 15, type = "Ljung")

kable(tidy(teste_lb), digits = 4, caption = "Teste de Ljung-Box para resíduos")

# H0: NAO Autocorrelacionado 
# P-valor maior do que 0.05, portanto nao rejeitamos a hipotese nula
# Os residuos nao apresentam autocorrelacao

# ---- teste normalidade ----
test_n <- nortest::ad.test(res.mod) # H0: Normalidade

kable(tidy(test_n), digits = 4, caption = "Teste de Anderson-Darling ")

# P-valor maior do que 0.05, portanto não rejeitamos a hipotese nula
# Os residuos nao apresentam normalidadee

# ---- teste raiz unitária ----
raiz_unit(ts = res.mod)$Tabela |> kable()

# ---- normalidade e estacionariedade dos resíduos ----
ggqqplot(res.mod) + ggtitle("Resíduo do Modelo") + tema_personalizado
shapiro.test(res.mod)
adf.test(res.mod)

# ---- previsão ----

autoplot(forecast(ARIMA_fit, h = 12)) + tema_personalizado



