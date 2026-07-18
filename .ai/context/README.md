# Documentos de Contexto (/.ai/context)

Este diretório abriga os documentos estruturados que fornecem contexto especializado para as IAs durante os processos de geração ou curadoria no projeto CHRONOS.

---

## 🧭 Objetivo

Funcionar como a "âncora de realidade" (Grounding / RAG) para os modelos de inteligência artificial. Estes arquivos contêm fatos pré-aprovados, terminologias específicas, limites geográficos e esquemas ontológicos que impedem as IAs de gerarem dados fora dos padrões científicos estabelecidos pela historiografia moderna.

---

## 🗂️ Exemplos de Conteúdo e Arquivos

*   `ontologies/`: Contém arquivos de definição de entidades e relacionamentos do grafo (como especificado no CKE - CHRONOS Knowledge Engine).
*   `historical_vocabularies/`: Arquivos de mapeamento de terminologias de difícil tradução (ex: cargos públicos em Roma, armas de cerco helenísticas, termos de parentesco dinásticos).
*   `geography_context/`: Mapeamento de nomes de cidades e regiões históricas com suas respectivas coordenadas ou equivalências modernas (ex: *Batalha de Canas* -> Localizada em *Apúlia, Itália*).

---

## 🎯 Exemplo de Uso

Ao solicitar à IA que elabore a ficha de um novo personagem histórico, o script de ingestão do backend deve concatenar o conteúdo de `ontologies/cke_ontology.json` à requisição, instruindo o modelo a formatar a saída de acordo com o esquema conceitual do motor semântico.

---

## 🛡️ Boas Práticas

1. **Rigor Científico Elevado:** Os documentos de contexto devem ser revisados por historiadores humanos antes de serem salvos nesta pasta.
2. **Formatos Leves:** Prefira utilizar formatos estruturados leves, como JSON ou Markdown simplificado, garantindo facilidade de leitura pelas IAs e economia de tokens.
3. **Mantenha Atualizado:** Se um novo personagem ou batalha de relevância for validado pela arqueologia, atualize os dicionários de contexto para refletirem a descoberta mais recente.
