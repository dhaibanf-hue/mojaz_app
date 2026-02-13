import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../constants.dart';
import 'audio_player_screen.dart';
import '../providers/app_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  final String? heroTag;

  const BookDetailScreen({super.key, required this.book, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isDownloaded = provider.downloadedBookIds.contains(book.id);
    final bool isFavorite = provider.favoriteBookIds.contains(book.id);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isFavorite, provider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildMainInfo(context, isDark),
                   const SizedBox(height: 32),
                   _buildActionButtons(context, provider, isDownloaded),
                   const SizedBox(height: 32),
                   _buildDescription(context),
                   const SizedBox(height: 32),
                   _buildKeyTerms(context),
                   const SizedBox(height: 32),
                   _buildCommunitySection(context, provider),
                   const SizedBox(height: 32),
                   _buildGiftSection(context),
                   const SizedBox(height: 120),
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: _buildBottomPlayButton(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isFavorite, AppProvider provider) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.primaryBg,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
          onPressed: () => provider.toggleFavorite(book.id),
        ),
        IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: heroTag ?? 'book-${book.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: book.cover, 
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.book, color: Colors.grey, size: 50),
                ),
              ),
              Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black54, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
        const SizedBox(height: 8),
        Text(book.author, style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoChip(Icons.star, book.rating.toString(), AppColors.gold),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.timer, '15 دقيقة', Colors.blue),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.category, book.category, AppColors.primaryButton),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppProvider provider, bool isDownloaded) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => provider.toggleDownload(book.id),
            icon: Icon(isDownloaded ? Icons.download_done : Icons.download, size: 18),
            label: Text(isDownloaded ? 'كتاب محمل' : 'تحميل أوفلاين'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDownloaded ? AppColors.success : AppColors.primaryButton,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عن هذا الملخص', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
        const SizedBox(height: 12),
        Text(book.description, style: const TextStyle(height: 1.6, color: AppColors.secondaryText)),
      ],
    );
  }

  Widget _buildKeyTerms(BuildContext context) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مصطلحات أساسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: ['العقلية النامية', 'التدفق العملي', 'الإنتاجية القصوى'].map((term) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.secondaryText.withValues(alpha: 0.1))),
            child: Text(term, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.accent.withValues(alpha: 0.1))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: AppColors.accent),
              const SizedBox(width: 12),
              Text('نقاش المجتمع (${provider.communityMembers})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('شارك أفكارك مع قرّاء آخرين ناقشوا هذا الكتاب مؤخراً.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('دخول غرفة النقاش'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGiftSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.pink.withValues(alpha: 0.1))),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.pink),
          const SizedBox(width: 12),
          const Expanded(child: Text('أهدِ هذا الملخص لصديق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          TextButton(onPressed: () {}, child: const Text('إرسال هدية', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildBottomPlayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(book: book))),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryButton, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('ابدأ الاستماع الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
