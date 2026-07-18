# Cartografia e Mapas Históricos (/knowledge/maps)

Este diretório contém os estudos geográficos, arquivos de coordenadas, esquemas de fronteiras imperiais e rotas de comércio que alimentam as representações cartográficas e o motor espacial-temporal do CHRONOS.

---

## 🧭 Objetivo

Garantir precisão geográfica milimétrica nas projeções cartográficas do aplicativo. Ao invés de mapas ilustrativos fictícios, o CHRONOS projeta as fronteiras reais e mutáveis dos impérios e pólis com base em dados de georreferenciamento histórico acadêmico contemporâneo.

---

## 🗂️ Estrutura de Informação Geoespacial

Os arquivos nesta pasta servem de rascunhos conceituais e guias de modelagem de dados contendo:

1.  **Fronteiras Geopolíticas Dinâmicas:** Definições vetoriais (GeoJSON) contendo polígonos que representam as alterações territoriais de civilizações ao longo de marcos temporais explícitos.
2.  **Sítios de Interesse (POI - Points of Interest):** Coordenadas geográficas exatas (latitude e longitude) de cidades antigas, templos, fortes e sítios arqueológicos correlatos.
3.  **Rotas Comerciais e Campanhas Militares:** Caminhos geográficos lineares descrevendo expedições de exploração (ex: Rota da Seda) ou campanhas de invasão (ex: Travessia dos Alpes por Aníbal Barca).

---

## 🎯 Modelo de Especificação Cartográfica

```markdown
# [GeoRef] Fronteiras Ptolemaicas - Ano 49 a.C.

-   **Civilização:** Egito Ptolemaico
-   **Ano de Recorte:** 49 a.C.
-   **Polígono GeoJSON de Referência:** `assets/maps/geojson/egypt_49bc.json`

## 🧭 Descrição Geopolítica
[Resumo sobre as fronteiras administrativas e disputas territoriais da época, incluindo guarnições militares compartilhadas ou províncias anexadas recentemente]

## 📍 Coordenadas de Pontos de Interesse (POIs)
*   **Alexandria:** `31.2001, 29.9187`
*   **Tebas:** `25.6872, 32.6396`
*   **Pelúsio (Fortaleza):** `31.0416, 32.5452`
```

---

## 🛡️ Boas Práticas

1. **Evite Projeções Anacrônicas:** Utilize projeções de mapas cartográficos baseados no sistema global `WGS84`, garantindo compatibilidade direta com serviços de mapas interativos modernos (como Google Maps Platform e mapas vetoriais reativos do Flutter).
2. **Defina os Períodos de Validade:** Territórios na antiguidade alteravam-se de forma volátil após cercos e tratados. Certifique-se de associar cada mapa a um ano inicial e final explícitos de estabilidade política.
3. **Represente Áreas de Controle Indireto:** Nem toda região do passado pertencia de forma centralizada a um império. Distinga em cores e opacidades as áreas de dominação direta (províncias) de zonas de influência tributária (reinos clientes).
