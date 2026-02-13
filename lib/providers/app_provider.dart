import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'dart:convert';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final _apiService = ApiService();
  
  List<Book> _liveBooks = [];
  List<Book> get liveBooks => _liveBooks;
  bool _isLoadingBooks = false;
  bool get isLoadingBooks => _isLoadingBooks;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // AI Reading State
  bool _isAiLoading = false;
  bool get isAiLoading => _isAiLoading;
  double _aiLoadingProgress = 0.0;
  double get aiLoadingProgress => _aiLoadingProgress;
  bool _runInBackground = false;
  bool get runInBackground => _runInBackground;

  void setAiLoading(bool loading) {
    _isAiLoading = loading;
    if (!loading) _aiLoadingProgress = 0.0;
    notifyListeners();
  }

  void setAiProgress(double progress) {
    _aiLoadingProgress = progress;
    notifyListeners();
  }

  void setRunInBackground(bool value) {
    _runInBackground = value;
    notifyListeners();
  }

  AppProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Auto theme based on time if not manually set
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;
    _isDarkMode = _prefs.getBool('isDarkMode') ?? isNight;
    
    _isGuest = _prefs.getBool('isGuest') ?? true;
    _userName = _prefs.getString('userName') ?? 'ضيف';
    _userEmail = _prefs.getString('userEmail') ?? 'guest@moujaz.app';
    _userPassword = _prefs.getString('userPassword') ?? '';
    
    // Load favorites
    _favoriteBookIds.addAll(_prefs.getStringList('favorites') ?? []);
    
    // Load audio progress
    final progressJson = _prefs.getString('audioProgress') ?? '{}';
    _audioProgress = Map<String, int>.from(json.decode(progressJson));

    // Load designs
    _isModernDesign = _prefs.getBool('isModernDesign') ?? true;
    
    fetchBooks(silent: true); // Silently load in background
    notifyListeners();
  }

  // Design Theme Management
  bool _isModernDesign = true;
  bool get isModernDesign => _isModernDesign;

  void toggleDesign() {
    _isModernDesign = !_isModernDesign;
    _prefs.setBool('isModernDesign', _isModernDesign);
    notifyListeners();
  }

  Future<void> fetchBooks({bool forceRefresh = false, bool silent = false}) async {
    if (_isLoadingBooks) return;
    // Remove cache check to always fetch fresh data or handle better cache logic
    // if (!forceRefresh && _liveBooks.isNotEmpty) return; 

    if (!silent) {
      _isLoadingBooks = true;
      _errorMessage = null;
      notifyListeners();
    }
    
    try {
      final books = await _apiService.fetchBooks();
      _liveBooks = books;
    } catch (e) {
      if (!silent) _errorMessage = "فشل الاتصال بالخادم: $e";
      debugPrint("Error fetching books: $e");
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 1. Dark Mode
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // 2. User State
  bool _isGuest = true;
  String _userName = 'ضيف';
  String _userEmail = 'guest@moujaz.app';
  String _userPassword = '';

  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPassword => _userPassword;

  void loginAsUser(String name, String email, {String password = ''}) {
    _isGuest = false;
    _userName = name;
    _userEmail = email;
    _userPassword = password;
    _prefs.setBool('isGuest', false);
    _prefs.setString('userName', name);
    _prefs.setString('userEmail', email);
    if (password.isNotEmpty) _prefs.setString('userPassword', password);
    notifyListeners();
  }

  void logout() {
    _isGuest = true;
    _userName = 'ضيف';
    _userEmail = 'guest@moujaz.app';
    _prefs.setBool('isGuest', true);
    _prefs.remove('userName');
    _prefs.remove('userEmail');
    _prefs.remove('userPassword');
    notifyListeners();
  }

  // 3 & 4. Playlists, Downloads, Favorites
  final List<String> _downloadedBookIds = [];
  final List<Book> _playlist = [];
  final List<String> _favoriteBookIds = [];

  List<String> get downloadedBookIds => _downloadedBookIds;
  List<Book> get playlist => _playlist;
  List<String> get favoriteBookIds => _favoriteBookIds;

  void toggleFavorite(String bookId) {
    if (_favoriteBookIds.contains(bookId)) {
      _favoriteBookIds.remove(bookId);
    } else {
      _favoriteBookIds.add(bookId);
    }
    _prefs.setStringList('favorites', _favoriteBookIds);
    notifyListeners();
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

  // 5. Audio Progress Persistence
  Map<String, int> _audioProgress = {}; // bookId -> seconds

  int getBookProgress(String bookId) => _audioProgress[bookId] ?? 0;

  void saveBookProgress(String bookId, int seconds) {
    _audioProgress[bookId] = seconds;
    _prefs.setString('audioProgress', json.encode(_audioProgress));
  }

  // 6. Navigation Management
  int _currentMainTabIndex = 0;
  int get currentMainTabIndex => _currentMainTabIndex;

  void setMainTab(int index) {
    _currentMainTabIndex = index;
    notifyListeners();
  }

  int _libraryInitialTab = 0;
  int get libraryInitialTab => _libraryInitialTab;
  
  void setLibraryTab(int index) {
    _libraryInitialTab = index;
    notifyListeners();
  }

  // 8 & 9. Streaks & Challenges
  int streak = 5;
  double weeklyGoalProgress = 0.65;

  // 5. AI Assistant Messages
  final List<Map<String, String>> chatMessages = [
    {"role": "ai", "content": "أهلاً بك! أنا مساعد موجز الذكي. كيف يمكنني مساعدتك اليوم في رحلتك المعرفية؟"}
  ];

  void sendMessage(String text) {
    chatMessages.add({"role": "user", "content": text});
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () {
      chatMessages.add({"role": "ai", "content": "أهلاً بك! بناءً على سؤالك، هذا الكتاب يتناول مفهوم 'التركيز' بعمق. هل تود معرفة الفصول التي تركز على الإنتاجية؟"});
      notifyListeners();
    });
  }

  // 7. AI Voice
  bool useAiVoice = false;
  void toggleVoiceMode() {
    useAiVoice = !useAiVoice;
    notifyListeners();
  }

  int communityMembers = 1240;

  bool _remindersEnabled = true;
  bool get remindersEnabled => _remindersEnabled;
  void toggleReminders() {
    _remindersEnabled = !_remindersEnabled;
    notifyListeners();
  }

  // Global Audio/TTS Session Management
  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  Future<void> stopAllAudio() async {
    _isAiLoading = false;
    _activeSessionId = "STOP_${DateTime.now().millisecondsSinceEpoch}";
    notifyListeners();
  }

  void setActiveSessionId(String id) {
    _activeSessionId = id;
    notifyListeners();
  }
}
