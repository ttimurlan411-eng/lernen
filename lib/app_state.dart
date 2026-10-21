import 'package:flutter/foundation.dart';

import '../models/verb_forms.dart';
import '../models/word.dart';
import '../services/dictionary_data_service.dart';
import '../services/favorites_repository.dart';
import '../services/settings_repository.dart';
import '../services/speech_service.dart';
import '../services/vocabulary_controller.dart';

enum LoadStatus { loading, ready, error }

/// Top-level application state: dataset loading, favorites and settings.
class AppState extends ChangeNotifier {
  AppState({
    DictionaryDataService? dataService,
    FavoritesRepository? favoritesRepository,
    SettingsRepository? settingsRepository,
    SpeechService? speechService,
  }) : _dataService = dataService ?? DictionaryDataService(),
       _favorites = FavoritesController(
         favoritesRepository ?? FavoritesRepository(),
       ),
       settings = SettingsController(
         settingsRepository ?? SettingsRepository(),
       ),
       speech = speechService ?? SpeechService() {
    settings.addListener(_applySpeechSettings);
  }

  final DictionaryDataService _dataService;
  final FavoritesController _favorites;
  final SpeechService speech;

  /// User preferences (interface language, speech).
  final SettingsController settings;

  /// Search query and level filter of the vocabulary screen.
  final VocabularyController vocabulary = VocabularyController();

  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;
  List<Word> _words = const <Word>[];
  List<VerbForms> _verbs = const <VerbForms>[];
  Map<String, VerbForms> _verbsByWordId = const <String, VerbForms>{};

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Word> get words => _words;
  List<VerbForms> get verbs => _verbs;
  FavoritesController get favorites => _favorites;

  /// Returns the verb record attached to [word], if the dataset contains one.
  VerbForms? verbFor(Word word) => _verbsByWordId[word.id];

  /// Pushes the current speech preferences into the speech engine.
  void _applySpeechSettings() {
    speech.enabled = settings.speechEnabled;
    speech.rate = settings.speechRate;
  }

  Future<void> initialize() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      // The interface language is loaded first so the UI never flashes in the
      // wrong language while the (much larger) dataset is read.
      await settings.load();
      _applySpeechSettings();
      final data = await _dataService.load();
      _words = data.words;
      _verbs = data.verbs;
      _verbsByWordId = data.verbsByWordId();
      await _favorites.load();
      _status = LoadStatus.ready;
    } on DataLoadException catch (error) {
      _errorMessage = error.message;
      _status = LoadStatus.error;
    } catch (error) {
      _errorMessage = error.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    settings.removeListener(_applySpeechSettings);
    super.dispose();
  }
}
