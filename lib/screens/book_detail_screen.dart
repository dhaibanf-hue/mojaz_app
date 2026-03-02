import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../constants.dart';
import 'audio_player_screen.dart';
import '../providers/app_provider.dart';
import 'dart:ui'; // For BackdropFilter

class BookDetailScreen extends StatelessWidget {
  final Book book;
  final String? heroTag;

  const BookDetailScreen({super.key, required this.book, this.heroTag});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<AppProvider>(context);
    final isDownloaded = provider.downloadedBookIds.contains(book.id);
    final isFavorite = provider.favoriteBookIds.contains(book.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Navbar (pinned)
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: (isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight).withOpacity(0.9),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white : Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'تفاصيل الكتاب',
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: isDark ? Colors.white70 : Colors.black54),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(isDownloaded ? Icons.download_done_rounded : Icons.download_outlined, 
                              color: isDownloaded ? AppColors.newPrimary : (isDark ? Colors.white70 : Colors.black54)),
                    onPressed: () => provider.toggleDownload(book.id),
                  ),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                              color: isFavorite ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54)),
                    onPressed: () => provider.toggleFavorite(book),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Center cover
                    children: [
                       // Hero Cover
                       _buildHeroCover(context, isDark),
                       const SizedBox(height: 24),
                       
                       // Title & Author
                       Text(
                         book.title,
                         textAlign: TextAlign.center,
                         style: GoogleFonts.notoKufiArabic(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: isDark ? Colors.white : Colors.black87,
                         ),
                       ),
                       const SizedBox(height: 8),
                       Text(
                         book.author,
                         textAlign: TextAlign.center,
                         style: GoogleFonts.notoKufiArabic(
                           fontSize: 16,
                           color: Colors.grey[500],
                         ),
                       ),
                       const SizedBox(height: 32),
                       
                       // Stats Bar
                       _buildStatsBar(context, isDark),
                       const SizedBox(height: 32),
                       
                       // Action Buttons
                       _buildActionButtons(context),
                       const SizedBox(height: 32),
                       
                       // Summary
                       _buildSummarySection(context, isDark),
                       const SizedBox(height: 32),
                       
                       // Key Takeaways
                       _buildTakeawaysSection(context, isDark),
                       
                       const SizedBox(height: 120), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildHeroCover(BuildContext context, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
         // Blur Effect Background
         Container(
           width: 160, height: 240,
           transform: Matrix4.translationValues(0, 20, 0),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(20),
             color: AppColors.newPrimary.withOpacity(0.4),
             boxShadow: [
               BoxShadow(color: AppColors.newPrimary.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
             ],
           ),
         ),
         // Actual Image
         Hero(
           tag: heroTag ?? 'detail-${book.id}',
           child: ClipRRect(
             borderRadius: BorderRadius.circular(16),
             child: CachedNetworkImage(
               imageUrl: book.cover,
               width: 180,
               height: 270,
               fit: BoxFit.cover,
               placeholder: (_,__) => Container(color: Colors.grey[200]),
             ),
           ),
         ),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, Icons.star_rounded, book.rating.toString(), 'التقييم', Colors.amber),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, Icons.category_rounded, book.category, 'الفئة', AppColors.newPrimary),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, Icons.timer_rounded, '18 د', 'المدة', isDark ? Colors.white70 : Colors.black54),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1, height: 30,
      color: isDark ? Colors.grey[700] : Colors.grey[200],
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color iconColor) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(icon, size: 16, color: iconColor),
             const SizedBox(width: 4),
             Text(
               value,
               style: GoogleFonts.manrope(
                 fontSize: 14,
                 fontWeight: FontWeight.bold,
                 color: isDark ? Colors.white : Colors.black87,
               ),
             ),
           ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              final provider = Provider.of<AppProvider>(context, listen: false);
              provider.playBook(book); // Start global playback
              Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(book: book)));
            },
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            label: Text('استمع الآن', style: GoogleFonts.notoKufiArabic(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimary,
              elevation: 4,
              shadowColor: AppColors.newPrimary.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(book: book))), // Same for demo, reader mode inside
            icon: const Icon(Icons.menu_book_rounded, color: AppColors.newPrimary),
            label: Text('اقرأ الملخص', style: GoogleFonts.notoKufiArabic(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.newPrimary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.newPrimary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.newPrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(
              'عن هذا الملخص',
              style: GoogleFonts.notoKufiArabic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          book.description,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 14,
            height: 1.8,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTakeawaysSection(BuildContext context, bool isDark) {
    final points = [
      'التركيز على الأنظمة بدلاً من الأهداف للوصول لنتائج مستدامة.',
      'تطبيق القوانين الأربعة لتغيير السلوك.',
      'أهمية الهوية: غيّر من "من تكون" وليس فقط "ماذا تفعل".',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.newPrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(
              'أهم النقاط',
              style: GoogleFonts.notoKufiArabic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...points.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.newPrimary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p,
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
