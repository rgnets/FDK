import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_ui_state_provider.g.dart';

/// UI state for room list filtering and searching
class RoomUIState {
  const RoomUIState({
    this.searchQuery = '',
    this.isSearching = false,
  });

  final String searchQuery;
  final bool isSearching;

  RoomUIState copyWith({
    String? searchQuery,
    bool? isSearching,
  }) {
    return RoomUIState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// Provider for room UI state (search, filters, etc.)
@riverpod
class RoomUIStateNotifier extends _$RoomUIStateNotifier {
  @override
  RoomUIState build() {
    return const RoomUIState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSearching({required bool isSearching}) {
    state = state.copyWith(isSearching: isSearching);
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      isSearching: false,
    );
  }
}
