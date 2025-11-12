# Análise e Monitoramento da Velocidade do Vento em Brasília (2001-2018)

## 1. Introdução

<p style="text-align: justify;">
O monitoramento de fenômenos naturais, como a velocidade do vento, é crucial para diversas aplicações, notadamente na área de energias renováveis e na climatologia. A velocidade do vento em Brasília (Estação 83377), no período de janeiro de 2001 a dezembro de 2018, apresenta flutuações e padrões sazonais bem definidos, com picos nos meses de agosto e setembro.

A presença de dependência temporal e sazonalidade na série viola o pressuposto de independência estatística necessário para a aplicação direta de técnicas tradicionais de Controle Estatístico de Processo (CEP), como o Gráfico de Controle para Valores Individuais. O CEP é uma ferramenta vital para garantir que um processo esteja operando sob controle estatístico, diferenciando a variabilidade comum da variabilidade por causas especiais.

O presente trabalho aplica uma metodologia robusta que integra a modelagem de séries temporais com o CEP. Utiliza-se o modelo Autorregressivo Integrado de Médias Móveis Sazonal (SARIMA) (Metodologia Box-Jenkins) para remover a estrutura de autocorrelação e sazonalidade da série. Os resíduos resultantes deste modelo, que se espera que se comportem como Ruído Branco (série independente e identicamente distribuída), serão então monitorados por meio do Gráfico de Controle para Valores Individuais. 
</p>
---

## 2. Objetivos

### Objetivo Geral

Monitorar a série temporal da velocidade média do vento em Brasília (m/s), no período de 2001 a 2018, utilizando o Gráfico de Controle para Valores Individuais ($I$-Chart) aplicado aos resíduos de um modelo SARIMA ajustado.

### Objetivos Específicos

* Realizar a análise exploratória da série temporal, incluindo decomposição aditiva e análise de correlogramas (FAC e FACP).
* Identificar, estimar e validar o modelo **SARIMA** que melhor descreva a dependência temporal e sazonal da série.
* Diagnosticar os resíduos do modelo ajustado, verificando as premissas de independência (Ruído Branco) e normalidade (Testes de Ljung-Box e Shapiro-Wilk).
* Apresentar e interpretar o Gráfico de Controle para Valores Individuais dos resíduos para verificar a estabilidade do processo.

---

## 3. Metodologia
A metodologia aplicada para a análise e o monitoramento da série temporal da velocidade do vento segue uma abordagem integrada, combinando a modelagem estatística preditiva do método Box-Jenkins com o Controle Estatístico de Processo (CEP) nos resíduos, conforme adaptado de (MOREIRA JUNIOR, 2021). Esta abordagem visa não apenas prever a série, mas também validar e monitorar a qualidade do ajuste. 

Inicialmente, realiza-se a análise inicial e pré-tratamento da série Temporal. Nesta etapa, a série da velocidade do vento é diagnosticada quanto à presença de componentes estruturais, como tendência, sazonalidade e, principalmente, não-estacionariedade. A não-estacionariedade é verificada formalmente através de testes de raiz unitária, como o de Phillips-Perron (PP) e o Aumentado de Dickey-Fuller (ADF). Devido à forte sazonalidade anual ($s=12$) observada, o modelo escolhido é o SARIMA (Sazonal ARIMA), na forma geral $\text{SARIMA}(p, d, q) \times (P, D, Q)_{12}$.

A modelagem SARIMA prossegue seguindo as três fases clássicas de Box-Jenkins. A Fase I é a identificação, na qual as ordens iniciais dos componentes autorregressivos ($p, P$) e de média móvel ($q, Q$) são determinadas. Isso é feito por meio da análise visual da Função de Autocorrelação (FAC) e da Função de Autocorrelação Parcial (FACP) da série já diferenciada. Em seguida, na Fase II, os parâmetros dos modelos candidatos são estimados por Máxima Verossimilhança. O modelo final é selecionado com base na parcimônia e na qualidade do ajuste, utilizando-se o Critério de Informação de Akaike (AIC) e Critério de Informação Bayesiano (BIC), preferindo-se sempre o modelo com o menor valor.

A \Fase III é a etapa de validação. Os resíduos ($\hat{a}_t$) do modelo ajustado devem necessariamente se comportar como um Ruído Branco Estacionário, o que significa que o modelo extraiu toda a estrutura de dependência da série. O diagnóstico é bifásico: a independência (ausência de autocorrelação) é verificada pelos correlogramas dos resíduos e formalizada pelo Teste de Ljung-Box ($p$-valor $> 0,05$), e a normalidade é verificada pelo histograma, gráfico Q-Q e formalmente pelo Teste de Shapiro-Wilk ($p$-valor $> 0,05$).

Finalmente, o Controle Estatístico de Processo (CEP) é aplicado aos resíduos ($\hat{a}_t$) validados do modelo SARIMA. O Gráfico de Controle para Valores Individuais ($I$-Chart) é construído para monitorar a variabilidade residual do processo, com os limites de controle. O objetivo do CEP é identificar causas especiais (pontos fora dos limites) no processo de erro do modelo, garantindo que o processo residual esteja estatisticamente sob controle para que as previsões sejam válidas e monitoráveis (MOREIRA JUNIOR, 2021).
