import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/history_controller.dart';
import '../widgets/api_key_banner.dart';
import '../widgets/error_view.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryController controller;
  final VoidCallback onOpenSettings;

  const HistoryScreen({
    super.key,
    required this.controller,
    required this.onOpenSettings,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    _searchController.text = widget.controller.currentQuery;
    if (widget.controller.events.isEmpty) {
      widget.controller.search(widget.controller.currentQuery);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _submitSearch([String? term]) {
    final query = term ?? _searchController.text;
    if (query.trim().isNotEmpty) {
      _searchController.text = query.trim();
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
          'Исторические события',
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск события (space, computer, flight)...',
                      prefixIcon: const Icon(Icons.history_edu),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
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
                  child: const Text('Поиск'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: HistoryController.suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final topic = HistoryController.suggestions[index];
                return ActionChip(
                  label: Text(topic),
                  onPressed: () => _submitSearch(topic),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.events.isEmpty && controller.errorMessage != null
                    ? ErrorView(
                        message: controller.errorMessage!,
                        onRetry: () => _submitSearch(),
                      )
                    : controller.events.isEmpty
                        ? Center(
                            child: Text(
                              'По запросу ничего не найдено',
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.events.length,
                            itemBuilder: (context, index) {
                              final ev = controller.events[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.tertiaryContainer.withAlpha(120),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              ev.formattedDate,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: theme.colorScheme.tertiary,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, size: 18),
                                            tooltip: 'Копировать',
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                text: '[${ev.formattedDate}] ${ev.event}',
                                              ));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Событие скопировано'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        ev.event,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
