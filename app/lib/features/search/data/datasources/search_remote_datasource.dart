import 'package:chronos/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/search_result.dart';

abstract class SearchRemoteDataSource {
  Future<List<Map<String, dynamic>>> search(SearchQuery query);
}

class SupabaseSearchRemoteDataSource implements SearchRemoteDataSource {
  final SupabaseClient _client;

  SupabaseSearchRemoteDataSource({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<Map<String, dynamic>>> search(SearchQuery query) async {
    final response = await _client.rpc(
      'search_chronos',
      params: {
        'p_query': query.text,
        'p_category': query.category.entityType,
        'p_sort': query.sort.value,
        'p_limit': query.pageSize,
        'p_offset': query.offset,
      },
    );
    return (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }
}
