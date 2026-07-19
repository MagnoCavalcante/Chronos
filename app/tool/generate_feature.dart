import 'dart:io';
import 'src/feature_context.dart';
import 'src/template_builders/builders.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Erro: Nome da feature não fornecido.');
    print('Utilização: dart run tool/generate_feature.dart <feature_name>');
    exit(1);
  }

  final featureName = args[0];
  final context = FeatureContext(featureName);

  print('==================================================');
  print('Iniciando CHRONOS Feature Generator para: ${context.featurePascal}');
  print('==================================================');

  final basePath = 'lib/features/$featureName';

  // Garantir a criação dos diretórios
  _createDir('$basePath/data/datasources');
  _createDir('$basePath/data/models');
  _createDir('$basePath/data/repositories');
  _createDir('$basePath/domain/entities');
  _createDir('$basePath/domain/repositories');
  _createDir('$basePath/domain/usecases');
  _createDir('$basePath/presentation/controllers');
  _createDir('$basePath/presentation/screens');
  _createDir('$basePath/presentation/widgets');
  _createDir('$basePath/di');
  _createDir('$basePath/routes');
  _createDir('$basePath/tests');
  _createDir('$basePath/data/migrations');
  _createDir('$basePath/data/seeds');

  // 1. Entity
  _writeFile(
    '$basePath/domain/entities/${context.singularSnake}.dart',
    EntityTemplateBuilder().build(context),
  );

  // 2. Model
  _writeFile(
    '$basePath/data/models/${context.singularSnake}_model.dart',
    ModelTemplateBuilder().build(context),
  );

  // 3. RemoteDataSource
  _writeFile(
    '$basePath/data/datasources/${context.singularSnake}_remote_datasource.dart',
    DataSourceTemplateBuilder().build(context),
  );

  // 4. Repository Interface & Implementation
  final repoBuilder = RepositoryTemplateBuilder();
  _writeFile(
    '$basePath/domain/repositories/${context.singularSnake}_repository.dart',
    repoBuilder.buildInterface(context),
  );
  _writeFile(
    '$basePath/data/repositories/${context.singularSnake}_repository_impl.dart',
    repoBuilder.buildImplementation(context),
  );

  // 5. UseCase
  _writeFile(
    '$basePath/domain/usecases/get_${featureName}_usecase.dart',
    UseCaseTemplateBuilder().build(context),
  );

  // 6. Controller
  _writeFile(
    '$basePath/presentation/controllers/${featureName}_controller.dart',
    ControllerTemplateBuilder().build(context),
  );

  // 7. Screen
  _writeFile(
    '$basePath/presentation/screens/${featureName}_screen.dart',
    ScreenTemplateBuilder().build(context),
  );

  // 8. Widgets
  final widgetBuilder = WidgetTemplateBuilder();
  _writeFile(
    '$basePath/presentation/widgets/${context.singularSnake}_card.dart',
    widgetBuilder.buildCard(context),
  );
  _writeFile(
    '$basePath/presentation/widgets/${context.singularSnake}_loading.dart',
    widgetBuilder.buildLoading(context),
  );
  _writeFile(
    '$basePath/presentation/widgets/${context.singularSnake}_error.dart',
    widgetBuilder.buildError(context),
  );
  _writeFile(
    '$basePath/presentation/widgets/${context.singularSnake}_empty.dart',
    widgetBuilder.buildEmpty(context),
  );

  // 9. DI
  _writeFile(
    '$basePath/di/${featureName}_di.dart',
    _buildDIFile(context),
  );

  // 10. Routes
  _writeFile(
    '$basePath/routes/${featureName}_routes.dart',
    _buildRoutesFile(context),
  );

  // 11. README
  _writeFile(
    '$basePath/README.md',
    ReadmeTemplateBuilder().build(context),
  );

  // 12. Migration & Seed
  _writeFile(
    '$basePath/data/migrations/migration.sql',
    MigrationTemplateBuilder().build(context),
  );
  _writeFile(
    '$basePath/data/seeds/seed.sql',
    SeedTemplateBuilder().build(context),
  );

  // 13. Unit Tests
  _writeFile(
    '$basePath/tests/${context.singularSnake}_entity_test.dart',
    _buildEntityTest(context),
  );
  _writeFile(
    '$basePath/tests/${context.singularSnake}_model_test.dart',
    _buildModelTest(context),
  );
  _writeFile(
    '$basePath/tests/${context.singularSnake}_repository_test.dart',
    _buildRepositoryTest(context),
  );
  _writeFile(
    '$basePath/tests/${featureName}_controller_test.dart',
    _buildControllerTest(context),
  );

  // 14. Append registrations to ServiceLocator
  _registerInServiceLocator(context);

  // 15. Append registrations to AppRoutes
  _registerInAppRoutes(context);

  print('==================================================');
  print('✔ Feature ${context.featurePascal} gerada com sucesso!');
  print('==================================================');
}

void _createDir(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

void _writeFile(String path, String content) {
  final file = File(path);
  file.writeAsStringSync(content);
  print('  Criado: $path');
}

String _buildDIFile(FeatureContext context) {
  return '''import 'package:chronos/core/di/service_locator.dart';
import '../data/datasources/${context.singularSnake}_remote_datasource.dart';
import '../data/repositories/${context.singularSnake}_repository_impl.dart';
import '../domain/repositories/${context.singularSnake}_repository.dart';
import '../domain/usecases/get_${context.featureName}_usecase.dart';
import '../presentation/controllers/${context.featureName}_controller.dart';

/// Inicializador de Dependências local para a feature de ${context.featurePascal}.
class ${context.featurePascal}DI {
  ${context.featurePascal}DI._();

  /// Registra todas as dependências da feature no ServiceLocator central.
  static void register() {
    final sl = ServiceLocator.instance;

    // 1. Data Source
    sl.registerLazySingleton<${context.singularPascal}RemoteDataSource>(
      () => ${context.singularPascal}RemoteDataSourceImpl(),
    );

    // 2. Repository
    sl.registerLazySingleton<${context.singularPascal}Repository>(
      () => ${context.singularPascal}RepositoryImpl(
        remoteDataSource: sl.get<${context.singularPascal}RemoteDataSource>(),
      ),
    );

    // 3. Use Case
    sl.registerLazySingleton<Get${context.featurePascal}UseCase>(
      () => Get${context.featurePascal}UseCase(
        repository: sl.get<${context.singularPascal}Repository>(),
      ),
    );

    // 4. Controller
    sl.registerFactory<${context.featurePascal}Controller>(
      () => ${context.featurePascal}Controller(
        useCase: sl.get<Get${context.featurePascal}UseCase>(),
      ),
    );
  }
}
''';
}

String _buildRoutesFile(FeatureContext context) {
  return '''import 'package:flutter/material.dart';
import '../presentation/screens/${context.featureName}_screen.dart';

class ${context.featurePascal}Routes {
  ${context.featurePascal}Routes._();

  static const String root = '/${context.featureName}';

  static Map<String, WidgetBuilder> get routes => {
        root: (context) => const ${context.featurePascal}Screen(),
      };
}
''';
}

String _buildEntityTest(FeatureContext context) {
  return '''import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../domain/entities/${context.singularSnake}.dart';

void main() {
  group('${context.singularPascal} Entity Tests', () {
    final now = DateTime.now();

    test('should support copyWith', () {
      final entity = ${context.singularPascal}(
        id: '1',
        slug: 'slug',
        nome: 'Nome',
        descricao: 'Descricao',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = entity.copyWith(nome: 'Novo Nome');

      expect(updated.nome, 'Novo Nome');
      expect(updated.id, '1');
    });

    test('should support value equality', () {
      final entity1 = ${context.singularPascal}(
        id: '1',
        slug: 'slug',
        nome: 'Nome',
        descricao: 'Descricao',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final entity2 = ${context.singularPascal}(
        id: '1',
        slug: 'slug',
        nome: 'Nome',
        descricao: 'Descricao',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(entity1, equals(entity2));
    });
  });
}
''';
}

String _buildModelTest(FeatureContext context) {
  return '''import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/${context.singularSnake}_model.dart';
import '../domain/entities/${context.singularSnake}.dart';

void main() {
  group('${context.singularPascal}Model Tests', () {
    final now = DateTime.now();

    final jsonSample = {
      'id': '123',
      'slug': 'test-slug',
      'nome': 'Test Name',
      'descricao': 'Test Description',
      'publication_status': 'published',
      'ativo': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('should create model from json', () {
      final model = ${context.singularPascal}Model.fromJson(jsonSample);

      expect(model.id, '123');
      expect(model.nome, 'Test Name');
      expect(model.publicationStatus, PublicationStatus.published);
    });

    test('should convert model to json', () {
      final model = ${context.singularPascal}Model(
        id: '123',
        slug: 'test-slug',
        nome: 'Test Name',
        descricao: 'Test Description',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['nome'], 'Test Name');
    });

    test('should support conversion from entity', () {
      final entity = ${context.singularPascal}(
        id: '123',
        slug: 'test-slug',
        nome: 'Test Name',
        descricao: 'Test Description',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final model = ${context.singularPascal}Model.fromEntity(entity);

      expect(model.id, '123');
      expect(model.nome, 'Test Name');
    });
  });
}
''';
}

String _buildRepositoryTest(FeatureContext context) {
  return '''import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/${context.singularSnake}_model.dart';
import '../data/repositories/${context.singularSnake}_repository_impl.dart';
import '../data/datasources/${context.singularSnake}_remote_datasource.dart';

class Fake${context.singularPascal}RemoteDataSource implements ${context.singularPascal}RemoteDataSource {
  final List<${context.singularPascal}Model> items;
  final bool shouldThrow;

  Fake${context.singularPascal}RemoteDataSource({required this.items, this.shouldThrow = false});

  @override
  Future<List<${context.singularPascal}Model>> getAll${context.featurePascal}() async {
    if (shouldThrow) {
      throw const ${context.singularPascal}DataSourceException(
        message: 'Database error',
        type: ${context.singularPascal}DataSourceErrorType.database,
      );
    }
    return items;
  }
}

void main() {
  group('${context.singularPascal}RepositoryImpl Tests', () {
    final now = DateTime.now();
    final modelSample = ${context.singularPascal}Model(
      id: '1',
      slug: 'slug',
      nome: 'Nome',
      descricao: 'Desc',
      publicationStatus: PublicationStatus.published,
      ativo: true,
      createdAt: now,
      updatedAt: now,
    );

    test('should return success result on valid data source load', () async {
      final fakeDataSource = Fake${context.singularPascal}RemoteDataSource(items: [modelSample]);
      final repo = ${context.singularPascal}RepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAll${context.featurePascal}();

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 1);
    });

    test('should return failure result on data source exception', () async {
      final fakeDataSource = Fake${context.singularPascal}RemoteDataSource(items: [], shouldThrow: true);
      final repo = ${context.singularPascal}RepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAll${context.featurePascal}();

      expect(result.isFailure, true);
      expect(result.failureOrNull?.message, 'Database error');
    });
  });
}
''';
}

String _buildControllerTest(FeatureContext context) {
  return '''import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../presentation/controllers/${context.featureName}_controller.dart';
import '../domain/entities/${context.singularSnake}.dart';
import '../domain/usecases/get_${context.featureName}_usecase.dart';
import '../domain/repositories/${context.singularSnake}_repository.dart';

class Fake${context.singularPascal}Repository implements ${context.singularPascal}Repository {
  final Result<List<${context.singularPascal}>> result;

  Fake${context.singularPascal}Repository(this.result);

  @override
  Future<Result<List<${context.singularPascal}>>> getAll${context.featurePascal}() async {
    return result;
  }
}

void main() {
  group('${context.featurePascal}Controller Tests', () {
    final now = DateTime.now();
    final entitySample = ${context.singularPascal}(
      id: '1',
      slug: 'slug',
      nome: 'Nome',
      descricao: 'Desc',
      publicationStatus: PublicationStatus.published,
      ativo: true,
      createdAt: now,
      updatedAt: now,
    );

    test('should load items successfully', () async {
      final fakeRepo = Fake${context.singularPascal}Repository(Result.success([entitySample]));
      final useCase = Get${context.featurePascal}UseCase(repository: fakeRepo);
      final controller = ${context.featurePascal}Controller(useCase: useCase);

      await controller.load${context.featurePascal}();

      expect(controller.isLoading, false);
      expect(controller.items.length, 1);
      expect(controller.hasError, false);
    });

    test('should handle failures correctly', () async {
      final fakeRepo = Fake${context.singularPascal}Repository(
        const Result.failure(DatabaseFailure('Error loading data')),
      );
      final useCase = Get${context.featurePascal}UseCase(repository: fakeRepo);
      final controller = ${context.featurePascal}Controller(useCase: useCase);

      await controller.load${context.featurePascal}();

      expect(controller.isLoading, false);
      expect(controller.hasError, true);
      expect(controller.failure?.message, 'Error loading data');
    });
  });
}
''';
}

void _registerInServiceLocator(FeatureContext context) {
  final file = File('lib/core/di/service_locator.dart');
  if (!file.existsSync()) {
    print('Aviso: lib/core/di/service_locator.dart não localizado.');
    return;
  }

  String content = file.readAsStringSync();
  final registerCall = '${context.featurePascal}DI.register();';

  if (content.contains(registerCall)) {
    print('Dependências de ${context.featurePascal} já registradas no ServiceLocator.');
    return;
  }

  // 1. Inserir import no topo
  final importLine = "import '../../features/${context.featureName}/di/${context.featureName}_di.dart';\n";
  content = importLine + content;

  // 2. Inserir a chamada de registro no final do setupServiceLocator
  final lastBraceIndex = content.lastIndexOf('}');
  if (lastBraceIndex != -1) {
    content = content.substring(0, lastBraceIndex) +
        '  $registerCall\n' +
        content.substring(lastBraceIndex);
  }

  file.writeAsStringSync(content);
  print('✔ Dependências de ${context.featurePascal} registradas no ServiceLocator.');
}

void _registerInAppRoutes(FeatureContext context) {
  final file = File('lib/core/navigation/app_router.dart');
  if (!file.existsSync()) {
    print('Aviso: lib/core/navigation/app_router.dart não localizado.');
    return;
  }

  String content = file.readAsStringSync();
  final spreadCall = '...${context.featurePascal}Routes.routes,';

  if (content.contains(spreadCall)) {
    print('Rotas de ${context.featurePascal} já registradas no AppRouter.');
    return;
  }

  // 1. Inserir import no topo
  final importLine = "import '../../features/${context.featureName}/routes/${context.featureName}_routes.dart';\n";
  content = importLine + content;

  // 2. Inserir o spread operator dentro do mapa de rotas
  final target = 'RouteNames.historicalCharacters: (context) => const HistoricalCharactersScreen(),';
  if (content.contains(target)) {
    content = content.replaceFirst(target, '$target\n        $spreadCall');
  } else {
    final mapIndex = content.indexOf('routes => {');
    if (mapIndex != -1) {
      final insertIndex = content.indexOf('{', mapIndex) + 1;
      content = content.substring(0, insertIndex) +
          '\n        $spreadCall' +
          content.substring(insertIndex);
    }
  }

  file.writeAsStringSync(content);
  print('✔ Rotas de ${context.featurePascal} registradas no AppRouter.');
}
