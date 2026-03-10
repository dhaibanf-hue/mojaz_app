import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../providers/app_provider.dart';
import '../constants.dart';
import 'book_detail_screen.dart';
import 'all_categories_screen.dart';
import 'category_books_screen.dart';
import '../widgets/animated_book_card.dart';
import '../utils/route_transitions.dart';
import 'package:animations/animations.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  final List<String> _recentSearches = ['العادات الذرية', 'علم النفس', 'تطوير الذات'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _isSearching = true;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    final provider = Provider.of<BooksProvider>(context, listen: false);
    final results = await provider.searchBooks(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header & Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'استكشف',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن كتاب، مؤلف أو موضوع',
                        hintStyle: GoogleFonts.notoKufiArabic(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        prefixIcon: _isSearching 
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: _clearSearch,
                              color: Colors.grey,
                            )
                          : null,
                        suffixIcon: Icon(Icons.search, color: isDark ? AppColors.newPrimary : Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: _isSearching
                    ? KeyedSubtree(key: const ValueKey('search'), child: _buildSearchResults(context, isDark))
                    : KeyedSubtree(key: const ValueKey('discover'), child: _buildDiscoveryView(context, isDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryView(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches Mock
          if (_recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     'عمليات البحث الأخيرة',
                     style: GoogleFonts.notoKufiArabic(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: isDark ? Colors.white : Colors.black,
                     ),
                   ),
                   const SizedBox(height: 12),
                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: _recentSearches.map((term) {
                       return AnimatedSize(
                         duration: const Duration(milliseconds: 250),
                         curve: Curves.easeInOut,
                         child: InputChip(
                           label: Text(term, style: const TextStyle(fontSize: 12)),
                           onDeleted: () {
                             setState(() {
                               _recentSearches.remove(term);
                             });
                           },
                           deleteIconColor: Colors.grey[500],
                           backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                           onPressed: () {
                             _searchController.text = term;
                             _performSearch(term);
                           },
                         ),
                       );
                     }).toList(),
                   ),
                ],
              ),
            ),

          // Categories Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التصنيفات',
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                     Navigator.push(context, FadeThroughPageRoute(page: const AllCategoriesScreen()));
                  },
                  child: Text(
                    'عرض الكل',
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildCategoryBtn(context, 'علم النفس', Icons.psychology, isDark),
              _buildCategoryBtn(context, 'ريادة الأعمال', Icons.rocket_launch, isDark),
              _buildCategoryBtn(context, 'الفلسفة', Icons.groups, isDark),
              _buildCategoryBtn(context, 'الإنتاجية', Icons.hourglass_empty, isDark),
            ],
          ),

          const SizedBox(height: 32),

          // Trending Now
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'شائع الآن',
              style: GoogleFonts.notoKufiArabic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: Consumer<BooksProvider>(
              builder: (context, provider, child) {
                final books = provider.liveBooks.isNotEmpty ? provider.liveBooks.take(5).toList() : dummyBooks.take(3).toList();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: books.length,
                  itemBuilder: (context, index) => _buildTrendingBook(context, books[index], isDark),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // New Summaries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'أحدث الملخصات',
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Consumer<BooksProvider>(
            builder: (context, provider, child) {
              final books = provider.liveBooks.isNotEmpty ? provider.liveBooks.reversed.take(4).toList() : dummyBooks;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildNewBookItem(context, books[index], isDark),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isDark) {
    if (_searchResults.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
             const SizedBox(height: 16),
             Text(
               'لا توجد نتائج لبحثك',
               style: GoogleFonts.notoKufiArabic(fontSize: 16, color: Colors.grey),
             ),
             const SizedBox(height: 24),
             Text(
               'جرب البحث عن أحد هذه التصنيفات:',
               style: GoogleFonts.notoKufiArabic(fontSize: 12, color: Colors.grey[500]),
             ),
             const SizedBox(height: 16),
             Wrap(
               spacing: 8,
               children: [
                 _buildSmallCategoryChip('تاريخ', isDark),
                 _buildSmallCategoryChip('فلسفة', isDark),
                 _buildSmallCategoryChip('ذكاء اصطناعي', isDark),
               ],
             )
           ],
         ),
       );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildNewBookItem(context, _searchResults[index], isDark);
      },
    );
  }

  Widget _buildSmallCategoryChip(String label, bool isDark) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
    );
  }

  Widget _buildCategoryBtn(BuildContext context, String title, IconData icon, bool isDark) {
    return InkWell(
      onTap: () {
        final provider = Provider.of<BooksProvider>(context, listen: false);
        final allBooks = provider.liveBooks.isNotEmpty ? provider.liveBooks : dummyBooks;
        final filtered = allBooks.where((b) => b.category.contains(title) || title.contains(b.category)).toList();
        Navigator.push(context, FadeThroughPageRoute(page: CategoryBooksScreen(categoryName: title, books: filtered.isEmpty ? allBooks : filtered)));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.newPrimary, size: 22),
            Text(
              title,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingBook(BuildContext context, Book book, bool isDark) {
    return SizedBox(
      width: 140,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AnimatedBookCard(
          book: book,
          heroTag: 'trending-${book.id}',
          closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          cardBuilder: (context, openContainer) {
            return GestureDetector(
              onTap: openContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: book.cover,
                          height: 180,
                          width: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.headset_rounded, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              const Text('18 د', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 10,
                      color: AppColors.newPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewBookItem(BuildContext context, Book book, bool isDark) {
    return AnimatedBookCard(
      book: book,
      heroTag: 'new-${book.id}',
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      cardBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: book.cover,
                    width: 54,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: AppColors.newPrimary.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text('15 دقيقة', style: GoogleFonts.manrope(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.newPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(book.category, style: GoogleFonts.manrope(color: AppColors.newPrimary, fontSize: 10, fontWeight: FontWeight.w900)),
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
  }
}
