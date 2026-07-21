# CHRONOS — Design Tokens & Design System
## Versão 1.0 — Guia de Engenharia de Design (Sprint 5.2.3)

Este documento define a única fonte oficial de tokens visuais que devem ser importados e consumidos pelos componentes do ecossistema CHRONOS.

---

## 1. Cores (Color Tokens)

| Token Name | Hex Value | Role / Usage | Contrast Ratio |
| :--- | :--- | :--- | :--- |
| `color-primary` | `#1E3A5F` | Cor institucional primária (Azul Profundo) | 5.8:1 contra branco |
| `color-accent` | `#C9A227` | Acentuações de status ativos e focos (Dourado) | 3.5:1 contra escuro |
| `color-bg-light` | `#F8F6F0` | Plano de fundo de canvas principal (Off-white) | 11.2:1 contra texto |
| `color-text-main` | `#1F2937` | Texto principal altamente legível (Charcoal) | 11.2:1 contra bg-light |
| `color-text-muted` | `#6B7280` | Legendas, subtítulos e pequenos rótulos | 4.8:1 contra bg-light |
| `color-border` | `#E5E7EB` | Linhas de divisão e contornos neutros suaves | — |

---

## 2. Tipografia (Typography Tokens)

- **`font-family-display`**: `"Cinzel", Georgia, serif`
  - Utilizada exclusivamente em títulos de destaque, títulos de páginas e cabeçalhos de eras históricas.
- **`font-family-sans`**: `"Inter", ui-sans-serif, system-ui, sans-serif`
  - Utilizada em todo o texto de corpo, formulários, botões e controles interativos de interface.
- **`font-family-mono`**: `"JetBrains Mono", ui-monospace, SFMono-Regular, monospace`
  - Utilizada para datas cronológicas (ex: `-3100 a.C.`), contadores numéricos, IDs e metadados.

---

## 3. Raios de Borda (Border Radius Tokens)

- **`radius-sm`**: `4px` — Aplicado em botões pequenos, chips e tags de status.
- **`radius-md`**: `8px` — Aplicado em cards menores, barras de busca e formulários.
- **`radius-lg`**: `12px` — Aplicado em cards de destaque, diálogos e bottom sheets.
- **`radius-full`**: `9999px` — Aplicado em avatares e contornos de botões ovais (pill buttons).

---

## 4. Spacing & Padding Tokens

- **`spacing-xs`**: `4px`
- **`spacing-sm`**: `8px`
- **`spacing-md`**: `16px`
- **`spacing-lg`**: `24px`
- **`spacing-xl`**: `32px`
- **`spacing-xxl`**: `48px`
