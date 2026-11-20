import 'package:flutter/foundation.dart';
import '../../data/models/dictionary_model.dart';
import '../../data/repositories/ninja_repository.dart';

class DictionaryController extends ChangeNotifier {
  final NinjaRepository _repository;

  DictionaryController(this._repository);

  DictionaryModel? _result;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentWord = 'flutter';
  final List<String> _history = [];
  bool _isDemoData = false;

  DictionaryModel? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentWord => _currentWord;
  List<String> get history => _history;
  bool get isDemoData => _isDemoData;

  static const List<String> suggestions = [
    'flutter',
    'interceptor',
    'network',
    'algorithm',
    'repository',
    'asynchronous',
  ];

  Future<void> search(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty) return;

    _currentWord = trimmed;
    _isLoading = true;
    _errorMessage = null;
    _isDemoData = false;
    notifyListeners();

    try {
      final res = await _repository.getDefinition(trimmed);
      _result = res;
      if (!_history.contains(trimmed)) {
        _history.insert(0, trimmed);
        if (_history.length > 8) _history.removeLast();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _result = _getDemoDefinition(trimmed);
      _isDemoData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DictionaryModel _getDemoDefinition(String word) {
    final Map<String, String> demos = {
      'flutter': 'To flap the wings rapidly without flying; an irregular rapid movement or tremor. Also a popular cross-platform UI framework created by Google.',
      'interceptor': 'A software pattern or component that intercepts requests and responses before they reach their final destination, often used for logging, authentication headers, and caching.',
      'network': 'An interconnected system of things or people; in computing, a group of interconnected computers and peripherals that can share resources and data.',
      'algorithm': 'A step-by-step procedure or set of rules for solving a specific problem or accomplishing a specific task, especially by a computer.',
      'repository': 'A place, room, or container where things are stored; in software architecture, an abstraction that encapsulates data access logic.',
    };

    return DictionaryModel(
      word: word,
      definition: demos[word] ?? 'Demo definition for "$word": A term used in computer science and programming. (Configure API-Ninjas key for live dictionary definitions).',
      valid: true,
    );
  }
}
