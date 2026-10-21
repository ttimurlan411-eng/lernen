import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/word_search.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/level_tile.dart';
import '../widgets/loading_view.dart';
import '../widgets/state_views.dart';

/// The dashboard: an overview of the dataset, the CEFR levels and quick
/// access to the vocabulary, the favorites and the settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.onOpenVocabulary,
    required this.onOpenFavorites,
    required this.onOpenSettings,
  });

  final AppState state;
  final VoidCallback onOpenVocabulary;
  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([state, state.favorites]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.settings,
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody(context, l10n)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    switch (state.status) {
      case LoadStatus.loading:
        return LoadingView(message: l10n.loading);
      case LoadStatus.error:
        return ErrorView(
          onRetry: state.initialize,
          message: state.errorMessage,
        );
      case LoadStatus.ready:
        break;
    }

    final counts = WordSearch.countsByLevel(state.words);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: <Widget>[
        Text(
          l10n.homeSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        _OverviewCard(
          wordCount: state.words.length,
          label: l10n.totalWords,
          verbLabel: l10n.verbCount(state.verbs.length),
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: l10n.levels),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 116,
          children: <Widget>[
            for (final level in WordSearch.levels)
              LevelTile(
                level: level,
                wordCount: counts[level] ?? 0,
                countLabel: l10n.wordCount(counts[level] ?? 0),
                onTap: () => _openLevel(level),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: l10n.quickAccess),
        const SizedBox(height: 10),
        _QuickAccessCard(
          key: const Key('home-words'),
          icon: Icons.menu_book_rounded,
          title: l10n.browseAllWords,
          subtitle: l10n.browseAllWordsSubtitle,
          onTap: onOpenVocabulary,
        ),
        const SizedBox(height: 10),
        _QuickAccessCard(
          key: const Key('home-favorites'),
          icon: Icons.favorite_rounded,
          title: l10n.favorites,
          subtitle: l10n.favoritesSubtitle,
          trailing: state.favorites.count.toString(),
          onTap: onOpenFavorites,
        ),
      ],
    );
  }

  void _openLevel(String level) {
    state.vocabulary.setLevel(level);
    onOpenVocabulary();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// The hero card summarising the dataset.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.wordCount,
    required this.label,
    required this.verbLabel,
  });

  final int wordCount;
  final String label;
  final String verbLabel;

  @override
  Widget build(BuildContext context) {
    return SoftContainer(
      gradient: AppTheme.brandGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$wordCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.auto_stories_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  verbLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable card offering quick access to another screen.
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trailing!,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
        ],
      ),
    );
  }
}
