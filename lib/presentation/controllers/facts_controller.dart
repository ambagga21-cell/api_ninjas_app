import 'package:flutter/foundation.dart';
import '../../data/models/fact_model.dart';
import '../../data/repositories/ninja_repository.dart';

class FactsController extends ChangeNotifier {
  final NinjaRepository _repository;

  FactsController(this._repository);

  List<FactModel> _facts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDemoData = false;

  List<FactModel> get facts => _facts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDemoData => _isDemoData;

  Future<void> fetchFacts({int limit = 6}) async {
    _isLoading = true;
    _errorMessage = null;
    _isDemoData = false;
    notifyListeners();

    try {
      final result = await _repository.getFacts(limit: limit);
      _facts = result;
    } catch (e) {
      _errorMessage = e.toString();
      _facts = _getDemoFacts();
      _isDemoData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMoreFacts({int limit = 3}) async {
    try {
      final newFacts = await _repository.getFacts(limit: limit);
      _facts.addAll(newFacts);
      notifyListeners();
    } catch (e) {
      // Игнорируем или обновляем
    }
  }

  List<FactModel> _getDemoFacts() {
    return [
      FactModel(fact: 'A single cloud can weigh more than 1 million pounds (approx. 500,000 kg).'),
      FactModel(fact: 'Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible.'),
      FactModel(fact: 'Octopuses have three hearts, nine brains, and blue blood.'),
      FactModel(fact: 'Bananas are berries, but strawberries are not botanically berries.'),
      FactModel(fact: 'The Eiffel Tower can be 15 cm taller during summer due to thermal expansion of iron.'),
      FactModel(fact: 'Flutter was originally known as "Sky" and ran on Android, aiming for 120 frames per second.'),
    ];
  }
}
