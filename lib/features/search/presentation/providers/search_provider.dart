import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart' show realSearchRepositoryProvider, realSearchServiceProvider;
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/search_service.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return ref.watch(realSearchRepositoryProvider);
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return ref.watch(realSearchServiceProvider);
});

class SearchState {
  final String query;
  final List<String> filters;
  final String sortBy;
  final List<SearchResult> results;
  final bool isLoading;

  SearchState({
    required this.query,
    required this.filters,
    required this.sortBy,
    required this.results,
    required this.isLoading,
  });

  factory SearchState.initial() {
    return SearchState(
      query: '',
      filters: [],
      sortBy: 'date_desc',
      results: [],
      isLoading: false,
    );
  }

  SearchState copyWith({
    String? query,
    List<String>? filters,
    String? sortBy,
    List<SearchResult>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _service;

  SearchNotifier(this._service) : super(SearchState.initial());

  Future<void> updateQuery(String newQuery) async {
    state = state.copyWith(query: newQuery, isLoading: true);
    await _performSearch();
  }

  Future<void> toggleFilter(String filter) async {
    final newFilters = List<String>.from(state.filters);
    if (newFilters.contains(filter)) {
      newFilters.remove(filter);
    } else {
      newFilters.add(filter);
    }
    state = state.copyWith(filters: newFilters, isLoading: true);
    await _performSearch();
  }

  Future<void> updateSort(String newSortBy) async {
    state = state.copyWith(sortBy: newSortBy, isLoading: true);
    await _performSearch();
  }

  Future<void> _performSearch() async {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }
    final results = await _service.executeSearch(
      query: state.query,
      entityTypes: state.filters.isEmpty ? null : state.filters,
      sortBy: state.sortBy,
      limit: 100,
      offset: 0,
    );
    state = state.copyWith(results: results, isLoading: false);
  }
}

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchServiceProvider));
});
