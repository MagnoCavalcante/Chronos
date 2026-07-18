# Recursos Estáticos e Mídias (/assets)

Este diretório centraliza todos os arquivos de recursos estáticos, mídias e ativos visuais ou sonoros utilizados no ecossistema CHRONOS.

---

## 🧭 Objetivo

Garantir que todos os ativos visuais, sonoros e tipográficos do CHRONOS sejam organizados sob uma estrutura clara de nomenclatura e compressão. Isso assegura que o aplicativo Flutter consiga carregar e renderizar mídias com extrema rapidez, mantendo o tamanho do instalador (APK/IPA) otimizado e a qualidade estética impecável.

---

## 🗂️ Estrutura de Subdiretórios

Para facilitar o gerenciamento de mídias, a pasta é subdividida em categorias explícitas:

```
assets/
├── icons/              # Ícones personalizados da interface (SVG / vetores)
├── images/             # Fotos de achados arqueológicos, museus e locais históricos reais
├── illustrations/      # Ilustrações autorais e reconstituições artísticas de civilizações
├── maps/               # Camadas de dados geográficos, arquivos GeoJSON e mapas cartográficos
├── animations/         # Animações de interface (arquivos Lottie ou Rive)
├── audio/              # Efeitos sonoros, trilhas sonoras ambientes e narrações históricas
└── fonts/              # Fontes tipográficas locais exclusivas do projeto
```

### 1. `icons/`
*   **Finalidade:** Armazenar ícones de interface específicos do CHRONOS (ex: brasões de civilizações, símbolos mitológicos e marcadores de mapa). Devem ser salvos estritamente no formato vetorial **SVG** para manter a escalabilidade sem perda de resolução.

### 2. `images/`
*   **Finalidade:** Fotos reais e científicas de peças arqueológicas, locais históricos ou documentos primários.
*   **Boas Práticas:** Devem ser otimizadas e comprimidas em formatos modernos como **WebP** ou **AVIF**, reduzindo drasticamente o consumo de banda sem perda visível de qualidade visual.

### 3. `illustrations/`
*   **Finalidade:** Reconstituições artísticas, artes conceituais e recriações de cenários de época (ex: uma ilustração mostrando como era o Farol de Alexandria em seu auge).

### 4. `maps/`
*   **Finalidade:** Arquivos vetoriais ou rasterizados que definem as fronteiras dos impérios do passado em diferentes anos, rotas de campanhas militares ou posições geográficas de sítios de escavação (ex: arquivos GeoJSON ou KML).

### 5. `animations/`
*   **Finalidade:** Animações interativas de alta performance e peso ultra-leve para micro-interações do aplicativo (ex: efeito de ondas de choque em batalhas ou transição fluida do fluxo do tempo). Prefira usar formatos vetoriais dinâmicos como **Lottie (JSON)** ou **Rive (.riv)**.

### 6. `audio/`
*   **Finalidade:** Efeitos sonoros de transição cronológica, narrações educacionais curtas e áudios de ambientação meditativa ou épica. Devem ser comprimidos em **MP3** de alta qualidade ou **Ogg/AAC**.

### 7. `fonts/`
*   **Finalidade:** Arquivos de fontes tipográficas específicas do projeto (ex: *Space Grotesk* para cabeçalhos e *JetBrains Mono* para dados de telemetria temporal). Os arquivos devem estar nos formatos **TTF** ou **OTF**.

---

## 🎯 Exemplos de Organização e Nomenclatura

*   **Ícones:** `assets/icons/ic_shield_roman.svg` (Prefixo de finalidade + tema + variante)
*   **Imagens:** `assets/images/colosseum_exterior_rome.webp` (Nome do artefato/local + detalhe + região)
*   **Áudios:** `assets/audio/sfx_time_travel_launch.mp3` (Indicador de efeito sonoro + ação)

---

## 🛡️ Boas Práticas de Ativos

1. **Compressão Obrigatória:** Nunca insira imagens brutas (PNGs de câmera de celular de 15MB) ou áudios não comprimidos (WAV). Use compressores para converter imagens para **WebP** com qualidade em torno de 80-85%.
2. **Nomenclatura Snake_Case:** Todos os arquivos de ativos devem usar letras estritamente minúsculas unidas por underline (`snake_case`), para evitar problemas de compatibilidade no Flutter e em diferentes sistemas operacionais de servidores.
3. **Resoluções Responsivas:** Para imagens rasterizadas que necessitem de grande fidelidade, salve-as em dimensões múltiplas recomendadas para que o Flutter possa carregar a versão correta de acordo com a densidade de pixels da tela do usuário.
