import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../constants.dart';
import 'book_detail_screen.dart';

class CategoryBooksScreen extends StatelessWidget {
  final String categoryName;
  final List<Book> books; 

  const CategoryBooksScreen({super.key, required this.categoryName, required this.books});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF122111) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: Text(
          categoryName,
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: books.isEmpty 
        ? Center(
            child: Text(
              'لا توجد كتب في هذا التصنيف حالياً',
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: books.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookCard(context, book, isDark);
            },
          ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: 'cat-${book.id}')));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'cat-${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.cover,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        book.rating.toString(),
                        style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("15 دقيقة", style: GoogleFonts.manrope(fontSize: 10, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: Colors.grey[400]), // Arabic RTL arrow is LEFT
          ],
        ),
      ),
    );
  }
}
