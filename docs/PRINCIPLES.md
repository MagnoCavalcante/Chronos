# PRINCIPLES: Os Princípios Fundamentais

Este documento detalha os princípios que governam o desenvolvimento de software, a arquitetura de informação, o design de interface e a curadoria de dados no ecossistema CHRONOS. Qualquer alteração ou nova funcionalidade deve respeitar estes pilares.

---

## 1. Diferenciação Estrita de Fatos, Interpretações e Hipóteses
* **Categoria**: Produto
* **Explicação**: Dados históricos têm diferentes níveis de certeza. Fatos arqueologicamente confirmados diferem de interpretações consolidadas e de hipóteses especulativas.
* **Motivação**: Evita a distorção do conhecimento e o dogmatismo, ensinando o usuário a pensar criticamente como um cientista da história.
* **Exemplo Prático**: Na interface do CHRONOS, a data de nascimento de Júlio César é exibida como fato historiográfico documentado, enquanto as intenções psicológicas por trás de suas decisões são categorizadas estritamente como interpretações de diferentes correntes historiográficas, cada uma claramente identificada.

## 2. Rastreabilidade Absoluta e Fontes Identificáveis
* **Categoria**: Produto
* **Explicação**: Toda e qualquer afirmação importante sobre uma era, evento, personagem ou artefato histórico no ecossistema deve possuir um link claro ou referência bibliográfica legível.
* **Motivação**: A autoridade não é nossa, é das evidências. Isso protege a integridade do projeto contra fake news e viés subjetivo.
* **Exemplo Prático**: No rodapé de cada cartão ou visualização detalhada, há um painel colapsável chamado "Fontes e Evidências" listando os registros primários ou artigos acadêmicos que apoiam a informação mostrada.

## 3. Interface Sóbria, Fluida e Minimalista
* **Categoria**: UX
* **Explicação**: A interface deve ser simples, limpa e com alto contraste, utilizando o espaço negativo de forma consciente e focando na informação.
* **Motivação**: O excesso de elementos visuais polui a mente e desvia o foco do fluxo temporal e do conteúdo histórico.
* **Exemplo Prático**: O layout do CHRONOS utiliza uma tipografia de exibição elegante (como *Space Grotesk*) para títulos e uma fonte mono (como *JetBrains Mono*) para metadados e anos. Não há decorações desnecessárias, botões flutuantes intrusivos ou animações exageradas.

## 4. Compreensão Cognitiva Sobre Memorização Mecânica
* **Categoria**: UX
* **Explicação**: O aplicativo deve priorizar a explicação das redes de causa e efeito, em vez de simplesmente exigir que o usuário decore nomes e datas.
* **Motivação**: A verdadeira educação histórica ocorre quando o usuário percebe os padrões políticos, sociais e científicos de uma época, e como eles influenciam a era subsequente.
* **Exemplo Prático**: Em vez de apresentar uma lista de datas isoladas da Revolução Científica, a interface exibe um fluxo em grafo mostrando como a tradução de textos helenísticos e o avanço da metalurgia criaram o substrato ideal para o desenvolvimento da imprensa e a circulação das teses astronômicas.

## 5. Transparência Acima de Autoridade
* **Categoria**: Produto
* **Explicação**: O desenvolvimento de nosso ecossistema e a curadoria dos dados são abertos e auditáveis. Qualquer alteração no banco de dados ou no código-fonte pode ser contestada publicamente.
* **Motivação**: O conhecimento coletivo e o escrutínio aberto são os melhores filtros para garantir a neutralidade científica e a evolução técnica do sistema.
* **Exemplo Prático**: Usamos o GitHub como repositório público de discussões técnicas e revisões de esquemas de dados, permitindo que qualquer pessoa aponte inconsistências em uma data ou proponha correções de modelagem.

## 6. Incentivo Ativo à Curiosidade e Exploração Livre
* **Categoria**: UX
* **Explicação**: A navegação não deve prender o usuário em funis estritamente lineares. A interface deve convidar o usuário a "perder-se" produtivamente na história.
* **Motivação**: O aprendizado autônomo e a paixão pela descoberta ocorrem quando puxamos um fio do conhecimento e somos levados a novas e inesperadas perguntas.
* **Exemplo Prático**: Ao navegar pela Era das Descobertas, o usuário pode clicar em um elemento secundário (como "Técnicas de Astrolábio") e ser suavemente redirecionado para a Idade de Ouro Islâmica, observando a herança tecnológica direta.

## 7. Tecnologia Neutra e Origem Transparente da Informação
* **Categoria**: Arquitetura
* **Explicação**: A tecnologia (incluindo inteligência artificial, se houver) nunca deve gerar conhecimento sintético sem fontes reais ou mascarar a origem original das informações.
* **Motivação**: IA generativa e processadores de dados podem criar alucinações. O CHRONOS usa IA apenas como assistente de estruturação de dados, mantendo o controle editorial em fontes historiográficas reais.
* **Exemplo Prático**: Se a IA for utilizada para resumir uma biografia, o resumo é exibido com um selo de autoria indicando o modelo utilizado e as fontes historiográficas exatas nas quais o resumo se baseou para a validação humana.

## 8. Escalabilidade Arquitetural Sustentável
* **Categoria**: Arquitetura
* **Explicação**: O banco de dados e o código do aplicativo devem ser desenhados de forma modular e limpa, prevendo um crescimento exponencial de dados sem degradação de performance.
* **Motivação**: Um ecossistema de conhecimento global acumula milhões de registros ao longo dos anos. A falta de arquitetura limpa inviabilizaria o projeto no longo prazo.
* **Exemplo Prático**: O modelo de dados separa estritamente as entidades em tabelas base imutáveis e resolve as conexões dinâmicas de causalidade por meio de chaves de relação limpas, mantendo o banco ágil e prevenindo a sobrecarga das consultas na UI.
