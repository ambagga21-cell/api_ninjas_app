import 'package:flutter/material.dart';
import '../controllers/riddles_controller.dart';
import '../widgets/api_key_banner.dart';
import '../widgets/error_view.dart';

class RiddlesScreen extends StatefulWidget {
  final RiddlesController controller;
  final VoidCallback onOpenSettings;

  const RiddlesScreen({
    super.key,
    required this.controller,
    required this.onOpenSettings,
  });

  @override
  State<RiddlesScreen> createState() => _RiddlesScreenState();
}

class _RiddlesScreenState extends State<RiddlesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    if (widget.controller.riddles.isEmpty) {
      widget.controller.fetchRiddles();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Загадки & Головоломки',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Показать все ответы',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: controller.riddles.isEmpty ? null : () => controller.revealAll(),
          ),
          IconButton(
            tooltip: 'Скрыть все ответы',
            icon: const Icon(Icons.visibility_off_outlined),
            onPressed: controller.riddles.isEmpty ? null : () => controller.hideAll(),
          ),
          IconButton(
            tooltip: 'Обновить загадки',
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading ? null : () => controller.fetchRiddles(),
          ),
        ],
      ),
      body: Column(
        children: [
          ApiKeyBanner(
            onOpenSettings: widget.onOpenSettings,
            isDemo: controller.isDemoData,
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.riddles.isEmpty && controller.errorMessage != null
                    ? ErrorView(
                        message: controller.errorMessage!,
                        onRetry: () => controller.fetchRiddles(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchRiddles(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.riddles.length,
                          itemBuilder: (context, index) {
                            final riddle = controller.riddles[index];
                            final isRevealed = controller.isRevealed(index);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondaryContainer.withAlpha(120),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.psychology_outlined,
                                            size: 22,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            riddle.title.isNotEmpty
                                                ? riddle.title
                                                : 'Загадка #${index + 1}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      riddle.question,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AnimatedCrossFade(
                                      duration: const Duration(milliseconds: 250),
                                      crossFadeState: isRevealed
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      firstChild: Align(
                                        alignment: Alignment.centerLeft,
                                        child: OutlinedButton.icon(
                                          onPressed: () => controller.toggleAnswer(index),
                                          icon: const Icon(Icons.help_outline, size: 18),
                                          label: const Text('Показать ответ'),
                                        ),
                                      ),
                                      secondChild: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.check_circle_outline,
                                                    size: 18, color: Colors.green.shade800),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Ответ:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green.shade900,
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: const Icon(Icons.close, size: 16),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () => controller.toggleAnswer(index),
                                                  tooltip: 'Скрыть ответ',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              riddle.answer,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.isLoading ? null : () => controller.fetchRiddles(),
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Новые загадки'),
      ),
    );
  }
}
