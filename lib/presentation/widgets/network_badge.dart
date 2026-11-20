import 'package:flutter/material.dart';

class ArchitectureInfoDialog extends StatelessWidget {
  const ArchitectureInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.verified_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Архитектура (Оценка 5)'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(
              context,
              title: '1. Сеть: Пакет Dio',
              description: 'Все HTTP-запросы (GET) к https://api.api-ninjas.com выполняются через настроенный экземпляр Dio с таймаутами и обработкой ошибок.',
              icon: Icons.cloud_done_outlined,
            ),
            const Divider(height: 24),
            _buildItem(
              context,
              title: '2. Кастомный Interceptor (ApiKeyInterceptor)',
              description: 'Класс ApiKeyInterceptor наследуется от Interceptor и автоматически инжектирует заголовок "X-Api-Key" и "Authorization" в каждый запрос перед отправкой.',
              icon: Icons.key_outlined,
            ),
            const Divider(height: 24),
            _buildItem(
              context,
              title: '3. pretty_dio_logger',
              description: 'В цепочку Dio interceptors включен PrettyDioLogger, который форматирует и печатает подробные логи запросов и ответов в консоль разработки.',
              icon: Icons.receipt_long_outlined,
            ),
            const Divider(height: 24),
            _buildItem(
              context,
              title: '4. Управление зависимостями: get_it',
              description: 'Все зависимости (Dio, ApiKeyInterceptor, PrettyDioLogger, NinjaRepository, ApiKeyStorage, Controllers) зарегистрированы в Service Locator (sl / GetIt) в injection_container.dart.',
              icon: Icons.hub_outlined,
            ),
            const Divider(height: 24),
            _buildItem(
              context,
              title: '5. Реальный API: API-Ninjas',
              description: 'Реализовано 5 разных разделов: Цитаты, Загадки, Факты, Английский словарь и Исторические события с поиском и фильтрацией.',
              icon: Icons.public_outlined,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно'),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
