import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchService {
  final SearchRepository _repository;

  SearchService(this._repository);

  Future<List<SearchResult>> executeSearch({
    required String query,
    List<String>? entityTypes,
    required String sortBy,
    required int limit,
    required int offset,
  }) {
    if (query.trim().isEmpty) {
      return Future.value([]);
    }
    return _repository.search(
      query: query.trim(),
      entityTypes: entityTypes,
      sortBy: sortBy,
      limit: limit,
      offset: offset,
    );
  }
}
