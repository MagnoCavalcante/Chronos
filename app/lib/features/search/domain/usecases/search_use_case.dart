import 'package:chronos/core/utils/result.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository _repository;

  const SearchUseCase(this._repository);

  Future<Result<SearchPage>> call(SearchQuery query) => _repository.search(query);
}
