import 'package:flutter/foundation.dart';
import '../../data/models/historical_event_model.dart';
import '../../data/repositories/ninja_repository.dart';

class HistoryController extends ChangeNotifier {
  final NinjaRepository _repository;

  HistoryController(this._repository);

  List<HistoricalEventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = 'space';
  bool _isDemoData = false;

  List<HistoricalEventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;
  bool get isDemoData => _isDemoData;

  static const List<String> suggestions = [
    'space',
    'computer',
    'flight',
    'internet',
    'discovery',
    'telescope',
  ];

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _currentQuery = trimmed;
    _isLoading = true;
    _errorMessage = null;
    _isDemoData = false;
    notifyListeners();

    try {
      final res = await _repository.getHistoricalEvents(trimmed);
      _events = res;
    } catch (e) {
      _errorMessage = e.toString();
      _events = _getDemoEvents(trimmed);
      _isDemoData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HistoricalEventModel> _getDemoEvents(String query) {
    return [
      HistoricalEventModel(
        year: '1961',
        month: '04',
        day: '12',
        event: 'Yuri Gagarin becomes the first human in outer space aboard Vostok 1.',
      ),
      HistoricalEventModel(
        year: '1969',
        month: '07',
        day: '20',
        event: 'Apollo 11 lands on the Moon; Neil Armstrong and Buzz Aldrin become the first humans to walk on its surface.',
      ),
      HistoricalEventModel(
        year: '1981',
        month: '08',
        day: '12',
        event: 'IBM introduces the Personal Computer (IBM PC model 5150), standardizing personal computing.',
      ),
      HistoricalEventModel(
        year: '1990',
        month: '12',
        day: '20',
        event: 'Tim Berners-Lee publishes the first website on the World Wide Web at CERN.',
      ),
      HistoricalEventModel(
        year: '2017',
        month: '05',
        day: '01',
        event: 'Google announces the first alpha release of Flutter at the Google I/O developer conference.',
      ),
    ];
  }
}
