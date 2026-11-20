import 'package:flutter/material.dart';

class ApiKeyBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final bool isDemo;

  const ApiKeyBanner({
    super.key,
    required this.onOpenSettings,
    this.isDemo = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDemo) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade900, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Демонстрационный режим',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  'Добавьте свой API-ключ в настройках для загрузки данных в реальном времени с API-Ninjas.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade900.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber.shade200,
              foregroundColor: Colors.amber.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: onOpenSettings,
            child: const Text('Ключ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
