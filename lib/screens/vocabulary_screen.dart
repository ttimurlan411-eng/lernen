import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/word_search.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/state_views.dart';
import '../widgets/word_card.dart';
import '../widgets/word_details_sheet.dart';

/// The searchable vocabulary: a search field, a level filter and the list of
/// matching words.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key, required this.state});

  final AppState state;

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.state.vocabulary.query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.state.vocabulary.clearQuery();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        widget.state,
        widget.state.favorites,
        widget.state.vocabulary,
      ]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.vocabulary)),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.state.vocabulary.setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: widget.state.vocabulary.hasQuery
                          ? IconButton(
                              tooltip: l10n.clearSearch,
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                _LevelFilter(
                  selected: widget.state.vocabulary.level,
                  onSelected: widget.state.vocabulary.setLevel,
                ),
                const SizedBox(height: 4),
                Expanded(child: _buildBody(l10n)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final status = widget.state.status;
    if (status == LoadStatus.loading) {
      return LoadingView(message: l10n.loading);
    }
    if (status == LoadStatus.error) {
      return ErrorView(
        onRetry: widget.state.initialize,
        message: widget.state.errorMessage,
      );
    }

    final results = WordSearch.apply(
      widget.state.words,
      level: widget.state.vocabulary.level,
      query: widget.state.vocabulary.query,
    );
    if (results.isEmpty) {
      return EmptyView(
        title: l10n.noResults,
        subtitle: l10n.noResultsSubtitle,
        icon: Icons.search_off_rounded,
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.wordCount(results.length),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final word = results[index];
              final isFav = widget.state.favorites.contains(word.id);
              return WordCard(
                word: word,
                isFavorite: isFav,
                onFavoriteToggle: () => widget.state.favorites.toggle(word.id),
                onTap: () => WordDetailsSheet.show(
                  context,
                  word: word,
                  isFavorite: isFav,
                  onFavoriteToggle: () =>
                      widget.state.favorites.toggle(word.id),
                  speech: widget.state.speech,
                  verb: widget.state.verbFor(word),
                ),
                speech: widget.state.speech,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LevelFilter extends StatelessWidget {
  const _LevelFilter({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(l10n.allLevels),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: selected == null ? Colors.white : AppTheme.textPrimary,
              ),
              showCheckmark: false,
            ),
          ),
          for (final level in WordSearch.levels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(level),
                selected: selected == level,
                onSelected: (_) => onSelected(level),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected == level
                      ? Colors.white
                      : AppTheme.textPrimary,
                ),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}
