import 'package:flutter/foundation.dart';
import '../../data/models/riddle_model.dart';
import '../../data/repositories/ninja_repository.dart';

class RiddlesController extends ChangeNotifier {
  final NinjaRepository _repository;

  RiddlesController(this._repository);

  List<RiddleModel> _riddles = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<int> _revealedIndices = {};
  bool _isDemoData = false;

  List<RiddleModel> get riddles => _riddles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool _isRevealed(int index) => _revealedIndices.contains(index);
  bool isRevealed(int index) => _isRevealed(index);
  bool get isDemoData => _isDemoData;

  void toggleAnswer(int index) {
    if (_revealedIndices.contains(index)) {
      _revealedIndices.remove(index);
    } else {
      _revealedIndices.add(index);
    }
    notifyListeners();
  }

  void revealAll() {
    for (int i = 0; i < _riddles.length; i++) {
      _revealedIndices.add(i);
    }
    notifyListeners();
  }

  void hideAll() {
    _revealedIndices.clear();
    notifyListeners();
  }

  Future<void> fetchRiddles({int limit = 5}) async {
    _isLoading = true;
    _errorMessage = null;
    _isDemoData = false;
    _revealedIndices.clear();
    notifyListeners();

    try {
      final result = await _repository.getRiddles(limit: limit);
      _riddles = result;
    } catch (e) {
      _errorMessage = e.toString();
      _riddles = _getDemoRiddles();
      _isDemoData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<RiddleModel> _getDemoRiddles() {
    return [
      RiddleModel(
        title: 'Загадка о времени',
        question: 'This thing all things devours; Birds, beasts, trees, flowers; Gnaws iron, bites steel; Grinds hard stones to meal; Slays king, ruins town, and beats high mountain down. What is it?',
        answer: 'Time (Время)',
      ),
      RiddleModel(
        title: 'Загадка о сундуке',
        question: 'A box without hinges, key, or lid, yet golden treasure inside is hid. What am I?',
        answer: 'An egg (Яйцо)',
      ),
      RiddleModel(
        title: 'Загадка о звуке',
        question: 'I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?',
        answer: 'An echo (Эхо)',
      ),
      RiddleModel(
        title: 'Загадка о темноте',
        question: 'The more of this there is, the less you see. What is it?',
        answer: 'Darkness (Темнота)',
      ),
    ];
  }
}
