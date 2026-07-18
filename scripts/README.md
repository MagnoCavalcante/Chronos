# Scripts de Automação e Utilitários (/scripts)

Este diretório centraliza todos os scripts utilitários, tarefas automatizadas, ferramentas de linha de comando e scripts de validação de dados utilizados no projeto CHRONOS.

---

## 🧭 Objetivo

Automatizar tarefas repetitivas de desenvolvimento, manipulação de banco de dados e controle de qualidade editorial. Através dos scripts centralizados nesta pasta, desenvolvedores e historiadores podem validar formatos de arquivos, converter mídias, injetar sementes (seeds) de dados de forma automatizada no Supabase e auditar a conformidade técnica do repositório.

---

## 🗂️ Exemplos de Scripts Planejados

1.  **`validate_dossiers.py` / `validate_dossiers.js`:** Script que varre recursivamente a pasta `knowledge/dossiers/` para garantir que todos os arquivos Markdown contenham as tags YAML obrigatórias no frontmatter e links bibliográficos válidos.
2.  **`optimize_assets.sh`:** Script shell para automatizar a conversão de imagens brutas (PNG/JPG) da pasta `assets/` para formatos modernos compactados (WebP) com perda de qualidade parametrizada.
3.  **`db_seed_pusher.js`:** Script utilitário para converter os arquivos de dossiê do Markdown estruturado para objetos JSON e injetá-los diretamente nas tabelas correspondentes da API REST do Supabase.

---

## 🎯 Exemplo de Uso de Script de Validação

Para rodar a validação local de integridade de metadados nos dossiês editoriais antes de realizar um commits:
```bash
# Executa o script de auditoria de metadados
node scripts/validate_dossiers.js --dir=knowledge/dossiers/
```

---

## 🛡️ Boas Práticas

1. **Evite Scripts Destrutivos Sem Confirmação:** Qualquer script de automação que execute exclusões no banco de dados ou deleção em massa de arquivos de mídia deve obrigatoriamente solicitar uma confirmação manual no terminal (`y/n`) antes de prosseguir.
2. **Documentação Interna Exaustiva:** Insira cabeçalhos explicativos e comentários bem estruturados dentro do próprio código do script para orientar futuros desenvolvedores sobre os parâmetros de entrada e dependências necessárias.
3. **Não Declare Segredos Hardcoded:** Assim como em qualquer parte do projeto, credenciais de acesso, tokens do Supabase ou chaves do Google AI Studio nunca devem estar salvas de forma estática dentro do código dos scripts. Faça sempre a leitura via variáveis de ambiente (`process.env` ou `os.environ`).
