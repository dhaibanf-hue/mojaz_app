import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/app_provider.dart';
import '../constants.dart';
import 'book_detail_screen.dart';
import '../widgets/animated_book_card.dart';
import 'package:animations/animations.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _localQuery = "";
  int _currentIndex = 0;
  bool _isReverse = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentIndex) {
        setState(() {
          _isReverse = _tabController.index < _currentIndex;
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<AppProvider>(context);

    // Filtering Logic (Synced with Provider)
    final allBooks = provider.liveBooks.isNotEmpty ? provider.liveBooks : dummyBooks;
    
    // Filter by Query if exists
    final filtered = allBooks.where((b) => 
      b.title.toLowerCase().contains(_localQuery.toLowerCase()) || 
      b.author.toLowerCase().contains(_localQuery.toLowerCase())
    ).toList();

    final inProgress = filtered.where((b) {
      final totalSeconds = (b.durationMinutes ?? 15) * 60;
      final progress = provider.getBookProgress(b.id);
      return progress > 0 && progress < totalSeconds;
    }).toList();
    final completed = filtered.where((b) {
      final totalSeconds = (b.durationMinutes ?? 15) * 60;
      return provider.getBookProgress(b.id) >= totalSeconds;
    }).toList();
    final downloaded = filtered.where((b) => provider.downloadedBookIds.contains(b.id)).toList();
    final favorites = filtered.where((b) => provider.favoriteBookIds.contains(b.id)).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مكتبتي',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.auto_stories_rounded, color: AppColors.newPrimary, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Inner Search
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _localQuery = v),
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'ابحث داخل مكتبتك...',
                        hintStyle: GoogleFonts.notoKufiArabic(fontSize: 12, color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Advanced Tabs with Counters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildTab(0, 'بدأت قراءتها', inProgress.length, isDark),
                  _buildTab(1, 'منجزة', completed.length, isDark),
                  _buildTab(2, 'بدون إنترنت', downloaded.length, isDark),
                  _buildTab(3, 'محفوظة', favorites.length, isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: _isReverse,
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _getTabContent(_currentIndex, inProgress, completed, downloaded, favorites, provider, isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTabContent(int index, List<Book> inProgress, List<Book> completed, List<Book> downloaded, List<Book> favorites, AppProvider provider, bool isDark) {
    switch (index) {
      case 0: return _buildList(inProgress, 'reading', provider, isDark);
      case 1: return _buildList(completed, 'done', provider, isDark);
      case 2: return _buildList(downloaded, 'offline', provider, isDark);
      case 3: return _buildList(favorites, 'saved', provider, isDark);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildTab(int index, String label, int count, bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final active = _tabController.index == index;
        return GestureDetector(
          onTap: () => _tabController.animateTo(index),
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.newPrimary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? AppColors.newPrimary : (isDark ? Colors.white12 : Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                if (count > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: active ? Colors.white24 : AppColors.newPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<Book> books, String type, AppProvider provider, bool isDark) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: 0.3, child: Icon(Icons.auto_stories_outlined, size: 80, color: AppColors.newPrimary)),
            const SizedBox(height: 16),
            Text('لا يوجد محتوى في هذا القسم', style: GoogleFonts.notoKufiArabic(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final book = books[index];
        final progressSeconds = provider.getBookProgress(book.id);
        final totalSeconds = (book.durationMinutes ?? 15) * 60;
        final percent = (progressSeconds / totalSeconds).clamp(0.0, 1.0);

        return AnimatedBookCard(
          book: book,
          heroTag: 'lib-${book.id}',
          closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          cardBuilder: (context, openContainer) {
            return InkWell(
              onTap: openContainer,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    // Cover + Progress Ring Overlay
                    SizedBox(
                      width: 60, height: 85,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(imageUrl: book.cover, fit: BoxFit.cover, width: 60, height: 85),
                          ),
                          Positioned(
                            bottom: 4, right: 4,
                            child: Container(
                              width: 24, height: 24,
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: Center(
                                child: TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0.0, end: percent),
                                  builder: (context, value, _) {
                                    return CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 2,
                                      color: AppColors.newPrimary,
                                      backgroundColor: Colors.white24,
                                    );
                                  }
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoKufiArabic(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          Text(book.author, style: GoogleFonts.notoKufiArabic(fontSize: 11, color: Colors.grey[500])),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                 decoration: BoxDecoration(color: AppColors.newPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                 child: Text(type == 'done' ? 'مكتمل' : '${(percent * 100).toInt()}%', 
                                     style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.newPrimary)),
                               ),
                               const Spacer(),
                               // Quick Actions
                               IconButton(
                                 icon: Icon(Icons.play_circle_fill_rounded, color: AppColors.newPrimary, size: 28),
                                 onPressed: () => provider.playBook(book),
                                 padding: EdgeInsets.zero,
                                 constraints: const BoxConstraints(),
                               ),
                               const SizedBox(width: 8),
                               IconButton(
                                 icon: Icon(type == 'saved' ? Icons.favorite_rounded : Icons.more_vert_rounded, 
                                     color: type == 'saved' ? Colors.redAccent : Colors.grey),
                                 onPressed: () => provider.toggleFavorite(book),
                                 padding: EdgeInsets.zero,
                                 constraints: const BoxConstraints(),
                               ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
