# ---- pacotes ----
library(kableExtra)
library(tidyverse)
library(forecast)
library(plotly)
library(ggpubr)
library(fpp)
library(qcc)
library(ggplot2)

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

data_brasilia <- read.csv("C:/Users/Cliente/Downloads/Time-Series-main/Time-Series-main/wind-brasilia.txt",
                          sep = ";")

dados <- data_brasilia %>%
  mutate(
    Data  = as.Date(Data, "%d/%m/%Y"),
    Year  = year(Data),
    Month = month(Data)
  ) %>%
  select(Data, VelocidadeVentoMedia, Year, Month)  # ajuste o nome da coluna se for diferente

serie_temporal <- ts(dados$VelocidadeVentoMedia, start = c(2001, 1), frequency = 12)

# ---- amostras da base ----
dados_selecionados <- rbind(head(data_brasilia, 3), tail(data_brasilia, 3))

dados_selecionados |>
  kable(caption = "Três primeiros e três últimas observações da série temporal")

# ---- estatísticas descritivas ----
summary(serie_temporal)


# ---- gráfico para valores individuais da série original ----

ichart_serie_original <- qcc(data = as.numeric(serie_temporal), 
                             type = "xbar.one", 
                             std.dev = "MR", 
                             k = 3,
                             title = "Gráfico para valores individuais da Série Original",
                             xlab = "Tempo (meses)", 
                             ylab = "Velocidade do Vento Média",
                             plot = TRUE,
                             bg.plot = "white")

# ---- gráfico da série temporal ----
autoplot(serie_temporal) +
  labs(
    title = "Série Temporal da Velocidade do Vento",
    x = "Tempo (meses)",
    y = "Velocidade do Vento"
  ) +
  tema_personalizado +
  scale_color_manual(values = c("#FF6347"))

# ---- gráfico das médias mensais ----

dados_mensais <- data.frame(
  Mes = cycle(serie_temporal),                
  Ano = floor(time(serie_temporal)),
  Valor = as.numeric(serie_temporal)        
) %>%
  group_by(Mes) %>%
  summarise(
    Media = mean(Valor, na.rm = TRUE),          
    Desvio = sd(Valor, na.rm = TRUE)            
  )

dados_mensais$Mes_Label <- factor(
  dados_mensais$Mes, 
  levels = 1:12, 
  labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
)

ggplot(dados_mensais, aes(x = Mes_Label, y = Media)) +
  geom_bar(stat = "identity", fill = "#317eac", alpha = 0.7) +  # Barras para a média
  geom_errorbar(aes(ymin = Media - Desvio, ymax = Media + Desvio), 
                width = 0.3, color = "black") +                 # Barras de erro
  labs(
    title = "Médias Mensais",
    x = "Mes",
    y = "Velocidade Média"
  ) +
  tema_personalizado +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# ---- ACF ----
ggAcf(serie_temporal, lag.max = 36) +
  labs(
    title = "Função de Autocorrelação (ACF)",
    y = "Autocorrelação"
  ) +
  tema_personalizado +
  scale_color_manual(values = c("#FF8C00"))

# ---- PACF ----
ggPacf(serie_temporal, lag.max = 36) +
  labs(
    title = "Função de Autocorrelação Parcial (PACF)",
    y = "Autocorrelação Parcial"
  ) +
  tema_personalizado +
  scale_color_manual(values = c("#32CD32"))

# ---- decomposição aditiva ----
decomposicao_aditiva <- decompose(serie_temporal, type = "additive")
autoplot(decomposicao_aditiva) +
  labs(title = "Decomposição Aditiva da Série Temporal") +
  tema_personalizado +
  scale_color_manual(values = c("#4682B4"))

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
  CS <- suppressWarnings(randtests::cox.stuart.test(ts, c("two.sided")))
  CeST <- suppressWarnings(trend::cs.test(ts))
  MannKT <- suppressWarnings(trend::mk.test(ts, continuity = TRUE))
  MannK <- suppressWarnings(Kendall::MannKendall(ts))
  KPSST <- suppressWarnings(tseries::kpss.test(ts, null = c("Trend")))
  
  p_value <- c(CS$p.value, CeST$p.value, MannKT$p.value, MannK$sl, KPSST$p.value)
  p_value1 <- ifelse(p_value >= 0.05, "Não Tendência", "Tendência")
  
  tabela <- data.frame(
    Testes = c("Cox Stuart", "Cox and Stuart Trend", "Mann-Kendall Trend", "Mann-Kendall", "KPSS Test for Trend"),
    H0 = rep("Não tendência", 5),
    p_valor = round(p_value, 4),
    Conclusao = p_value1
  )
  
  list(CS = CS, CeST = CeST, MannKT = MannKT, MannK = MannK, KPSST = KPSST, Tabela = tabela)
}

resultado_tendencia <- tend_determ(serie_temporal)
print(resultado_tendencia$Tabela)

# ---- testes de raiz unitária ----
raiz_unit <- function(ts) {
  ADF <- suppressWarnings(tseries::adf.test(ts, alternative = "stationary"))
  PP  <- suppressWarnings(tseries::pp.test(ts, alternative = "stationary"))
  KPSSL <- suppressWarnings(tseries::kpss.test(ts, null = "Level"))
  
  p_value <- c(ADF$p.value, PP$p.value, KPSSL$p.value)
  p_value1 <- ifelse(p_value[1:2] >= 0.05, "Tendência", "NAO tendência")
  p_value2 <- ifelse(p_value[3] >= 0.05, "NAO tendência", "Tendência")
  
  tabela <- data.frame(
    Testes = c("Augmented Dickey-Fuller", "Phillips-Perron Unit Root", "KPSS Test for Level"),
    H0 = c("Tendência", "Tendência", "NAO tendência"),
    p_valor = round(p_value, 4),
    Conclusao = c(p_value1, p_value2)
  )
  
  list(ADF = ADF, PP = PP, KPSSL = KPSSL, Tabela = tabela)
}

resultado_raiz_unitaria <- raiz_unit(serie_temporal)
print(resultado_raiz_unitaria$Tabela)

# ---- testes de sazonalidade ----
sazonalidade <- function(ts, diff = 0, freq = 12) {
  KrusW <- suppressWarnings(seastests::kw(ts, diff = diff, freq = freq))
  Fried <- suppressWarnings(seastests::fried(ts, diff = diff, freq = freq))
  
  p_value <- c(KrusW$Pval, Fried$Pval)
  p_value1 <- ifelse(p_value >= 0.05, "NAO sazonal", "Sazonal")
  
  tabela <- data.frame(
    Testes = c("Kruskal-Wallis", "Friedman rank"),
    H0 = rep("NAO sazonal", 2),
    p_valor = round(p_value, 4),
    Conclusao = p_value1
  )
  
  list(KrusW = KrusW, Fried = Fried, Tabela = tabela)
}

resultado_sazonalidade <- sazonalidade(serie_temporal)
print(resultado_sazonalidade$Tabela)

# ---- ajuste ETS ----
n <- length(serie_temporal)

y <- serie_temporal[1:(n - 12)]
y <- ts(y, start = c(2001, 1), frequency = 12)

mod <- ets(y)
summary(mod)

accuracy(mod)

# ---- observado vs ajustado ----
data <- data.frame(
  Tempo = as.Date(as.yearmon(time(y))),
  Observada = as.numeric(y),
  Ajustada = as.numeric(mod$fitted)
)

ggplot(data) +
  geom_line(aes(x = Tempo, y = Observada, color = "Observada"), size = 1) +
  geom_line(aes(x = Tempo, y = Ajustada, color = "Ajustada"), size = 1) +
  labs(
    x = "Tempo",
    y = "Valores da Série",
    color = "Legenda"
  ) +
  scale_color_manual(
    values = c("Observada" = "black", "Ajustada" = "red")http://127.0.0.1:44437/graphics/2ab34be6-5b1a-41a8-a09d-7caf24b816d5.png
  ) +
  scale_x_date(
    date_breaks = "2 year",
    date_labels = "%Y"
  ) +
  tema_personalizado +
  theme(
    legend.position = "top",
    legend.background = element_rect(fill = "white", color = NA),
    legend.title = element_blank()
  )

# ---- previsão ----
mod %>% forecast(h = 12) %>%
  autoplot() +
  ylab("Velocidade Media") +
  tema_personalizado

# ---- resíduos: comparação ----
cbind(
  'Residuals' = residuals(mod),
  'Forecast errors' = residuals(mod, type = 'response')
) %>%
  autoplot(facet = TRUE) + xlab("Year") +
  ylab("") +
  tema_personalizado

# ---- resíduos e diagnósticos ----
res_ets <- residuals(mod)

ggtsdisplay(res_ets, plot.type = "histogram", theme = theme_bw() + tema_personalizado)

# ---- normalidade e estacionariedade dos resíduos ----
ggqqplot(res_ets) + ggtitle("Resíduo do Modelo") + tema_personalizado
shapiro.test(res_ets)
adf.test(res_ets)

# ---- autocorrelação dos resíduos ----
Box.test(res_ets, lag = 10)

# ---- gráfico de controle de medidas individuais para os resíduos ----

residuos_vento_inicial <- qcc(data=res_ets, type="xbar.one", std.dev="MR", 
                              k=3, nsigmas=3, # k=3 para 3-sigma (padrão)
                              title="Gráfico de controle de medidas individuais para os resíduos",
                              xlab = "Amostras", ylab = "Resíduos do ETS")

# ---- remoção causas especiais ----

pontos_fora_controle <- c(10, 77, 138) 

# ---- cria vetor de índices que mantêm apenas os pontos dentro de controle ----

removedor_vento <- 1:length(res_ets)
removedor_vento <- removedor_vento[!(removedor_vento %in% pontos_fora_controle)]

# ---- gráfico de controle com causas especiais removidas ----

novoslimites_vento <- qcc(data=res_ets[removedor_vento], type="xbar.one",
                          std.dev="MR", nsigmas=3, k=3,
                          title="Gráfico de controle com causas especiais removidas (Recálculo)",
                          xlab = "Amostras", ylab = "Resíduos do ETS") # Este gráfico mostra apenas os pontos 'sob controle'

# ---- gráfico de controle com os novos limites ----

resid_new_vento <- qcc(data=res_ets, type="xbar.one",
                       k=3, nsigmas=3,
                       center=novoslimites_vento$center, # Usa a nova Linha Central
                       limits=novoslimites_vento$limits, # Usa os novos Limites (UCL/LCL)
                       title="Gráfico de controle com os novos limites (Processo Sob Controle)",
                       xlab = "Amostras", ylab = "Resíduos do ETS")

