import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/quotes_controller.dart';
import '../widgets/api_key_banner.dart';
import '../widgets/error_view.dart';

class QuotesScreen extends StatefulWidget {
  final QuotesController controller;
  final VoidCallback onOpenSettings;

  const QuotesScreen({
    super.key,
    required this.controller,
    required this.onOpenSettings,
  });

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    if (widget.controller.quotes.isEmpty) {
      widget.controller.fetchQuotes();
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

  void _copyToClipboard(String text, String author) {
    Clipboard.setData(ClipboardData(text: '"$text" — $author'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Цитата скопирована в буфер обмена'),
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
          'Цитаты & Мудрость',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить цитаты',
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading ? null : () => controller.fetchQuotes(),
          ),
        ],
      ),
      body: Column(
        children: [
          ApiKeyBanner(
            onOpenSettings: widget.onOpenSettings,
            isDemo: controller.isDemoData,
          ),
          // Выбор категории
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: QuotesController.availableCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = QuotesController.availableCategories[index];
                final isSelected = controller.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat == 'all' ? 'Все категории' : cat,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.setCategory(cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Список цитат или индикатор загрузки
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.quotes.isEmpty && controller.errorMessage != null
                    ? ErrorView(
                        message: controller.errorMessage!,
                        onRetry: () => controller.fetchQuotes(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchQuotes(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.quotes.length,
                          itemBuilder: (context, index) {
                            final quote = controller.quotes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.format_quote_rounded,
                                          size: 32,
                                          color: theme.colorScheme.primary.withAlpha(150),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primaryContainer.withAlpha(120),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            quote.category.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '«${quote.quote}»',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 18,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            quote.author,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Копировать',
                                          icon: const Icon(Icons.copy_rounded, size: 18),
                                          onPressed: () => _copyToClipboard(
                                            quote.quote,
                                            quote.author,
                                          ),
                                        ),
                                      ],
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
        onPressed: controller.isLoading ? null : () => controller.fetchQuotes(),
        icon: const Icon(Icons.casino_outlined),
        label: const Text('Случайные цитаты'),
      ),
    );
  }
}
