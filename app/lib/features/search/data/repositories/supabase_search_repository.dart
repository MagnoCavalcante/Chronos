import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/search_result_model.dart';

class SupabaseSearchRepository implements SearchRepository {
  final SearchRemoteDataSource _dataSource;

  SupabaseSearchRepository({required SearchRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Result<SearchPage>> search(SearchQuery query) async {
    try {
      final response = await _dataSource.search(query);
      final rows = response
          .map(SearchResultModel.fromJson)
          .toList(growable: false);
      return Result.success(SearchPage(results: rows, hasMore: rows.length == query.pageSize));
    } on PostgrestException catch (error) {
      final failure = error.code == '42501' || error.code == 'PGRST301'
          ? AuthenticationFailure('Não foi possível autorizar a pesquisa no acervo.', originalError: error)
          : DatabaseFailure('A pesquisa no Supabase falhou: ${error.message}', originalError: error);
      return Result.failure(failure);
    } catch (error) {
      final message = error.toString().toLowerCase();
      final failure = message.contains('socketexception') || message.contains('network') || message.contains('connection')
          ? NetworkFailure('Não foi possível conectar ao acervo histórico.', originalError: error)
          : UnexpectedFailure('Não foi possível concluir a pesquisa.', originalError: error);
      return Result.failure(failure);
    }
  }
}
