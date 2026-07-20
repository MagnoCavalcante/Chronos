# CHRONOS Core Foundation Documentation
## Version 2.0.0 (Sprint 4.2.0)

This document provides detailed technical documentation for the core/base infrastructure introduced in CHRONOS v2.0.0. The core foundation eliminates code duplication and consolidates architectural patterns across all features.

---

## Overview

The core foundation consists of six base classes located in `app/lib/core/base/` that provide standardized implementations for common architectural patterns:

1. **BaseEntity** - Centralizes common entity attributes
2. **BaseModel<T>** - Standardizes data model serialization
3. **BaseRepository<T>** - Defines common repository operations
4. **BaseRemoteDatasource<T>** - Centralizes error handling and logging for remote data sources
5. **BaseUseCase<Output, Input>** - Standardizes use case execution with logging
6. **BaseController** - Provides reactive state management

---

## 1. BaseEntity

**Location**: `app/lib/core/base/base_entity.dart`

### Purpose
Centralizes common attributes shared by all domain entities, eliminating duplication and ensuring consistency across the codebase.

### Attributes
- `id` (String): Unique identifier for the entity
- `active` (bool): Activation status flag
- `createdAt` (DateTime): Timestamp of entity creation
- `updatedAt` (DateTime): Timestamp of last entity update

### Features
- **Immutability**: All attributes are `final` and constructor is `const`
- **Value Equality**: Provides `operator ==` and `hashCode` based on `id` only
- **CopyWith**: Abstract method for creating modified copies (subclasses must implement)

### Usage Example
```dart
class Era extends BaseEntity {
  final String nome;
  final String descricao;

  const Era({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.nome,
    required this.descricao,
  });

  @override
  Era copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nome,
    String? descricao,
  }) {
    return Era(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
    );
  }
}
```

### Benefits
- Eliminates ~20 lines of duplicate code per entity
- Guarantees consistent attribute naming and types
- Provides built-in value equality without manual implementation
- Ensures all entities have essential audit fields

---

## 2. BaseModel<T>

**Location**: `app/lib/core/base/base_model.dart`

### Purpose
Defines the standard contract for data models, ensuring consistent serialization and entity conversion across all features.

### Methods
- `Map<String, dynamic> toJson()`: Converts model to JSON representation
- `factory BaseModel.fromJson(Map<String, dynamic> json)`: Reconstructs model from JSON
- `T toEntity()`: Converts model to domain entity
- `factory BaseModel.fromEntity(T entity)`: Converts domain entity to model

### Features
- **Type Safety**: Generic type parameter ensures correct entity type
- **No Reflection**: Requires explicit implementation (no runtime reflection)
- **Bidirectional Conversion**: Supports both JSON↔Model and Model↔Entity conversions

### Usage Example
```dart
class EraModel extends Era implements BaseModel<Era> {
  @override
  factory EraModel.fromJson(Map<String, dynamic> json) {
    return EraModel(
      id: json['id'] as String,
      active: json['ativo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ativo': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nome': nome,
      'descricao': descricao,
    };
  }

  @override
  Era toEntity() {
    return Era(
      id: id,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nome: nome,
      descricao: descricao,
    );
  }

  @override
  factory EraModel.fromEntity(Era entity) {
    if (entity is EraModel) return entity;
    return EraModel(
      id: entity.id,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nome: entity.nome,
      descricao: entity.descricao,
    );
  }
}
```

### Benefits
- Eliminates ~30-40 lines of duplicate serialization code per model
- Guarantees consistent JSON field naming and type handling
- Enforces bidirectional conversion pattern
- Prevents runtime errors through compile-time type checking

---

## 3. BaseRepository<T>

**Location**: `app/lib/core/base/base_repository.dart`

### Purpose
Defines standard CRUD operations for repositories, ensuring consistent data access patterns across all features.

### Methods
- `Future<Result<List<T>>> getAll()`: Retrieve all entities
- `Future<Result<T>> getById(String id)`: Retrieve single entity by ID
- `Future<Result<void>> delete(String id)`: Delete entity by ID
- `Future<Result<T>> save(T entity)`: Save new entity
- `Future<Result<T>> update(T entity)`: Update existing entity

### Features
- **Result Pattern**: All operations return `Result<T>` for error handling
- **Generic Type**: Works with any entity type
- **Abstract**: Interface only - implementations provided by feature-specific repositories

### Usage Example
```dart
abstract class EraRepository extends BaseRepository<Era> {
  Future<Result<List<Era>>> getAllEras();
  // CRUD methods inherited from BaseRepository<Era>
}

class EraRepositoryImpl implements EraRepository {
  final EraRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Era>>> getAllEras() async {
    try {
      final models = await _remoteDataSource.getAllEras();
      final entities = models.map((m) => m.toEntity()).toList();
      return Result.success(List.unmodifiable(entities));
    } on ServerException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<Era>> getById(String id) {
    throw UnimplementedError('getById não implementado para EraRepository');
  }

  @override
  Future<Result<void>> delete(String id) {
    throw UnimplementedError('delete não implementado para EraRepository');
  }

  @override
  Future<Result<Era>> save(Era entity) {
    throw UnimplementedError('save não implementado para EraRepository');
  }

  @override
  Future<Result<Era>> update(Era entity) {
    throw UnimplementedError('update não implementado para EraRepository');
  }
}
```

### Benefits
- Eliminates ~15-20 lines of duplicate repository interface code
- Standardizes CRUD operation signatures
- Guarantees consistent error handling pattern
- Allows features to implement only needed operations

---

## 4. BaseRemoteDatasource<T>

**Location**: `app/lib/core/base/base_remote_datasource.dart`

### Purpose
Centralizes error handling, logging, and Supabase client management for remote data sources, eliminating duplicate error handling code.

### Features
- **Centralized Error Handling**: Automatic detection and mapping of network, authentication, and database errors
- **Unified Logging**: Consistent logging across all data sources using ChronosLogger
- **Supabase Client Management**: Optional client injection for testing
- **Empty Response Detection**: Automatic validation of query results

### Methods
- `fetchData()`: Abstract method for data fetching (implemented by subclasses)
- `executeWithErrorHandling()`: Executes fetchData with automatic error handling and logging
- `throwIfEmpty()`: Validates response and throws ServerException if empty
- `mapPostgrestException()`: Maps Supabase exceptions to ServerException
- `mapGenericException()`: Maps generic exceptions to ServerException

### Usage Example
```dart
class EraRemoteDataSourceImpl extends BaseRemoteDatasource<EraModel>
    implements EraRemoteDataSource {
  EraRemoteDataSourceImpl({SupabaseClient? client})
      : super(
          client: client ?? SupabaseConfig.client,
          tag: 'EraRemoteDataSource',
        );

  @override
  Future<List<EraModel>> fetchData() async {
    final response = await client
        .from('eras')
        .select()
        .eq('ativo', true)
        .eq('publication_status', PublicationStatus.published.value)
        .order('ordem_cronologica', ascending: true);

    throwIfEmpty(response, 'Era');

    return response
        .map((item) => EraModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EraModel>> getAllEras() async {
    return executeWithErrorHandling();
  }
}
```

### Benefits
- Eliminates ~50-80 lines of duplicate error handling code per datasource
- Guarantees consistent error mapping and logging
- Reduces bug surface area by centralizing error logic
- Simplifies datasource implementations to focus on data fetching only

### Error Types Handled
- **Network Errors**: SocketException, connection failures, XMLHTTP errors
- **Authentication Errors**: Supabase RLS violations (42501, PGRST301)
- **Database Errors**: PostgrestException with database-specific codes
- **Empty Response**: Queries returning no results when data expected
- **Unknown Errors**: Catch-all for unexpected exceptions

---

## 5. BaseUseCase<Output, Input>

**Location**: `app/lib/core/base/base_usecase.dart`

### Purpose
Standardizes use case execution with centralized logging and error handling, eliminating duplicate boilerplate in business logic layer.

### Methods
- `call(Input input)`: Public method that wraps execute() with logging and error handling
- `execute(Input input)`: Abstract method implemented by subclasses with actual business logic

### Features
- **Automatic Logging**: Logs use case start, success, and failure
- **Error Handling**: Wraps exceptions in Result.failure()
- **Generic Types**: Supports any input/output types
- **Callable Class**: Can be invoked directly using `useCase()`

### Usage Example
```dart
class GetAllErasUseCase extends BaseUseCase<List<Era>, void> {
  final EraRepository repository;

  GetAllErasUseCase(this.repository);

  @override
  Future<Result<List<Era>>> execute(void input) async {
    return await repository.getAllEras();
  }
}

// Usage
final useCase = GetAllErasUseCase(repository);
final result = await useCase(); // Automatic logging and error handling
```

### Benefits
- Eliminates ~10-15 lines of duplicate logging/error handling per use case
- Guarantees consistent logging across all business logic
- Simplifies use case implementation to focus on business logic only
- Provides automatic error wrapping in Result pattern

---

## 6. BaseController

**Location**: `app/lib/core/base/base_controller.dart` (re-export from `core/presentation/base_controller.dart`)

### Purpose
Provides reactive state management with standardized async operation execution, concurrency protection, and logging.

### Features
- **Reactive State**: Uses ChangeNotifier for UI reactivity
- **ViewStatus Enum**: Tracks operation states (initial, loading, success, failure)
- **ViewState Enum**: Tracks data states (initial, data, error, empty)
- **Async Execution**: `execute()` method with automatic state management
- **Concurrency Protection**: Prevents duplicate simultaneous operations
- **Automatic Logging**: Logs state transitions and operation results

### Methods
- `execute()`: Executes async operation with automatic state management
- `retry()`: Retries the last failed operation
- `refresh()`: Refreshes the current data
- `status`: Current ViewStatus of the controller

### Usage Example
```dart
class ErasController extends BaseController<List<Era>> {
  final GetAllErasUseCase getAllErasUseCase;

  ErasController(this.getAllErasUseCase);

  Future<void> loadEras() async {
    final result = await execute(() => getAllErasUseCase());
    result.fold(
      (eras) => updateState(ViewState.data(eras)),
      (failure) => updateState(ViewState.error(failure.message)),
    );
  }
}
```

### Benefits
- Eliminates ~30-40 lines of duplicate state management code per controller
- Guarantees consistent state transitions and logging
- Prevents common bugs like duplicate simultaneous requests
- Simplifies controller implementation to focus on business logic

---

## Migration Guide

### For Existing Features

To migrate an existing feature to use the core foundation:

1. **Entity**: Add `extends BaseEntity` and remove duplicate attributes
2. **Model**: Add `implements BaseModel<T>` and ensure all methods are implemented
3. **Repository Interface**: Add `extends BaseRepository<T>` and remove duplicate method signatures
4. **Remote DataSource**: Add `extends BaseRemoteDatasource<T>` and implement `fetchData()`
5. **Use Case**: Add `extends BaseUseCase<Output, Input>` and implement `execute()`
6. **Controller**: Ensure it extends `BaseController` (already done in most cases)

### For New Features

All new features MUST use the core foundation from the start:

1. Create entity extending `BaseEntity`
2. Create model implementing `BaseModel<T>`
3. Create repository interface extending `BaseRepository<T>`
4. Create remote datasource extending `BaseRemoteDatasource<T>` (if applicable)
5. Create use case extending `BaseUseCase<Output, Input>`
6. Create controller extending `BaseController`

---

## Best Practices

### DO
- Always extend/implement the appropriate base class
- Use `super` parameters for base class attributes
- Implement `copyWith` to call super.copyWith first
- Use the provided logging in base classes instead of custom logging
- Leverage automatic error handling in base classes

### DON'T
- Duplicate attributes that exist in `BaseEntity`
- Implement custom error handling when `BaseRemoteDatasource` can handle it
- Skip implementing required methods from base interfaces
- Use reflection in models (BaseModel requires explicit implementation)
- Override base class methods unless absolutely necessary

---

## Testing Considerations

### Unit Testing Base Classes
The base classes are designed to be testable:

- **BaseEntity**: Test equality and copyWith behavior
- **BaseModel<T>**: Test serialization and entity conversion
- **BaseRepository<T>**: Test interface compliance
- **BaseRemoteDatasource<T>**: Test error mapping and logging
- **BaseUseCase<Output, Input>**: Test logging and error wrapping
- **BaseController**: Test state transitions and concurrency protection

### Mocking
When testing feature-specific implementations:

- Mock repository interfaces (not implementations)
- Inject mock SupabaseClient into datasources
- Use dependency injection for all base class dependencies

---

## Performance Considerations

The core foundation is designed for minimal performance impact:

- **No Reflection**: All serialization is explicit (no runtime reflection overhead)
- **Value Equality**: BaseEntity uses simple ID comparison (O(1))
- **Lazy Initialization**: Base classes don't allocate resources until needed
- **Minimal Overhead**: Base methods add negligible execution time

---

## Future Enhancements

Potential future additions to the core foundation:

- **BaseLocalDatasource<T>**: For local storage (SQLite, SharedPreferences)
- **BasePaginatedUseCase**: For paginated data fetching
- **BaseCachableRepository**: For repository caching strategies
- **BaseValidator**: For common validation patterns

---

## Conclusion

The core foundation provides a solid, consistent base for all CHRONOS features, eliminating duplication, reducing bugs, and accelerating development. By standardizing architectural patterns, it ensures code quality and maintainability across the entire codebase.
