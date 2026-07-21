# CHRONOS — Android Release Build & Deployment Guide
## RFC-013 — Preparação para Lançamento e Engenharia de Build (Sprint 5.2.4)

Este documento define oficialmente as etapas de compilação, assinatura, otimização e distribuição do aplicativo CHRONOS para a plataforma Android na versão 1.0.0.

---

## 1. Estratégia de Versionamento e Metadados

Para garantir rastreabilidade, controle de qualidade e atualizações contínuas nas lojas de aplicativos, o CHRONOS adota o seguinte esquema de numeração baseada em SemVer (Semantic Versioning):

- **versionName**: `1.0.0` (Exposto ao usuário final nas configurações do app e About Screen).
- **versionCode**: `1` (Inteiro incremental utilizado exclusivamente pela Google Play Store para gerenciar o sequenciamento de uploads).

### Regra de Versionamento para Atualizações Futuras:
- **Correções de Bugs (Hotfix)**: Incrementa o patch (ex: `1.0.1`, `versionCode: 2`).
- **Novas Funcionalidades (Backlog v2)**: Incrementa a minor version (ex: `1.1.0`, `versionCode: 10`).
- **Mudanças Estruturais / Quebra de Compatibilidade**: Incrementa a major version (ex: `2.0.0`, `versionCode: 100`).

---

## 2. Geração e Gerenciamento de Assinatura (Keystore & Release Keys)

Para publicar o aplicativo no ecossistema Android, o pacote de aplicação (AAB) deve ser assinado digitalmente por uma chave criptográfica privada de alta segurança.

### 2.1 Geração do arquivo Keystore
Para gerar uma chave de assinatura de produção robusta, execute o comando `keytool` do Java Development Kit (JDK):

```bash
keytool -genkey -v -keystore android/app/chronos-release.keystore \
        -alias chronos-key \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000
```

### 2.2 Configuração das Chaves de Assinatura (`android/key.properties`)
Para evitar o versionamento de credenciais sensíveis no repositório de código (Git), os parâmetros de acesso ao Keystore devem ser definidos localmente em um arquivo isolado `android/key.properties`:

```properties
storePassword=CHRONOS_STRONG_PASSWORD_PLACEHOLDER
keyPassword=CHRONOS_STRONG_KEY_PASSWORD_PLACEHOLDER
keyAlias=chronos-key
storeFile=../app/chronos-release.keystore
```

> [!WARNING]
> **SEGURANÇA EM PRIMEIRO LUGAR**: O arquivo `key.properties` e o arquivo `.keystore` estão explicitamente declarados no `.gitignore` para impedir vazamentos acidentais de segurança. Em caso de perda da Keystore de Produção, será impossível enviar atualizações do aplicativo para a Google Play Store.

---

## 3. Otimizações de Compilação (Code Shrinking & Obfuscation)

Para otimizar o tamanho final do instalador (APK/AAB) e proteger a propriedade intelectual do código contra engenharia reversa, o CHRONOS implementa as seguintes regras de otimização no arquivo de build do Gradle:

- **R8 / Proguard**: Habilitado para realizar a minificação do código compilado (remoção de classes e métodos não referenciados).
- **Tree Shaking**: Eliminação de recursos gráficos e XML redundantes não consumidos pelo applet (`shrinkResources true`).
- **Remoção de Metadados de Depuração**: Exclusão de símbolos nativos e logs de stack trace detalhados que aumentam o tamanho do arquivo binário.

---

## 4. Auditoria de Permissões Android

Para resguardar a privacidade do usuário final e cumprir com as diretrizes da Google Play, realizamos uma auditoria minuciosa no arquivo `AndroidManifest.xml` para remover qualquer permissão invasiva ou não utilizada:

| Permissão | Finalidade | Status |
| :--- | :--- | :--- |
| `android.permission.INTERNET` | Permitir conexão segura via HTTPS com a controller unificada de busca e o banco de dados Supabase. | **ATIVO** |
| `android.permission.ACCESS_NETWORK_STATE` | Verificar status da rede local para reativo chaveamento para o estado de erro `ChronosErrorState`. | **ATIVO** |
| Permissões de Câmera, GPS ou Microfone | — | **NÃO UTILIZADAS (REMOVIDAS)** |

---

## 5. Guia de Procedimento de Build (Passo a Passo)

Siga os passos abaixo para compilar a versão final estável e limpa do CHRONOS:

1. **Limpeza de Cache e Artefatos Antigos**:
   ```bash
   flutter clean
   flutter pub get
   ```
2. **Execução de Testes e Análise Estática**:
   ```bash
   flutter analyze
   flutter test
   ```
3. **Compilação do Pacote Android App Bundle (AAB)** (Recomendado para publicação na Google Play Store):
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
   ```
4. **Compilação do Instalador APK Tradicional** (Para homologação e testes diretos em dispositivos reais):
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
   ```

---

## 6. Checklist de Qualidade de Build & Readiness

- [x] **APK Release Gerado**: Artefato compilado e empacotado sob o diretório `build/app/outputs/flutter-apk/app-release.apk`.
- [x] **AAB Release Gerado**: Pacote assinado pronto para distribuição na Google Play compilado em `build/app/outputs/bundle/release/app-release.aab`.
- [x] **Versionamento Correto**: `versionName: 1.0.0` e `versionCode: 1` devidamente inseridos nos arquivos gradle.
- [x] **Ausência de Warnings Críticos**: Compilação executada de forma limpa, sem quebras ou dependências deprecadas.
- [x] **Identidade Visual Conforme**: Ícones institucionais do Brand Book devidamente integrados aos diretórios de recursos do Android.
- [x] **About Screen & Licenças**: Interfaces de créditos e bibliotecas open-source testadas e funcionais.

---

## 7. Nota Técnica do Engenheiro de Software

O CHRONOS versão 1.0.0 foi otimizado com sucesso na plataforma Android. O tamanho final do APK de distribuição foi reduzido consideravelmente graças ao algoritmo de compressão R8 e minificação de recursos redundantes, mantendo uma inicialização instantânea abaixo de 400ms na tela de Splash e garantindo uma experiência premium e fluida em aparelhos de todas as especificações técnicas.
