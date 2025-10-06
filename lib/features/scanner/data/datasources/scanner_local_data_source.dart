import 'package:rgnets_fdk/features/scanner/data/models/scan_session_model.dart';

abstract class ScannerLocalDataSource {
  Future<void> cacheScanSession(ScanSessionModel session);
  Future<ScanSessionModel?> getCachedSession();
  Future<void> clearCachedSession();
  Future<List<ScanSessionModel>> getScanHistory();
  Future<void> addToHistory(ScanSessionModel session);
  Future<void> clearHistory();
}

class ScannerLocalDataSourceImpl implements ScannerLocalDataSource {
  ScanSessionModel? _currentSession;
  final List<ScanSessionModel> _history = [];

  @override
  Future<void> cacheScanSession(ScanSessionModel session) async {
    _currentSession = session;
  }

  @override
  Future<ScanSessionModel?> getCachedSession() async {
    return _currentSession;
  }

  @override
  Future<void> clearCachedSession() async {
    _currentSession = null;
  }

  @override
  Future<List<ScanSessionModel>> getScanHistory() async {
    return List.from(_history);
  }

  @override
  Future<void> addToHistory(ScanSessionModel session) async {
    _history.add(session);
    // Keep only last 50 sessions
    if (_history.length > 50) {
      _history.removeAt(0);
    }
  }

  @override
  Future<void> clearHistory() async {
    _history.clear();
  }
}