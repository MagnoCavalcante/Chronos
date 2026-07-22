import 'package:supabase_flutter/supabase_flutter.dart';
import '../base/base_repository.dart';
import '../config/supabase_config.dart';
import '../errors/failure.dart';
import '../utils/logger.dart';
import '../utils/result.dart';

/// Repositório genérico para operações CRUD diretas em uma tabela Supabase.
///
/// Trabalha com mapas JSON, permitindo que qualquer módulo do CHRONOS
/// obtenha criação, leitura, atualização e exclusão sem depender de
/// entidades tipadas específicas.
class CrudRepository extends BaseRepository {
  final String tableName;
  final String orderBy;
  final String? filterColumn;
  final dynamic filterValue;

  CrudRepository({
    required this.tableName,
    this.orderBy = 'name',
    this.filterColumn,
    this.filterValue,
  });

  PostgrestQueryBuilder get _table => SupabaseConfig.client.from(tableName);

  Future<Result<List<Map<String, dynamic>>>> getAll() async {
    return safeCall<List<Map<String, dynamic>>>(
      () async {
        var query = _table.select();
        if (filterColumn != null && filterValue != null) {
          query = query.eq(filterColumn!, filterValue);
        }
        final response = await query.order(orderBy, ascending: true);
        return response;
      },
      onError: (e, s) => _mapError(e),
    );
  }

  Future<Result<List<Map<String, dynamic>>>> getRecent(int limit, {String orderBy = 'created_at'}) async {
    return safeCall<List<Map<String, dynamic>>>(
      () async {
        final response = await _table.select().order(orderBy, ascending: false).limit(limit);
        return response;
      },
      onError: (e, s) => _mapError(e),
    );
  }

  Future<Result<Map<String, dynamic>>> getById(String id) async {
    return safeCall<Map<String, dynamic>>(
      () async {
        final response = await _table.select().eq('id', id).limit(1);
        if (response.isEmpty) {
          throw Exception('Registro não encontrado.');
        }
        return response.first;
      },
      onError: (e, s) => _mapError(e),
    );
  }

  Future<Result<Map<String, dynamic>>> create(Map<String, dynamic> data) async {
    return safeCall<Map<String, dynamic>>(
      () async {
        final payload = Map<String, dynamic>.from(data);
        payload.remove('id');
        payload.removeWhere((key, value) => value == null);
        final response = await _table.insert(payload).select().single();
        return response;
      },
      onError: (e, s) => _mapError(e),
    );
  }

  Future<Result<Map<String, dynamic>>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    return safeCall<Map<String, dynamic>>(
      () async {
        final payload = Map<String, dynamic>.from(data);
        payload.remove('id');
        payload.remove('created_at');
        payload.removeWhere((key, value) => value == null);
        final response = await _table.update(payload).eq('id', id).select().single();
        return response;
      },
      onError: (e, s) => _mapError(e),
    );
  }

  Future<Result<void>> delete(String id) async {
    return safeCall<void>(
      () async {
        await _table.delete().eq('id', id);
      },
      onError: (e, s) => _mapError(e),
    );
  }

  Failure _mapError(Object error) {
    ChronosLogger.error(
      'Erro no CRUD [$tableName]: $error',
      tag: 'CrudRepository',
      error: error,
    );
    if (error is PostgrestException) {
      return DatabaseFailure(
        'Erro no banco de dados [$tableName]: ${error.message}',
        originalError: error,
      );
    }
    final message = error.toString().toLowerCase();
    if (message.contains('socket') || message.contains('network')) {
      return NetworkFailure(
        'Falha de conectividade ao acessar $tableName.',
        originalError: error,
      );
    }
    return UnknownFailure(
      'Erro inesperado [$tableName]: $error',
      originalError: error,
    );
  }
}
