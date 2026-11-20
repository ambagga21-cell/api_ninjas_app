import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/facts_controller.dart';
import '../widgets/api_key_banner.dart';
import '../widgets/error_view.dart';

class FactsScreen extends StatefulWidget {
  final FactsController controller;
  final VoidCallback onOpenSettings;

  const FactsScreen({
    super.key,
    required this.controller,
    required this.onOpenSettings,
  });

  @override
  State<FactsScreen> createState() => _FactsScreenState();
}

class _FactsScreenState extends State<FactsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    if (widget.controller.facts.isEmpty) {
      widget.controller.fetchFacts();
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

  void _copyFact(String fact) {
    Clipboard.setData(ClipboardData(text: fact));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Факт скопирован'),
        duration: Duration(seconds: 2),
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
          'Удивительные факты',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить факты',
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading ? null : () => controller.fetchFacts(),
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
                : controller.facts.isEmpty && controller.errorMessage != null
                    ? ErrorView(
                        message: controller.errorMessage!,
                        onRetry: () => controller.fetchFacts(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchFacts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.facts.length,
                          itemBuilder: (context, index) {
                            final fact = controller.facts[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '#${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fact.fact,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              height: 1.45,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.copy_rounded, size: 18),
                                              tooltip: 'Скопировать факт',
                                              onPressed: () => _copyFact(fact.fact),
                                            ),
                                          ),
                                        ],
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
        onPressed: controller.isLoading ? null : () => controller.fetchFacts(),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Сгенерировать еще'),
      ),
    );
  }
}
