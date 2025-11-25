# Modelagem estatística e análise de séries temporais

Este repositório é destinado para diversos projetos de Análise e Modelagem de Séries Temporais, utilizando metodologias estatísticas avançadas como a família $\text{ARIMA}$ (Box-Jenkins) e $\text{ETS}$ (Suavização Exponencial). 

O objetivo principal de cada projeto é conduzir o ciclo completo de análise:

1.  Diagnóstico exploratório: Identificação de tendência, sazonalidade e volatilidade.
2.  Modelagem: Ajuste do modelo mais adequado para capturar a estrutura de dependência.
3.  Validação: Verificação dos resíduos para garantir as premissas de Ruído Branco e normalidade.
4.  Projeção e monitoramento: Geração de previsões futuras e monitoramento da variabilidade residual.

---

## Estrutura do repositório

```bash

├── series-saldo-de-emprego/     # análise do saldo de emprego no Maranhão
│   ├── img/                           # pasta com as figuras 
│   ├── MA.txt                       # conjunto de dados original
│   ├── codigo.R                     # script R para a modelagem
│   └── relatorio.md                 # relatório detalhado da análise
├── series-vento/                # análise da velocidade média do vento em Brasília
│   ├── img/                           # pasta com as figuras 
│   ├── codigo.R                     # script R para a modelagem 
│   ├── relatorio.md                 # relatório detalhado da análise
│   └── wind-brasilia.txt            # conjunto de dados original
└── README.md
```

---

## Destaques e resultados principais

### 1. Saldo de emprego no Maranhão (SARIMA)

A análise do saldo de emprego confirmou uma série com alta volatilidade e forte sazonalidade anual. A série foi marcada por choques macroeconômicos ($\text{2008}$ e $\text{2015}$) e apresentou uma tendência determinística sutilmente negativa. O modelo **$\text{SARIMA}$** foi validado com sucesso. O Teste de $\text{Ljung-Box}$ para os resíduos ($\mathbf{p\text{-valor} = \text{0.3824}}$) e o $\text{QQ-Plot}$ confirmaram que os erros são Ruído Branco e aproximadamente normais. O modelo está estatisticamente apto a gerar previsões confiáveis que incorporam o padrão sazonal e a tendência histórica.

### 2. Velocidade do vento em Brasília (ETS + CEP)

A análise da velocidade do vento combinou a modelagem com o monitoramento de qualidade. Utilizou-se o modelo **$\text{ETS}(\text{A},\text{N},\text{A})$** para capturar a sazonalidade e a dependência da série. Após a modelagem, o Gráfico de Controle para Valores Individuais foi aplicado aos resíduos. Inicialmente, três pontos fora de controle (Causas Especiais) foram detectados. Os limites de controle foram recalculados após a remoção dessas causas, resultando em um processo residual sob controle estatístico, garantindo a estabilidade e validade das previsões.

---

## Tecnologias Utilizadas

* **Linguagem:** $\text{R}$

---
