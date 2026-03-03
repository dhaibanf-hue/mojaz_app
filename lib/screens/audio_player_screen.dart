import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../constants.dart';
import '../providers/app_provider.dart';
import '../services/tts_service.dart';
import 'drive_mode_screen.dart';

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
  late String _mySessionId;

  // Reading Settings
  double _fontSize = 18.0;
  Color _themeBgColor = Colors.white;
  Color _themeTextColor = const Color(0xFF1E293B); // Slate 800
  String _activeThemeId = 'white';

  // TTS/Text Logic
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;
  Timer? _progressSaveTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _mySessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _initAudio();
    _initTts();
    
    // Prepare sentences
    _sentences = widget.book.description.isNotEmpty 
        ? widget.book.description.split(RegExp(r'(?<=[.؟!])\s+'))
        : ['لا يوجد نص متاح لهذا الكتاب.'];
    
    // Auto-save progress
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _saveAllProgress();
    });
  }

  void _saveAllProgress() {
    if (!mounted) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.saveBookProgress(widget.book.id, _position.inSeconds);
  }

  Future<void> _initTts() async {
    await _ttsService.initTts();
    _ttsService.engine.setCompletionHandler(() {
      if (mounted && _isTtsSpeaking) {
        setState(() {
          if (_currentSentenceIndex < _sentences.length - 1) {
            _currentSentenceIndex++;
            _ttsService.speak(_sentences[_currentSentenceIndex]);
            _scrollToCurrentSentence();
          } else {
            _isTtsSpeaking = false;
            _currentSentenceIndex = 0;
          }
        });
      }
    });
  }

  void _scrollToCurrentSentence() {
    // Basic scrolling logic - ideally would calculate offset of specific text span
    // For now, scroll incrementally or keeping it simple
  }

  Future<void> _initAudio() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final savedProgress = provider.getBookProgress(widget.book.id);
      
      // Load real audio if available
      if (widget.book.audioUrl.isNotEmpty) {
         await _audioPlayer.setUrl(widget.book.audioUrl);
      }
      
      if (savedProgress > 0) {
        await _audioPlayer.seek(Duration(seconds: savedProgress));
      }

      // Add state listeners to update UI
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      _audioPlayer.positionStream.listen((pos) {
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      });

      _audioPlayer.durationStream.listen((dur) {
        if (mounted) {
          setState(() {
            _duration = dur ?? Duration.zero;
          });
        }
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
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isTtsSpeaking) {
      _stopTts();
      return;
    }

    if (_audioPlayer.playing) {
      _audioPlayer.pause();
      _saveAllProgress();
    } else {
      _audioPlayer.play();
    }
  }
  
  void _stopTts() {
    _ttsService.stop();
    if (mounted) setState(() => _isTtsSpeaking = false);
  }

  // --- Actions ---
  void _toggleFavorite() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.toggleFavorite(widget.book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.isFavorite(widget.book.id) ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة'), duration: const Duration(seconds: 1)),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReaderSettingsModal(
        currentFontSize: _fontSize,
        currentThemeId: _activeThemeId,
        onFontSizeChanged: (val) => setState(() => _fontSize = val),
        onThemeChanged: (id, bg, text) => setState(() {
          _activeThemeId = id;
          _themeBgColor = bg;
          _themeTextColor = text;
        }),
        onReset: () => setState(() {
           _fontSize = 18.0;
           _activeThemeId = 'white';
           _themeBgColor = Colors.white;
           _themeTextColor = const Color(0xFF1E293B);
        }),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MoreOptionsModal(
        book: widget.book,
        toggleFavorite: _toggleFavorite,
        driveModeAction: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DriveModeScreen(book: widget.book)),
          );
        },
        downloadAction: () {
           final provider = Provider.of<AppProvider>(context, listen: false);
           if (provider.downloadedBookIds.contains(widget.book.id)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف التحميل')));
           } else {
              provider.markAsDownloaded(widget.book.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري التحميل...')));
           }
           Navigator.pop(context);
        },
        sleepTimerAction: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم ضبط مؤقت النوم: 15 دقيقة')));
           Navigator.pop(context);
        },
        shareAction: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري مشاركة الرابط...')));
           Navigator.pop(context);
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isFav = provider.isFavorite(widget.book.id);
    // Use theme text color or fallback based on current _themeBgColor brightness? 
    // Actually we set _themeTextColor explicitly.
    
    return Scaffold(
      backgroundColor: _themeBgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Navbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                         icon: Icon(Icons.expand_more_rounded, color: _themeTextColor.withValues(alpha: 0.7)),
                         onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isFav ? Icons.star_rounded : Icons.star_outline_rounded, 
                                      color: isFav ? AppColors.gold : _themeTextColor.withValues(alpha: 0.7)),
                            onPressed: _toggleFavorite,
                          ),
                          IconButton(
                            icon: Icon(Icons.text_fields_rounded, color: _themeTextColor.withValues(alpha: 0.7)),
                            onPressed: _showSettings,
                          ),
                          IconButton(
                            icon: Icon(Icons.format_list_bulleted_rounded, color: _themeTextColor.withValues(alpha: 0.7)),
                            onPressed: () { 
                              // Mock TOC
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قائمة الفصول'))); 
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert_rounded, color: _themeTextColor.withValues(alpha: 0.7)),
                            onPressed: _showMoreOptions,
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 180), // Space for player
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Container(
                               width: 100, height: 140,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(12),
                                 boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                               ),
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(12),
                                 child: CachedNetworkImage(imageUrl: widget.book.cover, fit: BoxFit.cover),
                               ),
                             ),
                             const SizedBox(width: 20),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     widget.book.author,
                                     style: GoogleFonts.notoKufiArabic(
                                       fontSize: 12,
                                       fontWeight: FontWeight.bold,
                                       color: AppColors.newPrimary,
                                     ),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     widget.book.title,
                                     style: GoogleFonts.notoKufiArabic(
                                       fontSize: 18,
                                       fontWeight: FontWeight.bold,
                                       color: _themeTextColor,
                                       height: 1.3,
                                     ),
                                   ),
                                   const SizedBox(height: 12),
                                   Row(
                                     children: [
                                       _buildInfoChip(Icons.menu_book_rounded, '8 فصول'),
                                       const SizedBox(width: 12),
                                       _buildInfoChip(Icons.schedule_rounded, '21 دقيقة'),
                                     ],
                                   )
                                 ],
                               ),
                             )
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Text Content
                        Text(
                          'المقدمة',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.newPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.book.description, // Using full description as demo text
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: _fontSize,
                            color: _activeThemeId == 'dark' ? Colors.grey[300] : Colors.grey[800],
                            height: 1.8,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        
                        // Demo extra text
                         const SizedBox(height: 20),
                         Text(
                          'ما الفائدة من هذا الملخص لي؟',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: _fontSize + 4,
                            fontWeight: FontWeight.bold,
                            color: _themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لطالما كان للبيئة عدو واضح: التلوث، الجرافات، المداخن، والشهية المتهورة للصناعة. هذا التصور هو ما قاد انتصارات حقيقية. لكن تغير المناخ يغير الخريطة القديمة بالكامل.',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: _fontSize,
                            color: _activeThemeId == 'dark' ? Colors.grey[300] : Colors.grey[800],
                            height: 1.8,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Floating Player
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _buildFloatingPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.notoKufiArabic(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFloatingPlayer() {
    return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: AppColors.newBackgroundDark, 
         borderRadius: BorderRadius.circular(28),
         boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
         ],
       ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           // Segmented Progress Bar
           SizedBox(
             height: 4,
             child: StreamBuilder<Duration?>(
               stream: _audioPlayer.durationStream,
               builder: (context, snapshotDuration) {
                 final duration = snapshotDuration.data ?? Duration.zero;
                 return StreamBuilder<Duration>(
                   stream: _audioPlayer.positionStream,
                   builder: (context, snapshotPosition) {
                     final position = snapshotPosition.data ?? Duration.zero;
                     return LayoutBuilder(
                       builder: (context, constraints) {
                         final count = 30; // Segments count
                         final width = constraints.maxWidth;
                         final segWidth = (width - (count - 1) * 2) / count;
                         
                         final totalSec = duration.inSeconds > 0 ? duration.inSeconds : 1;
                         final currentSec = position.inSeconds;
                         final percent = currentSec / totalSec;
                         final activeCount = (percent * count).toInt();
                         
                         return Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: List.generate(count, (index) {
                             final isActive = index < activeCount;
                             return Expanded(
                               child: Container(
                                 margin: const EdgeInsets.symmetric(horizontal: 1),
                                 decoration: BoxDecoration(
                                   color: isActive ? AppColors.newPrimary : Colors.white.withValues(alpha: 0.1),
                                   borderRadius: BorderRadius.circular(2),
                                 ),
                               ),
                             );
                           }),
                         );
                       }
                     );
                   }
                 );
               }
             ),
           ),
           const SizedBox(height: 16),
           
           // Controls
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               // Speed (Demo)
               TextButton(
                 onPressed: () {
                   // Cycle speed logic
                 },
                 style: TextButton.styleFrom(
                   foregroundColor: Colors.white70,
                   minimumSize: const Size(40, 40),
                 ),
                 child: const Text('1x', style: TextStyle(fontWeight: FontWeight.bold)),
               ),
               
               // Playback Icons
               Row(
                 children: [
                   IconButton(
                     onPressed: () {
                        // Safe seek backward
                        if (_audioPlayer.position.inSeconds > 5) {
                          _audioPlayer.seek(_audioPlayer.position - const Duration(seconds: 5));
                        } else {
                          _audioPlayer.seek(Duration.zero);
                        }
                     },
                     icon: const Icon(Icons.replay_5_rounded, color: Colors.white70),
                   ),
                   const SizedBox(width: 16),
                   GestureDetector(
                     onTap: _togglePlay,
                     child: StreamBuilder<PlayerState>(
                       stream: _audioPlayer.playerStateStream,
                       builder: (context, snapshot) {
                         final isPlaying = snapshot.data?.playing ?? false;
                         return Container(
                           width: 56, height: 56,
                           decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                           child: Icon(
                             isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, 
                             color: AppColors.newBackgroundDark, 
                             size: 32
                           ),
                         );
                       }
                     ),
                   ),
                   const SizedBox(width: 16),
                   IconButton(
                     onPressed: () {
                        // Safe seek forward
                        _audioPlayer.seek(_audioPlayer.position + const Duration(seconds: 5));
                     },
                     icon: const Icon(Icons.forward_5_rounded, color: Colors.white70),
                   ),
                 ],
               ),
               
               // Next
               IconButton(
                 onPressed: () {},
                 icon: const Icon(Icons.skip_next_rounded, color: Colors.white60),
               ),
             ],
           ),
         ],
       ),
    );
  }
}

// --- Modals ---

class ReaderSettingsModal extends StatelessWidget {
  final double currentFontSize;
  final String currentThemeId;
  final Function(double) onFontSizeChanged;
  final Function(String, Color, Color) onThemeChanged;
  final VoidCallback onReset;

  const ReaderSettingsModal({
    super.key,
    required this.currentFontSize,
    required this.currentThemeId,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2F35), // Card Green
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           // Themes
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _buildThemeBtn('black', Colors.black, Colors.white),
               _buildThemeBtn('dark', const Color(0xFF062127), Colors.white), // Dark Teal
               _buildThemeBtn('cream', const Color(0xFFF5E6CC), Colors.black87),
               _buildThemeBtn('white', Colors.white, Colors.black87),
             ],
           ),
           const SizedBox(height: 32),
           
           // Font Size
           Row(
             children: [
               const Text('Aa', style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold)),
               Expanded(
                 child: SliderTheme(
                   data: SliderTheme.of(context).copyWith(
                     activeTrackColor: AppColors.newPrimary,
                     inactiveTrackColor: Colors.white24,
                     thumbColor: Colors.white,
                     trackHeight: 4,
                   ),
                   child: Slider(
                     value: currentFontSize,
                     min: 12,
                     max: 32,
                     onChanged: onFontSizeChanged,
                   ),
                 ),
               ),
               const Text('Aa', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             ],
           ),
           
           const SizedBox(height: 24),
           TextButton(
             onPressed: onReset,
             child: const Text('إعادة للوضع الأصلي', style: TextStyle(color: AppColors.newPrimary, fontWeight: FontWeight.bold)),
           ),
        ],
      ),
    );
  }

  Widget _buildThemeBtn(String id, Color bg, Color text) {
    final bool isActive = currentThemeId == id;
    return GestureDetector(
      onTap: () => onThemeChanged(id, bg, text),
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.newPrimary : Colors.transparent, 
            width: 2
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
      ),
    );
  }
}


class MoreOptionsModal extends StatelessWidget {
  final Book book;
  final VoidCallback toggleFavorite;
  final VoidCallback downloadAction;
  final VoidCallback sleepTimerAction;
  final VoidCallback shareAction;
  final VoidCallback driveModeAction;

  const MoreOptionsModal({
    super.key,
    required this.book,
    required this.toggleFavorite,
    required this.downloadAction,
    required this.sleepTimerAction,
    required this.shareAction,
    required this.driveModeAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF063B34), // Moojaz Dark Green
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 24),
              width: 48, height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), 
                borderRadius: BorderRadius.circular(3)
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'خيارات إضافية',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          _buildOptionTile(
            icon: Icons.bookmark_border_rounded, 
            label: 'إضافة للمحفوظات',
            onTap: toggleFavorite,
          ),
          _buildOptionTile(
            icon: Icons.directions_car_rounded, 
            label: 'وضع القيادة',
            onTap: driveModeAction,
          ),
          _buildOptionTile(
            icon: Icons.download_rounded, 
            label: 'تحميل الملخص',
            onTap: downloadAction,
          ),
          _buildOptionTile(
            icon: Icons.bedtime_rounded, 
            label: 'ضبط مؤقت النوم',
            onTap: sleepTimerAction,
          ),
          _buildOptionTile(
            icon: Icons.share_rounded, 
            label: 'مشاركة',
            onTap: shareAction,
          ),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('إلغاء', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Icon(Icons.chevron_left_rounded, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
