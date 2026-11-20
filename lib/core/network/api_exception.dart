import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Таймаут подключения к серверу API-Ninjas. Проверьте интернет.',
          originalError: error,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Таймаут отправки запроса.',
          originalError: error,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Таймаут получения ответа от сервера.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final responseData = error.response?.data;
        String detail = '';
        if (responseData is Map && responseData.containsKey('error')) {
          detail = ': ${responseData['error']}';
        }

        if (status == 400) {
          return ApiException(
            message: 'Неверный запрос (400)$detail. Проверьте параметры запроса.',
            statusCode: status,
            originalError: error,
          );
        } else if (status == 401 || status == 403) {
          return ApiException(
            message: 'Неверный или отсутствующий API-ключ ($status). Укажите корректный ключ в настройках (X-Api-Key).',
            statusCode: status,
            originalError: error,
          );
        } else if (status == 429) {
          return ApiException(
            message: 'Превышен лимит запросов к API-Ninjas (429). Повторите попытку позже.',
            statusCode: status,
            originalError: error,
          );
        } else if (status != null && status >= 500) {
          return ApiException(
            message: 'Ошибка сервера API-Ninjas ($status). Повторите позже.',
            statusCode: status,
            originalError: error,
          );
        }
        return ApiException(
          message: 'Ошибка ответа сервера ($status)$detail.',
          statusCode: status,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Запрос был отменен.',
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Ошибка сети. Нет связи с https://api.api-ninjas.com. Проверьте подключение к сети.',
          originalError: error,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: 'Непредвиденная сетевая ошибка: ${error.message ?? error.toString()}',
          originalError: error,
        );
    }
  }

  @override
  String toString() => message;
}
