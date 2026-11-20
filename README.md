# Ninja Network Hub (Работа с сетью во Flutter)

Приложение Flutter для взаимодействия с REST API сервиса [API-Ninjas](https://api-ninjas.com), разработанное в строгом соответствии с требованиями практического задания на максимальную оценку (**Оценка 5**).

---

## 🎯 Соответствие критериям оценивания

| Оценка | Требования | Реализация в проекте |
| :--- | :--- | :--- |
| **Оценка 3** | Разработать приложение, которое работает с сетью с использованием пакета **Dio**. | Клиент `Dio` сконфигурирован в `lib/core/di/injection_container.dart` с базовым URL `https://api.api-ninjas.com/v1`, таймаутами подключения и заголовками. Выполняются реальные GET-запросы через `NinjaRepositoryImpl`. |
| **Оценка 4** | Добавить класс `interceptor`, который автоматически добавляет токен в заголовок, и использовать interceptor от пакета `pretty_dio_logger`. | 1. Создан класс `ApiKeyInterceptor extends Interceptor` (`lib/core/network/api_key_interceptor.dart`), переопределяющий `onRequest` и добавляющий `X-Api-Key` и `Authorization: Bearer <key>`.<br>2. Подключен и настроен `PrettyDioLogger` с красивым форматированием заголовков, тела запросов и ответов в консоли. |
| **Оценка 5** | Использовать `Dio`, кастомный `interceptor` для токена, `pretty_dio_logger` и пакет `get_it` для управления зависимостями. Приложение должно обладать богатой функциональностью (не две кнопки). | 1. Все сервисы, клиент `Dio`, интерцепторы, репозитории и контроллеры зарегистрированы в `get_it` Service Locator (`lib/core/di/injection_container.dart`).<br>2. Реализовано **5 интерактивных разделов** API-Ninjas + экран настроек и проверки сети. |

---

## 📱 Функциональные разделы приложения

1. **Цитаты & Мудрость (`/v1/quotes`)**:
   - Фильтрация по 9 категориям (`inspirational`, `life`, `success`, `wisdom`, `knowledge` и др.).
   - Копирование цитат в буфер обмена с всплывающим уведомлением.
   - Генерация случайных цитат и pull-to-refresh.

2. **Загадки & Головоломки (`/v1/riddles`)**:
   - Интерактивные карточки с загадками.
   - Кнопка разгадки «Показать ответ» с анимацией и подсветкой правильного ответа.
   - Быстрые действия в шапке: «Показать все ответы» / «Скрыть все ответы».

3. **Удивительные факты (`/v1/facts`)**:
   - Лента познавательных научных и исторических фактов с нумерацией.
   - Быстрое копирование любого факта.
   - Кнопка генерации новой порции фактов.

4. **Английский толковый словарь (`/v1/dictionary`)**:
   - Поисковая строка для любого слова на английском языке.
   - Быстрые чипы-подсказки (`flutter`, `interceptor`, `network`, `algorithm`, `repository`, `asynchronous`).
   - Бейдж валидности слова и подробное толкование.

5. **Исторические события (`/v1/historicalevents`)**:
   - Поиск исторических фактов по ключевым словам (`space`, `computer`, `flight`, `internet`).
   - Красивое отображение даты и описания события.

6. **Настройки & Статус API**:
   - Поле для ввода и сохранения персонального API-ключа от `api-ninjas.com`.
   - Кнопка «Проверить соединение (Ping)», делающая тестовый запрос с отображением HTTP-статуса и времени отклика в миллисекундах.
   - Модальное окно с детальным описанием архитектуры проекта.
   - Демонстрационный режим: если ключ ещё не указан, приложение не падает, а показывает демо-данные с предупреждающим баннером.

---

## 📂 Структура проекта

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart    # Регистрация зависимостей в GetIt (sl)
│   ├── network/
│   │   ├── api_endpoints.dart          # Константы путей API-Ninjas
│   │   ├── api_exception.dart          # Обработка сетевых ошибок DioException
│   │   └── api_key_interceptor.dart    # Кастомный Interceptor для добавления токена
│   ├── services/
│   │   └── api_key_storage.dart        # Хранилище API-ключа в SharedPreferences
│   └── theme/
│       └── app_theme.dart              # Светлая и темная тема Material 3
├── data/
│   ├── models/
│   │   ├── quote_model.dart            # Модель цитаты
│   │   ├── riddle_model.dart           # Модель загадки
│   │   ├── fact_model.dart             # Модель факта
│   │   ├── dictionary_model.dart       # Модель словарной статьи
│   │   └── historical_event_model.dart # Модель исторического события
│   └── repositories/
│       └── ninja_repository.dart       # Контракт и реализация сетевых запросов через Dio
├── presentation/
│   ├── controllers/                    # ViewModels (ChangeNotifier)
│   │   ├── quotes_controller.dart
│   │   ├── riddles_controller.dart
│   │   ├── facts_controller.dart
│   │   ├── dictionary_controller.dart
│   │   ├── history_controller.dart
│   │   └── settings_controller.dart
│   ├── screens/                        # Пользовательские экраны
│   │   ├── home_screen.dart            # Главный навигационный экран (Adaptive)
│   │   ├── quotes_screen.dart
│   │   ├── riddles_screen.dart
│   │   ├── facts_screen.dart
│   │   ├── dictionary_screen.dart
│   │   ├── history_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/                        # Переиспользуемые виджеты
│       ├── api_key_banner.dart
│       ├── error_view.dart
│       └── network_badge.dart
└── main.dart                           # Точка входа в приложение
```

---

## 🚀 Запуск проекта

### 1. Переход в каталог проекта
```bash
cd C:\Users\Александр\.gemini\antigravity\scratch\api_ninjas_app
```

### 2. Запуск тестов
```bash
flutter test
```

### 3. Запуск приложения
```bash
# Запуск на Windows Desktop
flutter run -d windows

# Либо запуск в браузере Chrome
flutter run -d chrome
```

---

## 🔑 Получение бесплатного API-ключа
1. Зарегистрируйтесь на сайте [https://api-ninjas.com](https://api-ninjas.com).
2. В личном кабинете скопируйте свой API Key.
3. Откройте в приложении вкладку **«Настройки»**, вставьте ключ и нажмите **«Сохранить ключ»**.
4. Нажмите **«Проверить соединение (Ping)»** для подтверждения готовности.
