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
      // На бесплатном тарифе API-Ninjas параметры limit и category доступны только по подписке Premium.
      // Делаем легкие параллельные запросы без query-параметров для получения свежих цитат:
      final count = limit.clamp(1, 4);
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.quotes)),
      );

      final list = <QuoteModel>[];
      for (final resp in responses) {
        if (resp.data is List && (resp.data as List).isNotEmpty) {
          list.add(QuoteModel.fromJson((resp.data as List).first as Map<String, dynamic>));
        }
      }
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
      // На бесплатном тарифе API-Ninjas параметр limit доступен только по подписке Premium.
      final count = limit.clamp(1, 4);
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.riddles)),
      );

      final list = <RiddleModel>[];
      for (final resp in responses) {
        if (resp.data is List && (resp.data as List).isNotEmpty) {
          list.add(RiddleModel.fromJson((resp.data as List).first as Map<String, dynamic>));
        }
      }
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
      // На бесплатном тарифе API-Ninjas параметр limit доступен только по подписке Premium.
      final count = limit.clamp(1, 4);
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.facts)),
      );

      final list = <FactModel>[];
      for (final resp in responses) {
        if (resp.data is List && (resp.data as List).isNotEmpty) {
          list.add(FactModel.fromJson((resp.data as List).first as Map<String, dynamic>));
        }
      }
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
      // Делаем легкий тестовый запрос без query-параметров (на Free-тарифе limit запрещен)
      final response = await _dio.get(
        ApiEndpoints.facts,
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
