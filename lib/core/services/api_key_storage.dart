import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyStorage extends ChangeNotifier {
  static const String _keyPref = 'ninja_api_key';
  
  // Default placeholder or public demo key
  // Users can easily set their own key in the Settings tab
  static const String defaultKey = 'YOUR_API_NINJAS_KEY_HERE';

  final SharedPreferences _prefs;
  String _apiKey;

  ApiKeyStorage(this._prefs) : _apiKey = _prefs.getString(_keyPref) ?? '' {
    if (_apiKey.isEmpty) {
      // If none set, start with empty or placeholder
      _apiKey = '';
    }
  }

  String get apiKey => _apiKey;

  bool get hasValidKey => _apiKey.trim().isNotEmpty && _apiKey != defaultKey;

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    await _prefs.setString(_keyPref, _apiKey);
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    _apiKey = '';
    await _prefs.remove(_keyPref);
    notifyListeners();
  }
}
