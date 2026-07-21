# CHRONOS — Guia de Aplicação de Marca
## Versão 1.0 — Diretrizes Gráficas (Sprint 5.2.3)

Este guia prático orienta designers e desenvolvedores na correta aplicação e renderização da identidade visual do CHRONOS em todas as interfaces.

---

## 1. Naming & Nomenclatura Oficial

A consistência de marca começa com a forma como nos comunicamos:

- **Nome Oficial**: **CHRONOS** (sempre grafado em maiúsculas quando em destaque, ou "Chronos" em parágrafos corridos).
- **Nome Curto**: **Chronos**
- **Tagline**: *"O Tempo em Camadas"* (ou *"As Camadas do Tempo e da História"*).

---

## 2. Aplicação de Logotipos e Vetores

Todas as renderizações da marca devem utilizar os SVGs oficiais localizados em `assets/branding/`.

- **chronos_logo_dark.svg**: Utilizado em interfaces escurecidas ou com fundo `#1E3A5F` (Azul Profundo).
- **chronos_logo_light.svg**: Utilizado em interfaces claras com fundo `#F8F6F0` (Off-white).
- **chronos_icon.svg**: O ícone simplificado para uso em avatares, favicons e marcações de tamanho reduzido (até 16px).

---

## 3. Diretrizes de Interface e Elementos Visuais

### 3.1 Botões e Chips
- Devem seguir cantos sutilmente arredondados (`border-radius: 4px` a `8px`) para manter a sobriedade.
- O botão primário deve utilizar fundo `#1E3A5F` com texto claro.
- Os chips de filtragem ativa utilizam borda e preenchimento de opacidade leve com a cor dourada antiga `#C9A227`.

### 3.2 Linha do Tempo (Timeline Component)
- A linha central de conexão deve ser uma divisória de espessura de `2dp` na cor neutra clara.
- O nó indicador de data ativa usa a cor de acento `#C9A227` em formato circular simples de `12dp`.

---

## 4. Auditoria de Contraste e Legibilidade

- **Texto Principal**: `#1F2937` sobre fundo `#F8F6F0` possui taxa de contraste de **11.2:1**, excedendo amplamente a recomendação mínima WCAG AAA de 7:1.
- **Destaque Secundário**: Ouro Antigo `#C9A227` sobre Azul Profundo `#1E3A5F` possui excelente contraste para indicação de foco e status ativos.
