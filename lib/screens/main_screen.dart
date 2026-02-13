import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'ai_assistant_screen.dart';
import '../providers/app_provider.dart';
import '../constants.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // If not on the Home tab, go back to it first
        if (provider.currentMainTabIndex != 0) {
          provider.setMainTab(0);
          return;
        }

        // If on the Home tab, show exit confirmation
        final shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: provider.currentMainTabIndex,
          children: _screens,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
          },
          backgroundColor: AppColors.primaryButton,
          child: const Icon(Icons.psychology, color: Colors.white, size: 30),
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem(provider, 0, Icons.home_rounded, Icons.home_outlined, 'الرئيسية'),
                  _buildNavBarItem(provider, 1, Icons.search_rounded, Icons.search, 'البحث'),
                  _buildNavBarItem(provider, 2, Icons.library_books_rounded, Icons.library_books_outlined, 'مكتبتي'),
                  _buildNavBarItem(provider, 3, Icons.person_rounded, Icons.person_outline, 'حسابي'),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildNavBarItem(AppProvider provider, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isActive = provider.currentMainTabIndex == index;
    return GestureDetector(
      onTap: () => provider.setMainTab(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryButton.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? AppColors.primaryButton : AppColors.secondaryText,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primaryButton : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
