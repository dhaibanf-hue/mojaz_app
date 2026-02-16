import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'book_detail_screen.dart'; 
import 'search_screen.dart';
import 'category_books_screen.dart';
import '../models/book.dart';
import '../providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 1.0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newOpacity = (1 - (offset / 80)).clamp(0.0, 1.0);
    bool scrolled = offset > 60;
    
    if (newOpacity != _opacity || scrolled != _isScrolled) {
      setState(() {
        _opacity = newOpacity;
        _isScrolled = scrolled;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final isModern = provider.isModernDesign;
    final displayBooks = provider.liveBooks.isNotEmpty ? provider.liveBooks : dummyBooks;
    final categories = displayBooks.map((e) => e.category).toSet().toList();
    
    return Scaffold(
      backgroundColor: isModern ? Theme.of(context).scaffoldBackgroundColor : (isDark ? AppColors.darkBg : const Color(0xFFF5F7FA)),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchBooks(),
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                 SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 50)),
                 
                  // Removed permanent loader above search bar as per user request
                 
                 if (provider.errorMessage != null && provider.liveBooks.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white70, size: 32),
                            const SizedBox(height: 12),
                            Text(
                              provider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => provider.fetchBooks(forceRefresh: true),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('إعادة المحاولة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
               
               // Search Bar
               SliverToBoxAdapter(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 24),
                   child: _buildSearchBar(context),
                 ),
               ),

               // Categories
               SliverToBoxAdapter(child: _buildCategories(context)),

               SliverToBoxAdapter(
                 child: Container(
                   margin: const EdgeInsets.only(top: 20),
                   decoration: BoxDecoration(
                     color: Theme.of(context).scaffoldBackgroundColor,
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                   ),
                   padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildRecommendationSection(context, isDark, isModern, displayBooks),
                       const SizedBox(height: 32),
                       _buildDiscoverRandomlyButton(context, isDark, displayBooks),
                       const SizedBox(height: 32),

                       _buildSectionHeader(context, 'أكمل الاستماع', 'تابع من حيث توقفت', () {}),
                       const SizedBox(height: 16),
                       _buildContinueReadingCard(context),

                       const SizedBox(height: 32),

                       _buildSectionHeader(context, 'رائد الآن', 'كتب يتحدد عنها الجميع', () {}),
                       const SizedBox(height: 20),
                       _buildHorizontalBookList(displayBooks, 'trending'),

                       const SizedBox(height: 32),

                       ...categories.map((cat) {
                         final books = displayBooks.where((b) => b.category == cat).toList();
                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _buildSectionHeader(context, 'عالم $cat', '', () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryBooksScreen(categoryName: cat, books: books)));
                             }),
                             const SizedBox(height: 20),
                             _buildHorizontalBookList(books, cat),
                             const SizedBox(height: 32),
                           ],
                         );
                       }),
                       const SizedBox(height: 32),
                       _buildSectionHeader(context, 'انشر روتينك', 'شارك ما تعلمته اليوم', () {}),
                       const SizedBox(height: 16),
                       _buildShareStoryCard(context, isDark),
                       const SizedBox(height: 48),
                     ],
                   ),
                 ),
               ),
            ],
          ),

            _buildHeader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.primaryBg.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primaryBg.withValues(alpha: 0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: isDark ? Colors.white70 : AppColors.primaryBg.withValues(alpha: 0.6), size: 22),
                const SizedBox(width: 12),
                Text(
                  'ابحث عن كتاب أو كاتب...',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.primaryBg.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCategories(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildCategoryItem(context, 'تطوير ذات', Icons.psychology),
          _buildCategoryItem(context, 'إدارة أعمال', Icons.work),
          _buildCategoryItem(context, 'علم نفس', Icons.favorite),
          _buildCategoryItem(context, 'تاريخ', Icons.history_edu),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String name, IconData icon) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: name))),
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: isDark ? Colors.white : AppColors.primaryBg, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.primaryBg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context, bool isDark, bool isModern, List<Book> books) {
    if (books.isEmpty) return const SizedBox();
    final book = books.length > 3 ? books[3] : books[0];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مقترح ذكي لك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryBg)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryButton.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('ذكاء اصطناعي', style: TextStyle(color: AppColors.primaryButton, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: 'recommend-${book.id}'))),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.02)]
                    : (isModern 
                        ? [AppColors.primaryBg, AppColors.primaryBg.withValues(alpha: 0.8)]
                        : [const Color(0xFF1976D2), const Color(0xFF2196F3)]),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isModern ? 24 : 16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                   Hero(
                     tag: 'recommend-${book.id}',
                     child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(4, 4))],
                       ),
                       child: CachedNetworkImage(
                         imageUrl: book.cover, 
                         width: 75, 
                         height: 110, 
                         fit: BoxFit.cover,
                         placeholder: (context, url) => Container(color: Colors.grey[200]),
                       ),
                     )
                   ),
                   const SizedBox(width: 20),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(book.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 4),
                         Text(book.author, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                         const SizedBox(height: 16),
                         Material(
                           color: Colors.transparent,
                           child: InkWell(
                             onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: const Text('استمع الآن', style: TextStyle(color: AppColors.primaryBg, fontSize: 12, fontWeight: FontWeight.bold)),
                             ),
                           ),
                         )
                       ],
                     ),
                   )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContinueReadingCard(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final book = provider.liveBooks.isNotEmpty ? provider.liveBooks[0] : dummyBooks[0];
    final seconds = provider.getBookProgress(book.id);
    final double progress = (seconds / 900).clamp(0.0, 1.0); // Assuming 15 mins (900s) for dummy
    final remainingMins = (15 - (seconds / 60)).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: 'continue-${book.id}'))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryBg, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: book.cover, 
                  width: 50, 
                  height: 50, 
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(remainingMins > 0 ? 'باقي $remainingMins دقيقة' : 'تم إنهاء الملخص', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress > 0 ? progress : 0.05, minHeight: 4, backgroundColor: Colors.white12, color: AppColors.primaryButton)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(radius: 18, backgroundColor: AppColors.primaryButton, child: Icon(Icons.play_arrow, color: Colors.white, size: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBookList(List<Book> books, String section) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: books.length,
        itemBuilder: (context, index) => _buildBookItem(context, books[index], section),
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book, String section) {
    final String tag = '$section-${book.id}';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: tag))),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: tag,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CachedNetworkImage(
                    imageUrl: book.cover,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis, 
               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, 
               style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryBg)), 
              if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))
            ]
          ),
          TextButton(
            onPressed: onTap, 
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('اعرض الكل', style: TextStyle(color: AppColors.primaryButton, fontWeight: FontWeight.bold, fontSize: 12))
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 24, right: 24, bottom: 12),
        color: _isScrolled 
            ? (provider.isDarkMode ? AppColors.darkBg.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9)) 
            : Colors.transparent,
        child: Opacity(
          opacity: _opacity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Text(
                    'موجز', 
                    style: TextStyle(
                      color: _isScrolled 
                          ? (provider.isDarkMode ? Colors.white : AppColors.primaryBg) 
                          : Colors.white, 
                      fontSize: 26, 
                      fontWeight: FontWeight.w900
                    )
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  provider.toggleReminders();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.remindersEnabled ? 'تم تفعيل تذكيرات القراءة الذكية' : 'تم إيقاف التذكيرات'),
                      backgroundColor: provider.remindersEnabled ? AppColors.success : AppColors.secondaryText,
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 18, 
                  backgroundColor: Colors.white10, 
                  child: Icon(
                    provider.remindersEnabled ? Icons.notifications_active : Icons.notifications_none, 
                    color: provider.remindersEnabled ? AppColors.primaryButton : Colors.white, 
                    size: 20
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDiscoverRandomlyButton(BuildContext context, bool isDark, List<Book> books) {
    if (books.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () {
          final randomBook = (List.from(books)..shuffle()).first;
          Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: randomBook, heroTag: 'random-${randomBook.id}')));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryButton.withValues(alpha: 0.1) : AppColors.primaryButton,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryButton.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              if (!isDark) BoxShadow(color: AppColors.primaryButton.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories, color: isDark ? AppColors.primaryButton : Colors.white),
              const SizedBox(width: 12),
              Text(
                'اكتشف كتاباً عشوائياً', 
                style: TextStyle(
                  color: isDark ? AppColors.primaryButton : Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareStoryCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            const Text(
              '"العلم صيدٌ والكتابة قيدهُ"', 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShareButton(Icons.camera_alt_outlined, 'ستوري', Colors.purple),
                const SizedBox(width: 20),
                _buildShareButton(Icons.chat_bubble_outline_rounded, 'واتساب', Colors.green),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
      ],
    );
  }
}
