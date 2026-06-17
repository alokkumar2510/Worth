import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> search({
    required String query,
    List<String>? entityTypes,
    required String sortBy, // date_desc | date_asc | name_asc
    required int limit,
    required int offset,
  });
}
