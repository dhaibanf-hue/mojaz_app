import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'home_v2_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'audio_player_screen.dart';
import 'ai_assistant_screen.dart';
import '../providers/app_provider.dart';
import '../utils/route_transitions.dart';
import '../constants.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeV2Screen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (booksProvider.currentMainTabIndex != 0) {
          booksProvider.setMainTab(0);
          return;
        }
        final shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Main Content
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(bottom: audioProvider.showMiniPlayer ? 140 : 80), 
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(booksProvider.currentMainTabIndex),
                  child: _screens[booksProvider.currentMainTabIndex],
                ),
              ),
            ),
            
            // Dynamic Footer Elements
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Real-time Mini Player
                  if (audioProvider.showMiniPlayer && audioProvider.currentPlayingBook != null)
                    _buildMiniPlayer(context, isDark, audioProvider, booksProvider),
                  
                  // Bottom Nav
                  _buildCustomNavBar(context, isDark, booksProvider),
                ],
              ),
            ),
            
            // AI Assistant FAB
            if (booksProvider.currentMainTabIndex == 0)
              Positioned(
                left: 24,
                bottom: audioProvider.showMiniPlayer ? 170 : 90,
                child: FloatingActionButton(
                  heroTag: 'ai_fab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeThroughPageRoute(page: const AiAssistantScreen()),
                    );
                  },
                  backgroundColor: AppColors.newPrimary,
                  elevation: 6,
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, bool isDark, AudioPlayerProvider audioProvider, BooksProvider booksProvider) {
    final book = audioProvider.currentPlayingBook!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeThroughPageRoute(page: AudioPlayerScreen(book: book))
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            // Book Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                 imageUrl: book.cover,
                 width: 44,
                 height: 44,
                 fit: BoxFit.cover,
              )
            ),
            const SizedBox(width: 12),
            // Progress and Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: audioProvider.currentDuration.inSeconds > 0 
                          ? audioProvider.currentPosition.inSeconds / audioProvider.currentDuration.inSeconds 
                          : 0.0,
                      minHeight: 4,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.newPrimary),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Controls
            Row(
              children: [
                // Speed Button
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التحكم في السرعة متاح في المشغل الكامل'), duration: Duration(seconds: 1)));
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '1.0x',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white38 : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Next Button
                IconButton(
                  icon: Icon(Icons.skip_next_rounded, color: isDark ? Colors.white38 : Colors.grey[500], size: 20),
                  onPressed: () {
                    final allBooks = booksProvider.liveBooks;
                    if (allBooks.isNotEmpty) {
                      final currentIndex = allBooks.indexWhere((b) => b.id == book.id);
                      final nextIndex = (currentIndex + 1) % allBooks.length;
                      audioProvider.playBook(allBooks[nextIndex]);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                // Play/Pause Circle
                GestureDetector(
                  onTap: () => audioProvider.togglePlayPause(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.newPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNavBar(BuildContext context, bool isDark, BooksProvider booksProvider) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF121212) : Colors.white).withValues(alpha: 0.85),
            border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavBarItem(booksProvider, 0, Icons.home_rounded, 'الرئيسية'),
              _buildNavBarItem(booksProvider, 1, Icons.search_rounded, 'البحث'),
              _buildNavBarItem(booksProvider, 2, Icons.auto_stories_rounded, 'مكتبتي'),
              _buildNavBarItem(booksProvider, 3, Icons.person_outline_rounded, 'حسابي'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(BooksProvider booksProvider, int index, IconData icon, String label) {
    final bool isActive = booksProvider.currentMainTabIndex == index;
    return GestureDetector(
      onTap: () => booksProvider.setMainTab(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.newPrimary : Colors.grey[400],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Noto Kufi Arabic',
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.newPrimary : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        title: const Text(
          'خروج من موجز', 
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)
        ),
        content: const Text(
          'هل تريد الخروج من التطبيق؟ ستم حفظ تقدمك تلقائياً.', 
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, height: 1.5)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontWeight: FontWeight.bold))
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('خروج', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}
