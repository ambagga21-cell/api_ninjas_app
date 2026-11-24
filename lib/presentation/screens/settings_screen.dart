import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/settings_controller.dart';
import '../widgets/network_badge.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsController controller;

  const SettingsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    _keyController.text = widget.controller.apiKey;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    _keyController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _saveKey() async {
    final messenger = ScaffoldMessenger.of(context);
    final key = _keyController.text.trim();
    await widget.controller.saveApiKey(key);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('API-ключ успешно сохранен в памяти и SharedPreferences'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Настройки & API-Ninjas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Карточка управления ключом API
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.vpn_key_outlined, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'API-ключ (X-Api-Key)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ключ автоматически добавляется в заголовки всех сетевых запросов через зарегистрированный в Dio класс ApiKeyInterceptor.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      labelText: 'Ваш API-ключ от api-ninjas.com',
                      hintText: 'Вставьте ваш ключ...',
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscureKey ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureKey = !_obscureKey;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.paste),
                            tooltip: 'Вставить из буфера',
                            onPressed: () async {
                              final data = await Clipboard.getData('text/plain');
                              if (data?.text != null) {
                                _keyController.text = data!.text!.trim();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saveKey,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Сохранить ключ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          _keyController.clear();
                          await controller.clearApiKey();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Ключ очищен')),
                          );
                        },
                        child: const Text('Очистить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: controller.isTesting
                        ? null
                        : () async {
                            // Сохраняем перед тестированием
                            await controller.saveApiKey(_keyController.text.trim());
                            await controller.testConnection();
                          },
                    icon: controller.isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(
                      controller.isTesting ? 'Проверка...' : 'Проверить соединение (Ping)',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Результат проверки соединения
          if (controller.testResult != null) ...[
            const SizedBox(height: 16),
            _buildTestResultCard(context, controller.testResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResultCard(BuildContext context, Map<String, dynamic> result) {
    final success = result['success'] == true;
    final statusCode = result['statusCode'];
    final durationMs = result['durationMs'];
    final message = result['message']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: success ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? Colors.green.shade800 : Colors.red.shade800,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success ? 'Подключение успешно!' : 'Ошибка подключения',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: success ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
              ),
              if (statusCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: success ? Colors.green.shade200 : Colors.red.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HTTP $statusCode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: success ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: success ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
          if (durationMs != null) ...[
            const SizedBox(height: 6),
            Text(
              'Время отклика: $durationMs мс',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: success ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
