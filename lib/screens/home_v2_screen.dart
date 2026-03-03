import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants.dart';
import 'book_detail_screen.dart';
import 'search_screen.dart';
import '../models/book.dart';
import 'audio_player_screen.dart';
import 'profile_screen.dart';


class HomeV2Screen extends StatelessWidget {
  const HomeV2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<AppProvider>(context);
    final displayBooks = provider.liveBooks.isNotEmpty ? provider.liveBooks : dummyBooks;
    
    // Ensure we have books to show
    final featuredBook = displayBooks.isNotEmpty ? displayBooks[0] : null;
    final newestBooks = displayBooks.length > 1 ? displayBooks.sublist(1) : [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(context, isDark),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 150), // Space for bottom player/nav
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        
                        // Featured Summary (Daily Pick)
                        if (featuredBook != null)
                          _buildDailySummary(context, isDark, featuredBook),
                        
                        const SizedBox(height: 32),
                        
                        // Latest Summaries List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'أحدث الملخصات',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                   // Navigate to all books or categories
                                   Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
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
                        
                        const SizedBox(height: 16),
                        
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: newestBooks.length > 5 ? 5 : newestBooks.length, // Show max 5 in this list
                          separatorBuilder: (_, __) => const SizedBox(height: 24),
                          itemBuilder: (context, index) {
                            return _buildBookItem(context, newestBooks[index], isDark);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Sticky Player & Nav
            // Positioned(
            //   left: 0, 
            //   right: 0, 
            //   bottom: 0,
            //   child: _buildBottomSection(context, isDark, featuredBook), 
            // ),
            // Note: Navigation and Mini Player are handled by MainScreen or a global overlay to be persistent.
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final provider = Provider.of<AppProvider>(context);
    final userName = provider.userName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك في موجز',
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'صباح الخير، $userName',
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.newPrimary.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.2)),
              ),
               child: ClipOval(
                 child: Image.network(
                   "https://lh3.googleusercontent.com/aida-public/AB6AXuABDCP5UguiaQCOwdw7qf40ABuzVkg-Ir9Kf16UKP5Mb5cuTqyQprKYWY89xXSuJ-FdgEVdpveF-vxE7fijF-eexRvqtaoqeiHei1injQlKr4NrdI2SU8NqFaF1POx2eRux4e6zkDZpPvXTjSA_DCt9DjcDVCtWnz428AkXxtIv1RRklNxRVcDWMW0Yo_DN88L6_NRwI5uuYzJjBQXp1zC23aOlIM0DBzmzZkc4wrXdJ2AajvL9KmKBZSPFf4uIfxwpla1i7UrGlKj3",
                   fit: BoxFit.cover,
                   errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: AppColors.newPrimary),
                 ),
               ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(BuildContext context, bool isDark, Book book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ملخص اليوم المميز',
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.newPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          InkWell(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: 'featured-${book.id}')));
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                 children: [
                   // Image Stack
                   Stack(
                     children: [
                        AspectRatio(
                          aspectRatio: 4/5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: book.cover,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                            ),
                          ),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Content Overlay
                        Positioned(
                          bottom: 24,
                          right: 24,
                          left: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.newPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  book.category,
                                  style: GoogleFonts.notoKufiArabic(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                book.title,
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.subtitle ?? 'كيف تنجز أكثر في وقت أقل', // Fallback subtitle or description
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                     ],
                   ),
                   
                   // Info Bar below image (Design shows inside image area or separate? 
                   // The design shows it BELOW the image but visually integrated or separate? 
                   // Looking at the HTML, it's separate below "aspect-[4/5]" block? 
                   // Ah, the HTML shows "flex items-center justify-between" BELOW the image container in the "flex flex-col gap-6"
                   // Let's replicate that structure.
                 ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                 children: [
                   _buildInfoColumn("مدة الملخص", "15 دقيقة", isDark),
                   Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 16)),
                   _buildInfoColumn("المؤلف", book.author, isDark),
                 ],
               ),
               
               GestureDetector(
                 onTap: () {
                   // Play button: open AudioPlayerScreen directly
                   final appProvider = Provider.of<AppProvider>(context, listen: false);
                   appProvider.playBook(book);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(book: book)));
                 },
                 child: Container(
                   width: 48,
                   height: 48,
                   decoration: BoxDecoration(
                     color: AppColors.newPrimary,
                     shape: BoxShape.circle,
                     boxShadow: [
                       BoxShadow(
                         color: AppColors.newPrimary.withValues(alpha: 0.3),
                         blurRadius: 10,
                         offset: const Offset(0, 4),
                       )
                     ],
                   ),
                   child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 10,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBookItem(BuildContext context, Book book, bool isDark) {
     return InkWell(
       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: 'list-${book.id}'))),
       borderRadius: BorderRadius.circular(16),
       child: Row(
         children: [
            // Cover
            Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: book.cover,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.category,
                    style: GoogleFonts.notoKufiArabic(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       color: AppColors.newPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoKufiArabic(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: GoogleFonts.notoKufiArabic(
                       fontSize: 12,
                       color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Metadata Icons
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("15 دقيقة", style: GoogleFonts.notoKufiArabic(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Icon(Icons.headset_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("4.8 ك", style: GoogleFonts.notoKufiArabic(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
              onPressed: () {},
            ),
         ],
       ),
     );
  }

  Widget _buildBottomSection(BuildContext context, bool isDark, Book? currentBook) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.newBackgroundDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player — self-managed via Consumer<AppProvider>
          _buildMiniPlayer(context, isDark),
             
          // Bottom Nav
          _buildBottomNav(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, bool isDark) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!provider.showMiniPlayer || provider.currentPlayingBook == null) {
          return const SizedBox.shrink();
        }
        final currentBook = provider.currentPlayingBook!;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => AudioPlayerScreen(book: currentBook))
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                     imageUrl: currentBook.cover,
                     width: 40,
                     height: 40,
                     fit: BoxFit.cover,
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBook.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: 0.3,
                          minHeight: 3,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.newPrimary),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    // Close/Stop button
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 18),
                      onPressed: () => provider.stopPlayback(),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    const SizedBox(width: 4),
                    // Play/Pause button
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.newPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => provider.togglePlayPause(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    // This could be integrated into MainScreen for state management, 
    // but building the visuals here as part of the "Home" UI update request.
    // In a real refactor, this should replace the BottomNavigationBar in MainScreen.
    // For now, it's a visual representation. We will need to update MainScreen to use this new layout logic.
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_rounded, "الرئيسية", true),
          _buildNavItem(Icons.search_rounded, "البحث", false),
          _buildNavItem(Icons.auto_stories_rounded, "مكتبتي", false),
          _buildNavItem(Icons.person_outline_rounded, "حسابي", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.newPrimary : Colors.grey[400],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.newPrimary : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
