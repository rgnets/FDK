import 'dart:async';
import 'dart:collection';
import 'package:rgnets_fdk/core/config/logger_config.dart';

/// Generic pagination service for efficient data loading
class PaginationService<T> {
  PaginationService({
    required this.pageSize,
    required this.fetchPage,
    this.cachePages = true,
  });

  final int pageSize;
  final Future<List<T>> Function(int page, int pageSize) fetchPage;
  final bool cachePages;

  // State management
  final _items = <T>[];
  final _pageCache = HashMap<int, List<T>>();
  final _loadedPages = <int>{};
  final _logger = LoggerConfig.getLogger();
  bool _hasMore = true;
  bool _isLoading = false;
  int _currentPage = 0;
  
  // Stream for state updates
  final _stateController = StreamController<PaginationState<T>>.broadcast();
  Stream<PaginationState<T>> get stateStream => _stateController.stream;
  
  // Getters
  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  int get totalLoaded => _items.length;
  
  /// Load next page of data
  Future<List<T>> loadNextPage() async {
    if (_isLoading || !_hasMore) {
      return [];
    }
    
    _isLoading = true;
    _notifyState();
    
    try {
      final nextPage = _currentPage + 1;
      
      // Check cache first
      if (cachePages && _pageCache.containsKey(nextPage)) {
        final cachedItems = _pageCache[nextPage]!;
        _items.addAll(cachedItems);
        _loadedPages.add(nextPage);
        _currentPage = nextPage;
        _hasMore = cachedItems.length >= pageSize;
        _isLoading = false;
        _notifyState();
        return cachedItems;
      }
      
      // Fetch from source
      final stopwatch = Stopwatch()..start();
      final newItems = await fetchPage(nextPage, pageSize);
      stopwatch.stop();
      
      _logger.d('PaginationService: Loaded page $nextPage (${newItems.length} items) in ${stopwatch.elapsedMilliseconds}ms');
      
      // Update state
      _items.addAll(newItems);
      _loadedPages.add(nextPage);
      _currentPage = nextPage;
      _hasMore = newItems.length >= pageSize;
      
      // Cache if enabled
      if (cachePages) {
        _pageCache[nextPage] = newItems;
      }
      
      _isLoading = false;
      _notifyState();
      
      return newItems;
    } catch (e) {
      _isLoading = false;
      _notifyState(error: e.toString());
      rethrow;
    }
  }
  
  /// Preload next page in background
  Future<void> preloadNextPage() async {
    if (!_hasMore || _isLoading) {
      return;
    }
    
    final nextPage = _currentPage + 1;
    
    // Already cached
    if (cachePages && _pageCache.containsKey(nextPage)) {
      return;
    }
    
    try {
      // Fetch in background without updating main list
      final newItems = await fetchPage(nextPage, pageSize);
      
      // Cache for future use
      if (cachePages) {
        _pageCache[nextPage] = newItems;
      }
      
      _logger.d('PaginationService: Preloaded page $nextPage (${newItems.length} items)');
    } on Exception catch (e) {
      _logger.e('PaginationService: Error preloading page $nextPage: $e');
    }
  }
  
  /// Load multiple pages in parallel
  Future<void> loadPagesInParallel(int pageCount) async {
    if (_isLoading) {
      return;
    }
    
    _isLoading = true;
    _notifyState();
    
    try {
      final startPage = _currentPage + 1;
      final endPage = startPage + pageCount - 1;
      
      // Create futures for parallel loading
      final futures = <Future<List<T>>>[];
      for (var page = startPage; page <= endPage; page++) {
        // Skip if already cached
        if (cachePages && _pageCache.containsKey(page)) {
          futures.add(Future.value(_pageCache[page]!));
        } else {
          futures.add(fetchPage(page, pageSize));
        }
      }
      
      // Wait for all pages
      final stopwatch = Stopwatch()..start();
      final results = await Future.wait(futures);
      stopwatch.stop();
      
      // Process results
      var totalItems = 0;
      for (var i = 0; i < results.length; i++) {
        final page = startPage + i;
        final items = results[i];
        
        _items.addAll(items);
        _loadedPages.add(page);
        totalItems += items.length;
        
        if (cachePages) {
          _pageCache[page] = items;
        }
        
        if (items.length < pageSize) {
          _hasMore = false;
          break;
        }
      }
      
      _currentPage = endPage;
      
      _logger.d('PaginationService: Loaded $pageCount pages ($totalItems items) in ${stopwatch.elapsedMilliseconds}ms');
      
      _isLoading = false;
      _notifyState();
    } catch (e) {
      _isLoading = false;
      _notifyState(error: e.toString());
      rethrow;
    }
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    _items.clear();
    _pageCache.clear();
    _loadedPages.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    
    _notifyState();
    
    await loadNextPage();
  }
  
  /// Clear cache but keep loaded items
  void clearCache() {
    _pageCache.clear();
  }
  
  /// Notify listeners of state change
  void _notifyState({String? error}) {
    _stateController.add(PaginationState<T>(
      items: items,
      isLoading: _isLoading,
      hasMore: _hasMore,
      currentPage: _currentPage,
      totalLoaded: _items.length,
      error: error,
    ));
  }
  
  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
}

/// State of pagination
class PaginationState<T> {
  const PaginationState({
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.currentPage,
    required this.totalLoaded,
    this.error,
  });
  
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int totalLoaded;
  final String? error;
  
  bool get hasError => error != null;
}