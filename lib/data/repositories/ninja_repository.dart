import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/quote_model.dart';
import '../models/riddle_model.dart';
import '../models/fact_model.dart';
import '../models/dictionary_model.dart';
import '../models/historical_event_model.dart';

abstract class NinjaRepository {
  Future<List<QuoteModel>> getQuotes({String? category, int limit = 5});
  Future<List<RiddleModel>> getRiddles({int limit = 5});
  Future<List<FactModel>> getFacts({int limit = 5});
  Future<DictionaryModel> getDefinition(String word);
  Future<List<HistoricalEventModel>> getHistoricalEvents(String query);
  Future<Map<String, dynamic>> testConnection();
}

class NinjaRepositoryImpl implements NinjaRepository {
  final Dio _dio;

  NinjaRepositoryImpl(this._dio);

  @override
  Future<List<QuoteModel>> getQuotes({String? category, int limit = 5}) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        ApiEndpoints.quotes,
        queryParameters: queryParams,
      );

      final list = (response.data as List)
          .map((item) => QuoteModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Ошибка при получении цитат: $e');
    }
  }

  @override
  Future<List<RiddleModel>> getRiddles({int limit = 5}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.riddles,
        queryParameters: {'limit': limit},
      );

      final list = (response.data as List)
          .map((item) => RiddleModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Ошибка при получении загадок: $e');
    }
  }

  @override
  Future<List<FactModel>> getFacts({int limit = 5}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.facts,
        queryParameters: {'limit': limit},
      );

      final list = (response.data as List)
          .map((item) => FactModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Ошибка при получении фактов: $e');
    }
  }

  @override
  Future<DictionaryModel> getDefinition(String word) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.dictionary,
        queryParameters: {'word': word.trim()},
      );

      return DictionaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Ошибка при поиске в словаре: $e');
    }
  }

  @override
  Future<List<HistoricalEventModel>> getHistoricalEvents(String query) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.historicalEvents,
        queryParameters: {'text': query.trim()},
      );

      final list = (response.data as List)
          .map((item) => HistoricalEventModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Ошибка при поиске исторических событий: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testConnection() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Делаем легкий тестовый запрос (1 факт)
      final response = await _dio.get(
        ApiEndpoints.facts,
        queryParameters: {'limit': 1},
      );
      stopwatch.stop();

      return {
        'success': true,
        'statusCode': response.statusCode,
        'durationMs': stopwatch.elapsedMilliseconds,
        'message': 'Соединение успешно! API-ключ действителен.',
        'data': response.data,
      };
    } on DioException catch (e) {
      stopwatch.stop();
      final apiEx = ApiException.fromDioException(e);
      return {
        'success': false,
        'statusCode': e.response?.statusCode,
        'durationMs': stopwatch.elapsedMilliseconds,
        'message': apiEx.message,
        'error': e.toString(),
      };
    }
  }
}
