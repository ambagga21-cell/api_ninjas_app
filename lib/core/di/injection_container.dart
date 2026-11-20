import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_endpoints.dart';
import '../network/api_key_interceptor.dart';
import '../services/api_key_storage.dart';
import '../../data/repositories/ninja_repository.dart';
import '../../presentation/controllers/quotes_controller.dart';
import '../../presentation/controllers/riddles_controller.dart';
import '../../presentation/controllers/facts_controller.dart';
import '../../presentation/controllers/dictionary_controller.dart';
import '../../presentation/controllers/history_controller.dart';
import '../../presentation/controllers/settings_controller.dart';

/// Глобальный экземпляр Service Locator из пакета get_it
/// Требование задания:
/// "для управления зависимостями использовать пакет get_it"
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ==========================================
  // 1. Внешние сервисы и локальное хранилище
  // ==========================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<ApiKeyStorage>(
    () => ApiKeyStorage(sl<SharedPreferences>()),
  );

  // ==========================================
  // 2. Интерцепторы Dio
  // ==========================================
  // Кастомный interceptor для добавления токена в заголовок
  sl.registerLazySingleton<ApiKeyInterceptor>(
    () => ApiKeyInterceptor(sl<ApiKeyStorage>()),
  );

  // Логгер сетевых запросов из пакета pretty_dio_logger
  sl.registerLazySingleton<PrettyDioLogger>(
    () => PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
  );

  // ==========================================
  // 3. Сетевой клиент Dio
  // ==========================================
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Добавляем обязательные интерцепторы в цепочку Dio
    dio.interceptors.addAll([
      sl<ApiKeyInterceptor>(),
      sl<PrettyDioLogger>(),
    ]);

    return dio;
  });

  // ==========================================
  // 4. Репозитории данных
  // ==========================================
  sl.registerLazySingleton<NinjaRepository>(
    () => NinjaRepositoryImpl(sl<Dio>()),
  );

  // ==========================================
  // 5. Контроллеры состояния экранов
  // ==========================================
  sl.registerFactory<QuotesController>(
    () => QuotesController(sl<NinjaRepository>()),
  );

  sl.registerFactory<RiddlesController>(
    () => RiddlesController(sl<NinjaRepository>()),
  );

  sl.registerFactory<FactsController>(
    () => FactsController(sl<NinjaRepository>()),
  );

  sl.registerFactory<DictionaryController>(
    () => DictionaryController(sl<NinjaRepository>()),
  );

  sl.registerFactory<HistoryController>(
    () => HistoryController(sl<NinjaRepository>()),
  );

  sl.registerLazySingleton<SettingsController>(
    () => SettingsController(
      sl<ApiKeyStorage>(),
      sl<NinjaRepository>(),
    ),
  );
}
