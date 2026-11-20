import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/dictionary_controller.dart';
import '../widgets/api_key_banner.dart';
import '../widgets/error_view.dart';

class DictionaryScreen extends StatefulWidget {
  final DictionaryController controller;
  final VoidCallback onOpenSettings;

  const DictionaryScreen({
    super.key,
    required this.controller,
    required this.onOpenSettings,
  });

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    _textController.text = widget.controller.currentWord;
    if (widget.controller.result == null) {
      widget.controller.search(widget.controller.currentWord);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    _textController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _submitSearch([String? term]) {
    final query = term ?? _textController.text;
    if (query.trim().isNotEmpty) {
      _textController.text = query.trim();
      widget.controller.search(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Английский словарь',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          ApiKeyBanner(
            onOpenSettings: widget.onOpenSettings,
            isDemo: controller.isDemoData,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Введите слово (напр. flutter, network)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _textController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onSubmitted: _submitSearch,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: controller.isLoading ? null : () => _submitSearch(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Text('Искать'),
                ),
              ],
            ),
          ),
          // Быстрые подсказки
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: DictionaryController.suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final word = DictionaryController.suggestions[index];
                return ActionChip(
                  label: Text(word),
                  onPressed: () => _submitSearch(word),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Результаты поиска
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.result == null && controller.errorMessage != null
                    ? ErrorView(
                        message: controller.errorMessage!,
                        onRetry: () => _submitSearch(),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: controller.result != null
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              controller.result!.word.toUpperCase(),
                                              style: theme.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.1,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: controller.result!.valid
                                                  ? Colors.green.shade50
                                                  : Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: controller.result!.valid
                                                    ? Colors.green.shade300
                                                    : Colors.orange.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  controller.result!.valid
                                                      ? Icons.check
                                                      : Icons.help_outline,
                                                  size: 14,
                                                  color: controller.result!.valid
                                                      ? Colors.green.shade800
                                                      : Colors.orange.shade800,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  controller.result!.valid
                                                      ? 'Действительное слово'
                                                      : 'Не подтверждено',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller.result!.valid
                                                        ? Colors.green.shade900
                                                        : Colors.orange.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Text(
                                        'Значение слова:',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        controller.result!.definition,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          height: 1.6,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                              text: '${controller.result!.word}: ${controller.result!.definition}',
                                            ));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Определение скопировано'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.copy, size: 16),
                                          label: const Text('Копировать'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
          ),
        ],
      ),
    );
  }
}
