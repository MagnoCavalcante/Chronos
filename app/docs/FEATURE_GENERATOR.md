# CHRONOS — Feature Generator

Este documento descreve a arquitetura, utilização, extensibilidade e diretrizes de manutenção do **CHRONOS Feature Generator**, uma ferramenta oficial de engenharia de software interna projetada para acelerar a inicialização de novas frentes de produto, garantindo 100% de conformidade com os padrões arquiteturais congelados do ecossistema.

---

## 1. Fluxo Completo de Execução

O gerador segue uma sequência rígida e previsível para garantir a integridade da arquitetura da aplicação:

1. **Validação de Entrada**: O script principal verifica a presença do nome da feature em formato snake_case como argumento da linha de comando.
2. **Análise de Contexto Semântico (`FeatureContext`)**: O nome fornecido é processado para derivar termos singulares/plurais em formatos Camel, Pascal e Snake case.
3. **Criação da Árvore de Diretórios**: Todas as subpastas da feature (`data`, `domain`, `presentation`, `di`, `routes`, `tests`, etc.) são criadas recursivamente.
4. **Construção de Templates**: Instâncias do `TemplateBuilder` geram o boilerplate do código de cada camada com as substituições semânticas necessárias.
5. **Gravação dos Arquivos**: Os arquivos de código Dart, scripts SQL de migração e sementes (seed), testes automatizados e o README local são escritos em disco.
6. **Injeção de Código Cirúrgica (Surgical Injection)**: 
   - Insere a importação e registra as dependências da nova feature em `lib/core/di/service_locator.dart`.
   - Insere a importação e registra as rotas no mapa central em `lib/core/navigation/app_routes.dart`.
7. **Confirmação Visual**: Exibe o log consolidado com os arquivos gerados e as confirmações de injeção estática.

---

## 2. Estrutura de Diretórios e Arquivos Gerados

Cada execução do gerador produz uma estrutura de pastas e arquivos estritamente acoplada aos princípios de Feature-Driven Development (FDD) e Clean Architecture:

```text
lib/features/<nome_da_feature>/
├── README.md                       # Documentação local da feature e do caso de uso
├── di/
│   └── <nome_da_feature>_di.dart   # Injeção e ServiceLocator local do módulo
├── routes/
│   └── <nome_da_feature>_routes.dart # Catálogo de rotas e mapeamento nominal local
├── domain/
│   ├── entities/
│   │   └── <singular_snake>.dart   # Entidades puras e imutáveis com suporte a cópia e igualdade
│   ├── repositories/
│   │   └── <singular_snake>_repository.dart # Interface abstrata do contrato comercial
│   └── usecases/
│       └── get_<nome_da_feature>_usecase.dart # Casos de uso de responsabilidade única
├── data/
│   ├── datasources/
│   │   └── <singular_snake>_remote_datasource.dart # Contrato de infraestrutura externa
│   ├── models/
│   │   └── <singular_snake>_model.dart # Serialização JSON e mapeamento de dados
│   ├── repositories/
│   │   └── <singular_snake>_repository_impl.dart # Implementação concreta com tratamento de Result<T>
│   ├── migrations/
│   │   └── migration.sql           # Template DDL SQL para criação de tabela
│   └── seeds/
│       └── seed.sql                # Template DML SQL para alimentação da tabela
├── presentation/
│   ├── controllers/
│   │   └── <nome_da_feature>_controller.dart # Gerenciamento de estado reativo e log
│   ├── screens/
│   │   └── <nome_da_feature>_screen.dart # Interface em conformidade com Material 3
│   └── widgets/
│       ├── <singular_snake>_card.dart # Exibição individual do registro
│       ├── <nome_da_feature>_loading.dart # Componente visual de esqueleto de carregamento
│       ├── <nome_da_feature>_error.dart # Componente visual para tratamento amigável de falhas
│       └── <nome_da_feature>_empty.dart # Componente visual para estado sem dados
└── tests/
    ├── <singular_snake>_entity_test.dart # Testes de cópia, imutabilidade e igualdade
    ├── <singular_snake>_model_test.dart # Testes de serialização e desserialização JSON
    ├── <singular_snake>_repository_test.dart # Testes de comportamento do repositório sob Result<T>
    └── <nome_da_feature>_controller_test.dart # Testes de comportamento do controle reativo
```

---

## 3. Como Utilizar e Regenerar

Para inicializar ou atualizar uma feature existente, execute o comando de execução na raiz do diretório `app`:

```bash
# Executar a partir de `/app/applet/app`
dart run tool/generate_feature.dart <nome_da_feature>
```

### Exemplos:
```bash
dart run tool/generate_feature.dart historical_characters
```

### Instruções de Regeneração:
- **Sobrescrita Segura**: O gerador foi projetado de forma idempotente para arquivos de template de código; se você modificar os templates base e executar o gerador novamente, ele irá reescrever os arquivos sob a feature.
- **Detecção de Duplicados**: Para as injeções estáticas em `service_locator.dart` e `app_routes.dart`, o gerador faz uma verificação estática. Se a chamada de registro (ex: `HistoricalCharactersDI.register();`) ou o spread de rotas (ex: `...HistoricalCharactersRoutes.routes`) já estiverem presentes nos arquivos centrais, o gerador os ignora, evitando duplicidade e mantendo a formatação intacta.
- **Limpeza de Recursos**: Se uma feature precisa ser descontinuada ou completamente redefinida de forma limpa, remova a pasta física da feature sob `lib/features/` e as chamadas correspondentes inseridas nos arquivos centrais antes de executar a nova geração.

---

## 4. Como Adicionar e Modificar Templates (Manutenção)

O gerador segue rigorosamente o princípio Aberto/Fechado (OCP). Para estender os templates ou criar novas camadas:

1. **Criar um Builder dedicado**: Adicione um arquivo sob `tool/src/template_builders/` estendendo a interface `TemplateBuilder`.
   
   *Exemplo (`tool/src/template_builders/my_custom_builder.dart`)*:
   ```dart
   import '../feature_context.dart';
   import 'template_builder.dart';

   class MyCustomBuilder implements TemplateBuilder {
     @override
     String build(FeatureContext context) {
       return '''// Template customizado para ${context.singularPascal}
// Criado em conformidade com o ecossistema CHRONOS.
''';
     }
   }
   ```

2. **Expor o Builder**: Registre a exportação do novo arquivo no agregador de exportações `tool/src/template_builders/builders.dart`.

3. **Adicionar ao Sequenciador**: Adicione a gravação do arquivo correspondente dentro do método principal `main` em `/app/tool/generate_feature.dart`:
   ```dart
   _writeFile(
     '$basePath/custom_layer/${context.singularSnake}_custom.dart',
     MyCustomBuilder().build(context),
   );
   ```

---

## 5. Diretrizes Rigorosas de Desenvolvimento

- **Sintaxe Result<T>**: Todos os métodos expostos na camada de domínio e repositórios devem sempre retornar a estrutura funcional unificada `Result<T>`. O uso de lançamentos de exceção diretos para fora de repositórios ou contratos de interface é estritamente proibido.
- **ChronosLogger**: Os controladores e serviços reativos de apresentação devem encapsular seus registros utilizando a chamada estática `ChronosLogger.info` and `ChronosLogger.error`, garantindo rastreabilidade estruturada.
- **Imports Absolutos vs. Relativos**: Em todos os templates, use imports absolutos (`package:chronos/...`) para se referir ao núcleo comum (`core`, `shared`, etc.). Use imports relativos apenas para dependências que estão no mesmo escopo local da feature (dentro de `lib/features/<nome_da_feature>/`).
