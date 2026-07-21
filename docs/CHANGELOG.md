# CHRONOS — Change Log & Documentação de Versões
## Padrão Permanente de Governança de Software (RFC-015)

Este documento estabelece o padrão permanente de governança e histórico de versões do ecossistema CHRONOS, servindo como a fonte única de verdade para a rastreabilidade da evolução do software.

---

## 1. Padrão de Documentação do Projeto

Para garantir uma manutenção saudável e um histórico perfeitamente estruturado, o CHRONOS adota o seguinte ecossistema de documentação contínua:

```
+-------------------------------------------------------------------+
|  1. RFC (Request for Comments)                                    |
|  -> Define exatamente o que SERÁ desenvolvido e as especificações. |
+-------------------------------------------------------------------+
                                 │
                                 ▼
+-------------------------------------------------------------------+
|  2. Release Notes                                                 |
|  -> Registra exatamente o que FOI entregue na respectiva versão.  |
+-------------------------------------------------------------------+
                                 │
                                 ▼
+-------------------------------------------------------------------+
|  3. Known Issues                                                  |
|  -> Registra o que foi conscientemente ADIADO ou catalogado.     |
+-------------------------------------------------------------------+
                                 │
                                 ▼
+-------------------------------------------------------------------+
|  4. Change Log (Este arquivo)                                     |
|  -> Mantém o histórico cronológico unificado de todas as versões.  |
+-------------------------------------------------------------------+
```

---

## 2. Histórico de Versões

### [1.0.0-RC1] — 21-07-2026
#### Adicionado (Added)
- **Branding & Assets Oficiais**: Criação de todo o conjunto de logotipos institucionais, ícones e favicons em formato vetorial SVG (`assets/branding/`).
- **Design Tokens**: Configuração unificada de cores (`#1E3A5F`, `#C9A227`, `#F8F6F0`, `#1F2937`) e tipografias de prestígio (**Cinzel** e **Inter**).
- **About Screen & Licenças**: Interface institucional para exibição de versão, licenças open source e créditos do projeto.
- **Estrutura de Build Android**: Configuração completa dos metadados de loja (Play Store) e script de build release (`flutter build apk` / `flutter build appbundle`).
- **Polimento de Experiência**: Implementação de skeletons dinâmicos (`ChronosSkeleton`) e tratamento de estados vazios/erro (`ChronosEmptyState`, `ChronosErrorState`).

#### Corrigido (Fixed)
- **Ordenação Cronológica**: Correção no ordenamento numérico absoluto de datas B.C. (A.C.) na busca global e na timeline.
- **Debounce de Pesquisa**: Adição de delay de 300ms para evitar requisições paralelas redundantes no servidor.

#### Conscientemente Adiado (Postponed / Backlog v2)
- Módulo Cartográfico Interativo (Mapas históricos).
- Grafo de Relações de Causalidade tridimensional.
- Sincronização e Caching offline avançado.

---

## 3. Diretrizes de Governança e Git Flow para Próximos Passos

Sempre que retornar ao desenvolvimento do CHRONOS:
1. **Abra uma nova RFC** especificando a feature ou correção proposta.
2. **Execute a auditoria** de qualidade, contraste e semântica de interface.
3. **Gerenciamento de Branches (Git Flow)**:
   - **Garantia de Versão**: A branch `release/1.0.0` e a tag `v1.0.0` estão permanentemente congeladas e seladas para proteção.
   - **Hotfixes**: Correções pós-lançamento da versão 1.0.0 devem obrigatoriamente ser desenvolvidas em branches `hotfix/1.0.x`, testadas rigorosamente e integradas de volta.
   - **Features Novas**: Novas funcionalidades devem residir em branches `feature/...` originadas a partir da futura branch `develop` (v1.1 ou superior).
4. **Atualize o Change Log** na seção correspondente mantendo o alinhamento estrito com os padrões semânticos de versionamento.
