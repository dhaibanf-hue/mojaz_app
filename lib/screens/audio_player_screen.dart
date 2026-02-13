import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../constants.dart';
import '../providers/app_provider.dart';
import '../services/tts_service.dart';
import 'drive_mode_screen.dart';
import 'dart:async';
import 'dart:ui';


class AudioPlayerScreen extends StatefulWidget {
  final Book book;

  const AudioPlayerScreen({super.key, required this.book});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  final TtsService _ttsService = TtsService();
  
  bool _isPlaying = false;
  bool _isTtsSpeaking = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _viewMode = 'audio';
  late String _mySessionId;

  // TTS Resume logic
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;
  Timer? _progressSaveTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _mySessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _initAudio();
    _initTts();
    
    // Efficient sentence splitting without memory bloat
    _sentences = widget.book.description.isNotEmpty 
        ? widget.book.description.split(RegExp(r'(?<=[.؟!])\s+'))
        : ['لا يوجد نص متاح لهذا الكتاب.'];
    
    // Start periodic progress saving
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _saveAllProgress();
    });
  }

  void _saveAllProgress() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.saveBookProgress(widget.book.id, _position.inSeconds);
    // You could also save _currentSentenceIndex if desired
  }

  Future<void> _initTts() async {
    await _ttsService.initTts();
    _ttsService.engine.setCompletionHandler(() {
      if (mounted && _isTtsSpeaking) {
        setState(() {
          if (_currentSentenceIndex < _sentences.length - 1) {
            _currentSentenceIndex++;
            _ttsService.speak(_sentences[_currentSentenceIndex]);
          } else {
            _isTtsSpeaking = false;
            _currentSentenceIndex = 0;
          }
        });
      }
    });

    _ttsService.engine.setStartHandler(() {
       if (mounted) setState(() {}); 
    });
  }

  Future<void> _initAudio() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final savedProgress = provider.getBookProgress(widget.book.id);
      
      await _audioPlayer.setUrl(widget.book.audioUrl);
      
      if (savedProgress > 0) {
        await _audioPlayer.seek(Duration(seconds: savedProgress));
      }

      _audioPlayer.durationStream.listen((d) => setState(() => _duration = d ?? Duration.zero));
      _audioPlayer.positionStream.listen((p) => setState(() => _position = p));
      _audioPlayer.playerStateStream.listen((state) {
        setState(() => _isPlaying = state.playing);
      });
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _saveAllProgress();
    _audioPlayer.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _togglePlay() {
    if (_isTtsSpeaking) _stopTts();

    if (_isPlaying) {
      _audioPlayer.pause();
      _saveAllProgress(); // Save explicitly on pause
    } else {
      _audioPlayer.play();
    }
  }

  bool _isProcessingAi = false;


  void _toggleTts() async {
    if (_isProcessingAi || !mounted) return;
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    if (_isTtsSpeaking) {
      _stopTts();
    } else {
      _isProcessingAi = true;
      try {
    if (_isPlaying) {
      await _audioPlayer.pause();
      // Ensure it's fully stopped for TTS to take over
      await _audioPlayer.stop();
    }
    await provider.stopAllAudio();
        
        if (!mounted) return;
        provider.setAiLoading(true);
        provider.setRunInBackground(false);
        provider.setActiveSessionId(_mySessionId);
        
        for (int i = 0; i <= 100; i += 10) {
          if (!mounted || provider.activeSessionId != _mySessionId || provider.runInBackground) break;
          provider.setAiProgress(i / 100);
          await Future.delayed(const Duration(milliseconds: 50));
        }
        
        if (!mounted || provider.activeSessionId != _mySessionId) return;
        
        provider.setAiLoading(false);
        setState(() => _isTtsSpeaking = true);
        
        // Safety check before speaking
        if (_currentSentenceIndex < _sentences.length) {
          await _ttsService.speak(_sentences[_currentSentenceIndex]);
        }
      } catch (e) {
        debugPrint("AI Voice Error: $e");
      } finally {
        _isProcessingAi = false;
        if (mounted && provider.isAiLoading) {
          provider.setAiLoading(false);
        }
      }
    }
  }

  void _stopTts() {
    _ttsService.stop();
    if (mounted) {
      setState(() => _isTtsSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Stop if another session is active
    if (provider.activeSessionId != null && 
        provider.activeSessionId != _mySessionId && 
        (_isPlaying || _isTtsSpeaking)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isPlaying) _audioPlayer.pause();
        if (_isTtsSpeaking) _stopTts();
      });
    }

    return Scaffold(
      backgroundColor: provider.isDarkMode ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriveModeScreen(book: widget.book))),
            tooltip: 'وضع القيادة',
          ),
          IconButton(
            icon: Icon(_isTtsSpeaking ? Icons.stop_circle : Icons.record_voice_over),
            onPressed: _toggleTts,
            tooltip: 'تبديل صوت الذكاء الاصطناعي',
          ),
          IconButton(icon: const Icon(Icons.playlist_add), onPressed: () => provider.addToPlaylist(widget.book)),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildToggleHeader(),
              Expanded(
                child: _viewMode == 'audio' ? _buildAudioView() : _buildTextView(),
              ),
              _buildControls(),
            ],
          ),
          if (provider.isAiLoading && !provider.runInBackground)
            _buildAiLoadingOverlay(context, provider),
        ],
      ),
    );
  }

  Widget _buildAiLoadingOverlay(BuildContext context, AppProvider provider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black26,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: provider.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: provider.aiLoadingProgress,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryButton),
                      ),
                    ),
                    Text(
                      "${(provider.aiLoadingProgress * 100).toInt()}%",
                      style: TextStyle(
                        color: provider.isDarkMode ? Colors.white : AppColors.primaryBg,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'جاري تحضير الملخص...',
                  style: TextStyle(
                    color: provider.isDarkMode ? Colors.white : AppColors.primaryBg,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يتم استخدام الذكاء الاصطناعي لإنشاء محتوى فريد',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => provider.stopAllAudio(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => provider.setRunInBackground(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('الخلفية'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTabItem('audio', 'استماع', Icons.headset),
          _buildTabItem('text', 'قراءة', Icons.menu_book),
        ],
      ),
    );
  }

  Widget _buildTabItem(String mode, String label, IconData icon) {
    final bool active = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? AppColors.primaryBg : Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: active ? AppColors.primaryBg : Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: 'audio-player-${widget.book.id}',
          child: Container(
            width: 240, height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(image: NetworkImage(widget.book.cover), fit: BoxFit.cover),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(widget.book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(widget.book.author, style: const TextStyle(color: AppColors.secondaryText)),
      ],
    );
  }

  Widget _buildTextView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            height: 1.8, 
            fontSize: 16, 
            color: Provider.of<AppProvider>(context).isDarkMode ? Colors.white : Colors.black87,
            fontFamily: 'Outfit'
          ),
          children: _sentences.asMap().entries.map((entry) {
            final int idx = entry.key;
            final String text = entry.value;
            final bool isCurrent = _isTtsSpeaking && _currentSentenceIndex == idx;
            
            return TextSpan(
              text: "$text ",
              style: TextStyle(
                backgroundColor: isCurrent ? AppColors.primaryButton.withValues(alpha: 0.3) : Colors.transparent,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        children: [
          Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble().clamp(1.0, double.infinity),
            onChanged: (value) {
              final newPos = Duration(seconds: value.toInt());
              _audioPlayer.seek(newPos);
              _saveAllProgress(); // Save explicitly on seek
            },
            activeColor: AppColors.primaryButton,
            inactiveColor: AppColors.primaryButton.withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.replay_10), onPressed: () => _audioPlayer.seek(_position - const Duration(seconds: 10))),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(color: AppColors.primaryButton, shape: BoxShape.circle),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                ),
              ),
              IconButton(icon: const Icon(Icons.forward_10), onPressed: () => _audioPlayer.seek(_position + const Duration(seconds: 10))),
            ],
          )
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}
