import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'home_v2_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'ai_assistant_screen.dart';
import 'audio_player_screen.dart';
import '../providers/app_provider.dart';
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
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    // Dummy active book for mini player demo
    final activeBook = provider.liveBooks.isNotEmpty ? provider.liveBooks.first : dummyBooks.first;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (provider.currentMainTabIndex != 0) {
          provider.setMainTab(0);
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
              padding: EdgeInsets.only(bottom: provider.showMiniPlayer ? 140 : 80), 
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
                  key: ValueKey<int>(provider.currentMainTabIndex),
                  child: _screens[provider.currentMainTabIndex],
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
                  if (provider.showMiniPlayer && provider.currentPlayingBook != null)
                    _buildMiniPlayer(context, isDark, provider),
                  
                  // Bottom Nav
                  _buildCustomNavBar(context, isDark, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, bool isDark, AppProvider provider) {
    final book = provider.currentPlayingBook!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AudioPlayerScreen(book: book))
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
              color: Colors.black.withOpacity(0.15),
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
                      value: 0.45, // Example progress
                      minHeight: 4,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.newPrimary),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Controls
            Row(
              children: [
                // Stop/Close Square Button
                IconButton(
                  icon: Icon(Icons.stop_rounded, color: isDark ? Colors.white38 : Colors.grey[400]),
                  onPressed: () => provider.stopPlayback(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                // Play/Pause Circle
                GestureDetector(
                  onTap: () => provider.togglePlayPause(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.newPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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

  Widget _buildCustomNavBar(BuildContext context, bool isDark, AppProvider provider) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30), // Extra bottom padding for home indicator
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF121212) : Colors.white).withOpacity(0.85),
            border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavBarItem(provider, 0, Icons.home_rounded, 'الرئيسية'),
              _buildNavBarItem(provider, 1, Icons.search_rounded, 'البحث'),
              _buildNavBarItem(provider, 2, Icons.auto_stories_rounded, 'مكتبتي'),
              _buildNavBarItem(provider, 3, Icons.person_outline_rounded, 'حسابي'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(AppProvider provider, int index, IconData icon, String label) {
    final bool isActive = provider.currentMainTabIndex == index;
    return GestureDetector(
      onTap: () => provider.setMainTab(index),
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
