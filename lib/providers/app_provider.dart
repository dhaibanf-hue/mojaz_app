import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final _apiService = ApiService();
  
  List<Book> _liveBooks = [];
  List<Book> get liveBooks => _liveBooks;
  bool _isLoadingBooks = false;
  bool get isLoadingBooks => _isLoadingBooks;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Global Playback State
  Book? _currentPlayingBook;
  Book? get currentPlayingBook => _currentPlayingBook;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  bool _showMiniPlayer = false;
  bool get showMiniPlayer => _showMiniPlayer;

  void playBook(Book book) {
    _currentPlayingBook = book;
    _isPlaying = true;
    _showMiniPlayer = true;
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stopPlayback() {
    _isPlaying = false;
    _showMiniPlayer = false;
    // Keep _currentPlayingBook so we can resume if needed, 
    // but the UI (MiniPlayer) will disappear.
    notifyListeners();
  }

  void hideMiniPlayer() {
    _showMiniPlayer = false;
    _isPlaying = false;
    notifyListeners();
  }

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
    
    // Load last tab
    _currentMainTabIndex = _prefs.getInt('lastMainTab') ?? 0;

    // Load points
    _points = _prefs.getInt('points') ?? 0;

    // Load interests
    _readingGoal = _prefs.getString('readingGoal') ?? '';
    _selectedInterests = _prefs.getStringList('selectedInterests') ?? [];
    _learningStyle = _prefs.getString('learningStyle') ?? '';
    _dailyTime = _prefs.getInt('dailyTime') ?? 0;

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

  List<String> get completedBookIds => _audioProgress.entries
      .where((entry) => entry.value >= 850)
      .map((entry) => entry.key)
      .toList();

  /// Total listening time in minutes (sum of all progress entries divided by 60)
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

  // 5. Audio Progress Persistence
  Map<String, int> _audioProgress = {}; // bookId -> seconds

  int getBookProgress(String bookId) => _audioProgress[bookId] ?? 0;

  void saveBookProgress(String bookId, int seconds) {
    _audioProgress[bookId] = seconds;
    _prefs.setString('audioProgress', json.encode(_audioProgress));
    
    // Cloud Sync
    _apiService.syncProgress(bookId, seconds);
    
    // Logic for awarding points (e.g., if completed)
    if (seconds >= 850) { // Assuming book is ~15 min
       updatePoints(10); // Award 10 points for completion
    }
  }

  void updatePoints(int extraPoints) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    // Update locally first
    _points += extraPoints;
    _prefs.setInt('points', _points);
    notifyListeners();

    if (userId != null) {
      try {
        await client.rpc('increment_points', params: {'user_id': userId, 'amount': extraPoints});
      } catch (e) {
        debugPrint("Point sync error: $e");
      }
    }
  }

  // Points
  int _points = 0;
  int get points => _points;

  // Interests Data
  String _readingGoal = '';
  List<String> _selectedInterests = [];
  String _learningStyle = '';
  int _dailyTime = 0;

  String get readingGoal => _readingGoal;
  List<String> get selectedInterests => _selectedInterests;
  String get learningStyle => _learningStyle;
  int get dailyTime => _dailyTime;

  void saveInterestData(String goal, List<String> interests, String style, int time) {
    _readingGoal = goal;
    _selectedInterests = interests;
    _learningStyle = style;
    _dailyTime = time;

    _prefs.setString('readingGoal', goal);
    _prefs.setStringList('selectedInterests', interests);
    _prefs.setString('learningStyle', style);
    _prefs.setInt('dailyTime', time);
    notifyListeners();
  }

  // 6. Navigation Management
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

  int get communityMembers {
    // محاكاة لنمو حقيقي بعدد الأعضاء يعتمد على الأيام منذ الإطلاق + نقاط المستخدم نفسه
    final daysSinceLaunch = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    return 1240 + daysSinceLaunch + (_points ~/ 50);
  }
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
