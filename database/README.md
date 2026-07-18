# Banco de Dados Supabase & PostgreSQL (/database)

Este diretório centraliza toda a lógica de modelagem física, segurança de acessos, migrações incrementais e carregamento de dados estáticos para a base de dados do projeto CHRONOS, baseada no **Supabase** e alimentada pelo **PostgreSQL**.

---

## 🧭 Objetivo

Garantir que a estrutura do banco de dados relacional seja versionada de forma profissional e segura. Através deste repositório, desenvolvedores e o sistema de CI/CD podem recriar, migrar, auditar e testar o banco de dados completo do CHRONOS em qualquer ambiente (desenvolvimento local, staging ou produção), assegurando que nenhuma política de segurança ou alteração de tabela seja feita de forma manual e sem rastreabilidade.

---

## 🗂️ Estrutura de Subdiretórios

```
database/
├── schema/             # Definição conceitual de tabelas, tipos ENUM e visões SQL
├── migrations/         # Arquivos de migração incremental gerados pelo Supabase CLI
├── seeds/              # Dados demográficos históricos estáticos de pré-carregamento (seeds)
├── rls/                # Políticas de Segurança de Linha (Row Level Security) específicas
└── backups/            # Lógicas de backup, scripts de restauração e dumps sanitizados
```

### 1. `schema/`
*   **Finalidade:** Armazena os scripts DDL (Data Definition Language) puros que definem as estruturas físicas das tabelas (ex: `characters`, `battles`, `civilizations`, `mythologies`), relacionamentos, chaves estrangeiras e índices de busca semântica por similaridade de embeddings (pgvector).

### 2. `migrations/`
*   **Finalidade:** Scripts SQL numerados de migração gerados e controlados pelo Supabase CLI (ex: `202607170001_create_characters_table.sql`). Esses arquivos de migração sequencial garantem a evolução segura da base de dados sem perda de informações.

### 3. `seeds/`
*   **Finalidade:** Scripts e arquivos de inserção de dados iniciais (Data Seeding). Contém dados estruturados das civilizações e linhas do tempo mestre que o aplicativo precisa carregar para que o ambiente de testes e homologação se pareça perfeitamente com a produção.

### 4. `rls/`
*   **Finalidade:** Declaração explícita de regras de segurança baseadas em linha (**Row Level Security - RLS**). O Supabase é acessado diretamente pelo cliente Flutter, logo, as políticas RLS são a barreira de segurança mais importante, garantindo que usuários comuns só editem seus próprios perfis, que convidados só leiam dossiês públicos, e que apenas administradores modifiquem dados históricos mestre.

### 5. `backups/`
*   **Finalidade:** Armazenamento de scripts de automação de backup, rotinas de limpeza, e dumps periódicos de estruturas de dados úteis para desenvolvimento local.

---

## 🎯 Exemplos de Políticas de Segurança (RLS)

Exemplo conceitual de política para controle de leitura pública de dossiês:
```sql
-- Garante que qualquer pessoa (autenticada ou não) possa ler dossiês marcados como públicos
CREATE POLICY "Leitura pública de dossiês"
ON public.dossiers
FOR SELECT
USING (is_public = true);
```

---

## 🛡️ Boas Práticas de Banco de Dados

1. **Migrações são Unidirecionais:** Nunca altere um arquivo de migração antiga já aplicada em produção. Crie sempre uma nova migração incremental para fazer qualquer modificação estrutural em tabelas.
2. **Apenas Políticas RLS Restritas:** Por padrão, toda nova tabela deve ter o Row Level Security ativado (`ALTER TABLE <tabela> ENABLE ROW LEVEL SECURITY;`). Nenhuma permissão de escrita de usuário anônimo deve ser exposta diretamente sem filtragem ou trigger de validação.
3. **Indexação Estratégica:** Crie índices (`INDEX`) para todas as chaves estrangeiras (`FOREIGN KEY`) e campos frequentemente pesquisados ou ordenados (como datas de nascimento, nomes ou anos de batalha), evitando lentidão de leitura em produção.
4. **pgvector para IA:** Lembre-se de habilitar e configurar a extensão `pgvector` nas tabelas que requerem busca por proximidade vetorial para busca semântica baseada em Inteligência Artificial.
