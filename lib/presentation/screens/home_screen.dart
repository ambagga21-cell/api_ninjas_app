import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../controllers/quotes_controller.dart';
import '../controllers/riddles_controller.dart';
import '../controllers/facts_controller.dart';
import '../controllers/dictionary_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/settings_controller.dart';
import 'quotes_screen.dart';
import 'riddles_screen.dart';
import 'facts_screen.dart';
import 'dictionary_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Контроллеры получены через GetIt (sl)
  late final QuotesController _quotesController;
  late final RiddlesController _riddlesController;
  late final FactsController _factsController;
  late final DictionaryController _dictionaryController;
  late final HistoryController _historyController;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _quotesController = sl<QuotesController>();
    _riddlesController = sl<RiddlesController>();
    _factsController = sl<FactsController>();
    _dictionaryController = sl<DictionaryController>();
    _historyController = sl<HistoryController>();
    _settingsController = sl<SettingsController>();
  }

  @override
  void dispose() {
    _quotesController.dispose();
    _riddlesController.dispose();
    _factsController.dispose();
    _dictionaryController.dispose();
    _historyController.dispose();
    // settingsController is singleton
    super.dispose();
  }

  void _navigateToSettings() {
    setState(() {
      _currentIndex = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      QuotesScreen(
        controller: _quotesController,
        onOpenSettings: _navigateToSettings,
      ),
      RiddlesScreen(
        controller: _riddlesController,
        onOpenSettings: _navigateToSettings,
      ),
      FactsScreen(
        controller: _factsController,
        onOpenSettings: _navigateToSettings,
      ),
      DictionaryScreen(
        controller: _dictionaryController,
        onOpenSettings: _navigateToSettings,
      ),
      HistoryScreen(
        controller: _historyController,
        onOpenSettings: _navigateToSettings,
      ),
      SettingsScreen(
        controller: _settingsController,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        if (isWide) {
          // Десктопный режим с NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFF5B4DFF),
                      child: Icon(Icons.hub_outlined, color: Colors.white),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.format_quote_outlined),
                      selectedIcon: Icon(Icons.format_quote),
                      label: Text('Цитаты'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.extension_outlined),
                      selectedIcon: Icon(Icons.extension),
                      label: Text('Загадки'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.lightbulb_outline),
                      selectedIcon: Icon(Icons.lightbulb),
                      label: Text('Факты'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: Text('Словарь'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_edu_outlined),
                      selectedIcon: Icon(Icons.history_edu),
                      label: Text('История'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Настройки'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Мобильный режим с BottomNavigationBar
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.format_quote_outlined),
                selectedIcon: Icon(Icons.format_quote),
                label: 'Цитаты',
              ),
              NavigationDestination(
                icon: Icon(Icons.extension_outlined),
                selectedIcon: Icon(Icons.extension),
                label: 'Загадки',
              ),
              NavigationDestination(
                icon: Icon(Icons.lightbulb_outline),
                selectedIcon: Icon(Icons.lightbulb),
                label: 'Факты',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Словарь',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_edu_outlined),
                selectedIcon: Icon(Icons.history_edu),
                label: 'История',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Настройки',
              ),
            ],
          ),
        );
      },
    );
  }
}
