import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles book fetching, searching, favorites, downloads, playlists, and audio progress.
class BooksProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final _apiService = ApiService();

  List<Book> _liveBooks = [];
  List<Book> get liveBooks => _liveBooks;
  bool _isLoadingBooks = false;
  bool get isLoadingBooks => _isLoadingBooks;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Playlists, Downloads, Favorites
  final List<String> _downloadedBookIds = [];
  final List<Book> _playlist = [];
  final List<String> _favoriteBookIds = [];

  List<String> get downloadedBookIds => _downloadedBookIds;
  List<Book> get playlist => _playlist;
  List<String> get favoriteBookIds => _favoriteBookIds;

  // Audio Progress Persistence
  Map<String, int> _audioProgress = {}; // bookId -> seconds

  // Callback to award points on book completion (set by parent to connect with AuthProvider)
  void Function(int points)? onPointsAwarded;

  BooksProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Load favorites
    _favoriteBookIds.addAll(_prefs.getStringList('favorites') ?? []);

    // Load audio progress
    final progressJson = _prefs.getString('audioProgress') ?? '{}';
    _audioProgress = Map<String, int>.from(json.decode(progressJson));

    // Load last tab
    _currentMainTabIndex = _prefs.getInt('lastMainTab') ?? 0;

    fetchBooks(silent: true);
    notifyListeners();
  }

  Future<void> fetchBooks({bool forceRefresh = false, bool silent = false}) async {
    if (_isLoadingBooks) return;

    if (!silent) {
      _isLoadingBooks = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final books = await _apiService.fetchBooks();
      _liveBooks = books;
      // Cache the books for offline usage
      final booksJsonList = books.map((b) => b.toMap()).toList();
      _prefs.setString('cachedRemoteBooks', json.encode(booksJsonList));
    } catch (e) {
      if (!silent) _errorMessage = "فشل الاتصال بالخادم: $e";
      debugPrint("Error fetching books: $e. Loading from cache...");
      // Fallback to cache
      final cachedString = _prefs.getString('cachedRemoteBooks');
      if (cachedString != null) {
        try {
           final List<dynamic> decoded = json.decode(cachedString);
           _liveBooks = decoded.map((map) => Book.fromMap(map)).toList();
           _errorMessage = null;
        } catch (parseErr) {
           debugPrint("Error parsing cached books: $parseErr");
        }
      }
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<List<Book>> searchBooks(String query) async {
    try {
      final remoteResults = await _apiService.searchBooks(query);
      if (remoteResults.isNotEmpty) return remoteResults;
      throw Exception("Empty remote search, falling back strictly to local.");
    } catch (e) {
      debugPrint("Search fallback on error or empty: $e");
      final qTrim = query.trim().toLowerCase();
      if (qTrim.isEmpty) return _liveBooks;
      return _liveBooks.where((b) =>
         b.title.toLowerCase().contains(qTrim) ||
         b.author.toLowerCase().contains(qTrim) ||
         b.category.toLowerCase().contains(qTrim)
      ).toList();
    }
  }

  List<String> get completedBookIds => _audioProgress.entries
      .where((entry) {
        final book = _liveBooks.firstWhere(
           (b) => b.id == entry.key,
           orElse: () => Book(id: '', title: '', author: '', description: '', cover: '', category: '', isPremium: false, rating: 0, durationMinutes: 15, audioUrl: '', pageCount: 0)
        );
        final totalSeconds = (book.durationMinutes ?? 15) * 60;
        return entry.value >= totalSeconds;
      })
      .map((entry) => entry.key)
      .toList();

  /// Total listening time in minutes
  int get totalListeningMinutes {
    final totalSeconds = _audioProgress.values.fold<int>(0, (sum, secs) => sum + secs);
    return (totalSeconds / 60).ceil();
  }

  bool isFavorite(String bookId) => _favoriteBookIds.contains(bookId);

  void toggleFavorite(Book book) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    if (_favoriteBookIds.contains(book.id)) {
      _favoriteBookIds.remove(book.id);
      if (userId != null) {
        await client.from('favorites').delete().eq('user_id', userId).eq('book_id', book.id);
      }
    } else {
      _favoriteBookIds.add(book.id);
      if (userId != null) {
        await client.from('favorites').upsert({'user_id': userId, 'book_id': book.id});
      }
    }
    _prefs.setStringList('favorites', _favoriteBookIds);
    notifyListeners();
  }

  void markAsDownloaded(String bookId) {
    if (!_downloadedBookIds.contains(bookId)) {
      _downloadedBookIds.add(bookId);
      notifyListeners();
    }
  }

  void toggleDownload(String bookId) {
    if (_downloadedBookIds.contains(bookId)) {
      _downloadedBookIds.remove(bookId);
    } else {
      _downloadedBookIds.add(bookId);
    }
    notifyListeners();
  }

  void addToPlaylist(Book book) {
    if (!_playlist.any((b) => b.id == book.id)) {
      _playlist.add(book);
      notifyListeners();
    }
  }

  int getBookProgress(String bookId) => _audioProgress[bookId] ?? 0;

  void saveBookProgress(String bookId, int seconds) {
    _audioProgress[bookId] = seconds;
    _prefs.setString('audioProgress', json.encode(_audioProgress));

    // Cloud Sync
    _apiService.syncProgress(bookId, seconds);

    // Logic for awarding points
    final book = _liveBooks.firstWhere(
       (b) => b.id == bookId,
       orElse: () => Book(id: '', title: '', author: '', description: '', cover: '', category: '', isPremium: false, rating: 0, durationMinutes: 15, audioUrl: '', pageCount: 0)
    );
    final totalSeconds = (book.durationMinutes ?? 15) * 60;

    if (seconds >= totalSeconds) {
       onPointsAwarded?.call(10);
    }
  }

  // Navigation Management
  int _currentMainTabIndex = 0;
  int get currentMainTabIndex => _currentMainTabIndex;

  void setMainTab(int index) {
    _currentMainTabIndex = index;
    _prefs.setInt('lastMainTab', index);
    notifyListeners();
  }

  int _libraryInitialTab = 0;
  int get libraryInitialTab => _libraryInitialTab;

  void setLibraryTab(int index) {
    _libraryInitialTab = index;
    notifyListeners();
  }
}
