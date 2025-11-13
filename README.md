# Modelagem Estatística e Análise de Séries Temporais

Este repositório é destinado para diversos projetos de Análise e Modelagem de Séries Temporais, utilizando metodologias estatísticas avançadas como a família $\text{ARIMA}$ (Box-Jenkins) e $\text{ETS}$ (Suavização Exponencial). 

O objetivo principal de cada projeto é conduzir o ciclo completo de análise:

1.  Diagnóstico Exploratório: Identificação de tendência, sazonalidade e volatilidade.
2.  Modelagem: Ajuste do modelo mais adequado para capturar a estrutura de dependência.
3.  Validação Rigorosa: Verificação dos resíduos para garantir as premissas de Ruído Branco e normalidade.
4.  Projeção e Monitoramento: Geração de previsões futuras e monitoramento da variabilidade residual.

---

## Estrutura do Repositório

├── series-saldo-de-emprego/         # Análise do saldo de emprego no Maranhão
│   ├── img/                         # Gráficos 
│   ├── MA.txt                       # Conjunto de dados original
│   ├── codigo.R                     # Script R para a modelagem
│   └── relatorio.md                 # Relatório detalhado da análise
├── series-vento/                    # Análise da velocidade média do vento em Brasília
│   ├── img/                         # Gráficos 
│   ├── codigo.R                     # Script R para a modelagem 
│   ├── relatorio.md                 # Relatório detalhado da análise
│   └── wind-brasilia.txt            # Conjunto de dados original
└── README.md

---

## Destaques e Resultados Principais

### 1. Saldo de Emprego no Maranhão (SARIMA)

A análise do saldo de emprego confirmou uma série com alta volatilidade e forte sazonalidade anual. A série foi marcada por choques macroeconômicos ($\text{2008}$ e $\text{2015}$) e apresentou uma tendência determinística sutilmente negativa. O modelo **$\text{SARIMA}$** foi validado com sucesso. O Teste de $\text{Ljung-Box}$ para os resíduos ($\mathbf{p\text{-valor} = \text{0.3824}}$) e o $\text{QQ-Plot}$ confirmaram que os erros são Ruído Branco e aproximadamente normais. O modelo está estatisticamente apto a gerar previsões confiáveis que incorporam o padrão sazonal e a tendência histórica.

### 2. Velocidade do Vento em Brasília (ETS + CEP)

A análise da velocidade do vento combinou a modelagem com o monitoramento de qualidade. Utilizou-se o modelo **$\text{ETS}(\text{A},\text{N},\text{A})$** para capturar a sazonalidade e a dependência da série. Após a modelagem, o Gráfico de Controle para Valores Individuais foi aplicado aos resíduos. Inicialmente, três pontos fora de controle (Causas Especiais) foram detectados. Os limites de controle foram recalculados após a remoção dessas causas, resultando em um processo residual sob controle estatístico, garantindo a estabilidade e validade das previsões.

---

## Tecnologias Utilizadas

* **Linguagem:** $\text{R}$

---
