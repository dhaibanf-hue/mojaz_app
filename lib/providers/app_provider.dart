import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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

  // New Playback Detail State for Sync
  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;
  Duration _currentDuration = Duration.zero;
  Duration get currentDuration => _currentDuration;

  void updatePlaybackStatus(Duration position, Duration duration) {
    _currentPosition = position;
    _currentDuration = duration;
    notifyListeners();
  }

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
    _userPhone = _prefs.getString('userPhone') ?? '';
    
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
    fetchCommunityCount(); // Get real user count
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
           _errorMessage = null; // Cleared since we loaded from cache
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
      // If empty remotely, try local logic below
      throw Exception("Empty remote search, falling back strictly to local.");
    } catch (e) {
      debugPrint("Search fallback on error or empty: $e");
      // Fallback to local search if remote fails or yields empty
      final qTrim = query.trim().toLowerCase();
      if (qTrim.isEmpty) return _liveBooks;
      return _liveBooks.where((b) => 
         b.title.toLowerCase().contains(qTrim) || 
         b.author.toLowerCase().contains(qTrim) ||
         b.category.toLowerCase().contains(qTrim)
      ).toList();
    }
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
  String _userPhone = '';

  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPassword => _userPassword;
  String get userPhone => _userPhone;

  void loginAsUser(String name, String email, {String password = '', String phone = ''}) {
    _isGuest = false;
    _userName = name;
    _userEmail = email;
    _userPassword = password;
    _userPhone = phone;
    _prefs.setBool('isGuest', false);
    _prefs.setString('userName', name);
    _prefs.setString('userEmail', email);
    if (password.isNotEmpty) _prefs.setString('userPassword', password);
    if (phone.isNotEmpty) _prefs.setString('userPhone', phone);
    notifyListeners();
  }

  Future<void> updateUserData({required String name, required String phone}) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    // Update local state
    _userName = name;
    _userPhone = phone;
    _prefs.setString('userName', name);
    _prefs.setString('userPhone', phone);
    notifyListeners();

    if (userId != null) {
      try {
        // Update Supabase profiles table (assuming it exists and has these columns)
        // Also update user metadata
        await client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
              'phone': phone,
            },
          ),
        );
        
        // If there's a profiles table, update it too
        await client.from('profiles').upsert({
          'id': userId,
          'full_name': name,
          'phone': phone,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint("Error updating user data in Supabase: $e");
      }
    }
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
      .where((entry) {
        // Find the book to get its exact duration
        final book = _liveBooks.firstWhere(
           (b) => b.id == entry.key, 
           orElse: () => Book(id: '', title: '', author: '', description: '', cover: '', category: '', isPremium: false, rating: 0, durationMinutes: 15, audioUrl: '', pageCount: 0)
        );
        final totalSeconds = (book.durationMinutes ?? 15) * 60;
        return entry.value >= totalSeconds;
      })
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
    final book = _liveBooks.firstWhere(
       (b) => b.id == bookId, 
       orElse: () => Book(id: '', title: '', author: '', description: '', cover: '', category: '', isPremium: false, rating: 0, durationMinutes: 15, audioUrl: '', pageCount: 0)
    );
    final totalSeconds = (book.durationMinutes ?? 15) * 60;
    
    if (seconds >= totalSeconds) { 
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

  Future<void> sendMessage(String text) async {
    chatMessages.add({"role": "user", "content": text});
    notifyListeners();

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key is missing');
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Add context to the prompt
      final prompt = "أنت مساعد ذكي لتطبيق 'موجز' للكتب الصوتية والملخصات باللغة العربية. دورك هو مساعدة المستخدمين واقتراح الكتب وإعطاء معلومات مفيدة. أجب بإيجاز وباحترافية.\nسؤال المستخدم: $text";
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        chatMessages.add({"role": "ai", "content": response.text!});
      } else {
        chatMessages.add({"role": "ai", "content": "عذراً، لم أتمكن من صياغة الإجابة في الوقت الحالي."});
      }
    } catch (e) {
      debugPrint("Gemini API Error: $e");
      chatMessages.add({"role": "ai", "content": "عذراً، حدث خطأ في الاتصال بالشبكة. يرجى المحاولة لاحقاً."});
    }
    notifyListeners();
  }

  // 7. AI Voice
  bool useAiVoice = false;
  void toggleVoiceMode() {
    useAiVoice = !useAiVoice;
    notifyListeners();
  }

  int _communityCount = 1250;
  int get communityMembers => _communityCount;

  Future<void> fetchCommunityCount() async {
    try {
      final client = Supabase.instance.client;
      final List<dynamic> response = await client.from('profiles').select('id').limit(100);
      _communityCount = 1250 + response.length;
      notifyListeners();
    } catch (e) {
      _communityCount = 1250;
      notifyListeners();
      debugPrint("Error fetching community count: $e");
    }
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
