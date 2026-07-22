import 'package:chronos/core/utils/result.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<Result<SearchPage>> search(SearchQuery query);
}
