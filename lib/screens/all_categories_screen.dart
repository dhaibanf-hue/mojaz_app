import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/book.dart';
import '../providers/app_provider.dart';
import 'category_books_screen.dart'; // Import to navigate to category list
import '../utils/route_transitions.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  // Use constant categories from App as per user request flow
  // "When clicking View All categories, it navigates here"
  
  String _searchQuery = '';
  final List<CategoryItem> _categories = const [
     CategoryItem(name: 'تطوير الذات', count: 45, icon: Icons.self_improvement, id: 'self_improvement'),
     CategoryItem(name: 'ريادة الأعمال', count: 32, icon: Icons.trending_up, id: 'entrepreneurship'),
     CategoryItem(name: 'علم النفس', count: 28, icon: Icons.psychology, id: 'psychology'),
     CategoryItem(name: 'الاقتصاد', count: 19, icon: Icons.payments, id: 'finance'),
     CategoryItem(name: 'التاريخ', count: 22, icon: Icons.history_edu, id: 'history'),
     CategoryItem(name: 'التكنولوجيا', count: 15, icon: Icons.memory, id: 'technology'),
     CategoryItem(name: 'الأدب العالمي', count: 41, icon: Icons.menu_book, id: 'literature'),
     CategoryItem(name: 'الصحة والجمال', count: 12, icon: Icons.favorite_border, id: 'health'),
  ];
  
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<BooksProvider>(context);
    final allBooks = provider.liveBooks.isNotEmpty ? provider.liveBooks : dummyBooks;
    
    final filteredCategories = _searchQuery.isEmpty 
        ? _categories 
        : _categories.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
             // Status Bar Area Mockup if needed or just SafeArea padding (already handled)
             
             // Header
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
               child: Column(
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         'تصنيفات موجز',
                         style: GoogleFonts.manrope(
                           fontSize: 24,
                           fontWeight: FontWeight.w800,
                           color: isDark ? Colors.white : const Color(0xFF1E293B),
                         ),
                       ),
                       Container(
                         width: 40,
                         height: 40,
                         decoration: BoxDecoration(
                           color: AppColors.newPrimary.withValues(alpha: 0.1),
                           shape: BoxShape.circle,
                         ),
                         child: IconButton(
                           icon: Icon(Icons.notifications_none, color: AppColors.newPrimary),
                           onPressed: () {},
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   // Search within categories
                   Container(
                     height: 48,
                     decoration: BoxDecoration(
                       color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.white,
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: [
                         if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                       ],
                     ),
                     child: TextField(
                       onChanged: (val) => setState(() => _searchQuery = val),
                       textAlign: TextAlign.right,
                       textDirection: TextDirection.rtl,
                       decoration: InputDecoration(
                         hintText: 'ابحث عن تصنيف...',
                         hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                         prefixIcon: Icon(Icons.search, color: AppColors.newPrimary.withValues(alpha: 0.6)), // Left icon for RTL inputs is prefix? No, usually suffix if RTL. But Design has specific icon placement.
                         // Design: Magnifying glass on RIGHT. Input text starts left of it?
                         // "absolute inset-y-0 right-0" in Tailwind means icon is on RIGHT.
                         // So we use suffixIcon for standard Flutter RTL or prefixIcon if LTR.
                         // Let's use suffixIcon for RTL search.
                         suffixIcon: Icon(Icons.search, color: AppColors.newPrimary.withValues(alpha: 0.6)),
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(vertical: 14),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             
             Expanded(
               child: GridView.builder(
                 padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                   childAspectRatio: 1.4,
                   crossAxisSpacing: 16,
                   mainAxisSpacing: 16,
                 ),
                 itemCount: filteredCategories.length,
                 itemBuilder: (context, index) {
                   final cat = filteredCategories[index];
                   return _buildCategoryCard(context, cat, isDark, allBooks);
                 },
               ),
             ),
             
             // CTA Section
             Padding(
               padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
               child: Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: AppColors.newPrimary.withValues(alpha: isDark ? 0.1 : 0.05),
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.2)),
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.auto_stories, size: 48, color: AppColors.newPrimary.withValues(alpha: 0.8)),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             'هل تبحث عن شيء محدد؟',
                             style: GoogleFonts.manrope(
                               fontSize: 14,
                               fontWeight: FontWeight.bold,
                               color: isDark ? Colors.white : const Color(0xFF1E293B),
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             'تصفح مكتبتنا الشاملة لأكثر من ١٠٠٠ ملخص كتاب عالمي.',
                             style: GoogleFonts.manrope(
                               fontSize: 11,
                               color: isDark ? Colors.grey[400] : Colors.grey[600],
                             ),
                           ),
                           const SizedBox(height: 8),
                           InkWell(
                             onTap: () {},
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                               decoration: BoxDecoration(
                                 color: AppColors.newPrimary,
                                 borderRadius: BorderRadius.circular(8),
                                 boxShadow: [
                                   BoxShadow(
                                     color: AppColors.newPrimary.withValues(alpha: 0.3),
                                     blurRadius: 8,
                                     offset: const Offset(0, 4),
                                   )
                                 ],
                               ),
                               child: Text(
                                 'اكتشف المزيد',
                                 style: GoogleFonts.manrope(
                                   fontSize: 12,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.white,
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
      // Bottom Nav would be MainScreen's responsibility usually, 
      // but design implies this is a standalone full screen or tab?
      // "When clicking View All categories, it navigates HERE"
      // So this is a pushed screen.
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryItem cat, bool isDark, List<Book> allBooks) {
    // Calculate real count from live books
    final filteredBooks = allBooks.where((b) {
      return b.category.contains(cat.name) || cat.name.contains(b.category) ||
             (cat.id == 'psychology' && b.category.contains('علم نفس')) ||
             (cat.id == 'self_improvement' && (b.category.contains('تطوير') || b.category.contains('ذات'))) ||
             (cat.id == 'entrepreneurship' && b.category.contains('ريادة')) ||
             (cat.id == 'finance' && (b.category.contains('اقتصاد') || b.category.contains('مال'))) ||
             (cat.id == 'history' && b.category.contains('تاريخ')) ||
             (cat.id == 'technology' && b.category.contains('تكنولوجيا')) ||
             (cat.id == 'literature' && b.category.contains('أدب')) ||
             (cat.id == 'health' && (b.category.contains('صحة') || b.category.contains('جمال')));
    }).toList();
    final displayCount = filteredBooks.isNotEmpty ? filteredBooks.length : cat.count;
    final booksToShow = filteredBooks.isNotEmpty ? filteredBooks : allBooks;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeThroughPageRoute(
            page: CategoryBooksScreen(
              categoryName: cat.name,
              books: booksToShow,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
          boxShadow: [
             if (!isDark) BoxShadow(
               color: Colors.black.withValues(alpha: 0.03),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.newPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cat.icon, color: AppColors.newPrimary, size: 24),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                   '$displayCount ملخص',
                   style: GoogleFonts.manrope(
                     fontSize: 11,
                     color: AppColors.newPrimary,
                     fontWeight: FontWeight.w600,
                   ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final int count;
  final IconData icon;
  final String id;
  
  const CategoryItem({required this.name, required this.count, required this.icon, required this.id});
}
