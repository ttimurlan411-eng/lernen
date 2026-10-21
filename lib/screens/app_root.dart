import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'vocabulary_screen.dart';

/// Hosts the bottom navigation shell with the main screens of the app.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.state});

  final AppState state;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _index = 0;

  void _select(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          HomeScreen(
            state: widget.state,
            onOpenVocabulary: () => _select(1),
            onOpenFavorites: () => _select(2),
            onOpenSettings: () => _select(3),
          ),
          VocabularyScreen(state: widget.state),
          FavoritesScreen(state: widget.state),
          SettingsScreen(state: widget.state),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        backgroundColor: AppTheme.surface,
        indicatorColor: const Color(0xFFE6E9FB),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(
              Icons.home_rounded,
              color: AppTheme.primary,
            ),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(
              Icons.menu_book_rounded,
              color: AppTheme.primary,
            ),
            label: l10n.navWords,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite, color: AppTheme.primary),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(
              Icons.settings_rounded,
              color: AppTheme.primary,
            ),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
