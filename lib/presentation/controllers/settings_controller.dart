import 'package:flutter/foundation.dart';
import '../../core/services/api_key_storage.dart';
import '../../data/repositories/ninja_repository.dart';

class SettingsController extends ChangeNotifier {
  final ApiKeyStorage _keyStorage;
  final NinjaRepository _repository;

  SettingsController(this._keyStorage, this._repository);

  bool _isTesting = false;
  Map<String, dynamic>? _testResult;

  bool get isTesting => _isTesting;
  Map<String, dynamic>? get testResult => _testResult;
  String get apiKey => _keyStorage.apiKey;
  bool get hasValidKey => _keyStorage.hasValidKey;

  Future<void> saveApiKey(String key) async {
    await _keyStorage.setApiKey(key);
    _testResult = null;
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    await _keyStorage.clearApiKey();
    _testResult = null;
    notifyListeners();
  }

  Future<void> testConnection() async {
    _isTesting = true;
    _testResult = null;
    notifyListeners();

    try {
      final res = await _repository.testConnection();
      _testResult = res;
    } catch (e) {
      _testResult = {
        'success': false,
        'message': 'Ошибка при проверке соединения: $e',
      };
    } finally {
      _isTesting = false;
      notifyListeners();
    }
  }
}
