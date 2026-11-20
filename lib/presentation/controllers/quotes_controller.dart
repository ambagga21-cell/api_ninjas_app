import 'package:flutter/foundation.dart';
import '../../data/models/quote_model.dart';
import '../../data/repositories/ninja_repository.dart';

class QuotesController extends ChangeNotifier {
  final NinjaRepository _repository;

  QuotesController(this._repository);

  List<QuoteModel> _quotes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'all';
  int _limit = 5;
  bool _isDemoData = false;

  List<QuoteModel> get quotes => _quotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  int get limit => _limit;
  bool get isDemoData => _isDemoData;

  static const List<String> availableCategories = [
    'all',
    'inspirational',
    'life',
    'success',
    'happiness',
    'wisdom',
    'knowledge',
    'courage',
    'attitude',
  ];

  Future<void> fetchQuotes({String? category, int? limit}) async {
    if (category != null) _selectedCategory = category;
    if (limit != null) _limit = limit;

    _isLoading = true;
    _errorMessage = null;
    _isDemoData = false;
    notifyListeners();

    try {
      final result = await _repository.getQuotes(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        limit: _limit,
      );
      _quotes = result;
    } catch (e) {
      _errorMessage = e.toString();
      // Запасные демонстрационные данные на случай отсутствия ключа
      _quotes = _getDemoQuotes(_selectedCategory);
      _isDemoData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchQuotes();
  }

  void setLimit(int limit) {
    _limit = limit;
    fetchQuotes();
  }

  List<QuoteModel> _getDemoQuotes(String category) {
    return [
      QuoteModel(
        quote: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
        category: 'success',
      ),
      QuoteModel(
        quote: 'Life is what happens when you’re busy making other plans.',
        author: 'John Lennon',
        category: 'life',
      ),
      QuoteModel(
        quote: 'Simplicity is the soul of efficiency.',
        author: 'Austin Freeman',
        category: 'knowledge',
      ),
      QuoteModel(
        quote: 'In the middle of difficulty lies opportunity.',
        author: 'Albert Einstein',
        category: 'inspirational',
      ),
      QuoteModel(
        quote: 'Happiness is not something ready made. It comes from your own actions.',
        author: 'Dalai Lama',
        category: 'happiness',
      ),
    ];
  }
}
