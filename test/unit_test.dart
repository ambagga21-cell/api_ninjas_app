import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api_ninjas_app/core/network/api_key_interceptor.dart';
import 'package:api_ninjas_app/core/services/api_key_storage.dart';
import 'package:api_ninjas_app/data/models/quote_model.dart';
import 'package:api_ninjas_app/data/models/riddle_model.dart';
import 'package:api_ninjas_app/data/models/fact_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiKeyInterceptor Tests (Оценка 4 и 5)', () {
    test('Автоматически добавляет X-Api-Key в заголовки Dio запроса', () async {
      SharedPreferences.setMockInitialValues({'ninja_api_key': 'test_secret_token_123'});
      final prefs = await SharedPreferences.getInstance();
      final storage = ApiKeyStorage(prefs);
      final interceptor = ApiKeyInterceptor(storage);

      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Проверяем, что заголовок добавлен
            expect(options.headers['X-Api-Key'], equals('test_secret_token_123'));
            expect(options.headers['Authorization'], equals('Bearer test_secret_token_123'));
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {'success': true},
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final response = await dio.get('https://api.api-ninjas.com/v1/facts');
      expect(response.statusCode, equals(200));
    });
  });

  group('Models Serialization Tests', () {
    test('QuoteModel correctly parses JSON', () {
      final json = {
        'quote': 'Knowledge is power.',
        'author': 'Francis Bacon',
        'category': 'knowledge',
      };
      final model = QuoteModel.fromJson(json);
      expect(model.quote, equals('Knowledge is power.'));
      expect(model.author, equals('Francis Bacon'));
      expect(model.category, equals('knowledge'));
    });

    test('RiddleModel correctly parses JSON', () {
      final json = {
        'title': 'Test Riddle',
        'question': 'What gets wetter as it dries?',
        'answer': 'A towel.',
      };
      final model = RiddleModel.fromJson(json);
      expect(model.title, equals('Test Riddle'));
      expect(model.question, equals('What gets wetter as it dries?'));
      expect(model.answer, equals('A towel.'));
    });

    test('FactModel correctly parses JSON', () {
      final json = {'fact': 'Earth is the third planet from the Sun.'};
      final model = FactModel.fromJson(json);
      expect(model.fact, equals('Earth is the third planet from the Sun.'));
    });
  });
}
