import '../models/word.dart';

/// Filters [Word]s by CEFR level and a free-text query.
///
/// The query is matched case-insensitively against the English, German and
/// Russian fields; nothing is merged or dropped from the source data.
class WordSearch {
  const WordSearch._();

  static const List<String> levels = <String>['A1', 'A2', 'B1', 'B2'];

  static List<Word> apply(
    List<Word> words, {
    String? level,
    String query = '',
    Set<String>? favoriteIds,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return words
        .where((word) {
          if (level != null && level.isNotEmpty && word.level != level) {
            return false;
          }
          if (favoriteIds != null && !favoriteIds.contains(word.id)) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return word.english.toLowerCase().contains(normalizedQuery) ||
              word.german.toLowerCase().contains(normalizedQuery) ||
              word.russian.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  /// Counts how many words each level of [levels] contains.
  static Map<String, int> countsByLevel(List<Word> words) {
    final counts = <String, int>{for (final level in levels) level: 0};
    for (final word in words) {
      counts[word.level] = (counts[word.level] ?? 0) + 1;
    }
    return counts;
  }
}
