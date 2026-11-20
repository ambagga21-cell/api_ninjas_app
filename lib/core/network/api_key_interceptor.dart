import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api_key_storage.dart';

/// Кастомный Interceptor для автоматического добавления токена/API-ключа в заголовок запроса.
/// Требование задания:
/// "создать класс interceptor, ответственный за добавление токена в заголовок"
class ApiKeyInterceptor extends Interceptor {
  final ApiKeyStorage _keyStorage;

  ApiKeyInterceptor(this._keyStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = _keyStorage.apiKey;

    if (key.isNotEmpty) {
      // API Ninjas требует ключ в заголовке 'X-Api-Key'
      options.headers['X-Api-Key'] = key;
      // Также добавляем стандартный Authorization заголовок при необходимости
      options.headers['Authorization'] = 'Bearer $key';

      if (kDebugMode) {
        debugPrint('[ApiKeyInterceptor] Добавлен токен в заголовки: ${options.path}');
      }
    } else {
      if (kDebugMode) {
        debugPrint('[ApiKeyInterceptor] Внимание: API-ключ не задан в хранилище');
      }
    }

    // Передаем управление дальше по цепочке интерцепторов
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[ApiKeyInterceptor] Успешный ответ: ${response.statusCode} [${response.requestOptions.path}]');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[ApiKeyInterceptor] Ошибка запроса [${err.requestOptions.path}]: ${err.response?.statusCode} - ${err.message}');
    }
    return super.onError(err, handler);
  }
}
