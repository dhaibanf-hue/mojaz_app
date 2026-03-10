import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Handles global playback state, AI loading, voice mode, and chat.
class AudioPlayerProvider extends ChangeNotifier {
  // Global Playback State
  Book? _currentPlayingBook;
  Book? get currentPlayingBook => _currentPlayingBook;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  bool _showMiniPlayer = false;
  bool get showMiniPlayer => _showMiniPlayer;

  // Playback Detail State for Sync
  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;
  Duration _currentDuration = Duration.zero;
  Duration get currentDuration => _currentDuration;

  // AI Reading State
  bool _isAiLoading = false;
  bool get isAiLoading => _isAiLoading;
  double _aiLoadingProgress = 0.0;
  double get aiLoadingProgress => _aiLoadingProgress;
  bool _runInBackground = false;
  bool get runInBackground => _runInBackground;

  // AI Voice
  bool useAiVoice = false;

  // Global Audio/TTS Session Management
  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  // AI Assistant Messages
  final List<Map<String, String>> chatMessages = [
    {"role": "ai", "content": "أهلاً بك! أنا مساعد موجز الذكي. كيف يمكنني مساعدتك اليوم في رحلتك المعرفية؟"}
  ];

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
    notifyListeners();
  }

  void hideMiniPlayer() {
    _showMiniPlayer = false;
    _isPlaying = false;
    notifyListeners();
  }

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

  void toggleVoiceMode() {
    useAiVoice = !useAiVoice;
    notifyListeners();
  }

  Future<void> stopAllAudio() async {
    _isAiLoading = false;
    _activeSessionId = "STOP_${DateTime.now().millisecondsSinceEpoch}";
    notifyListeners();
  }

  void setActiveSessionId(String id) {
    _activeSessionId = id;
    notifyListeners();
  }

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
}
