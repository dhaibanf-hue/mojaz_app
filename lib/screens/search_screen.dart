import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/book.dart';
import '../providers/app_provider.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];


  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  double _minRating = 0;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    final allBooks = provider.liveBooks.isNotEmpty ? provider.liveBooks : dummyBooks;

    setState(() {
      _searchResults = allBooks.where((book) {
        final queryLower = query.toLowerCase();
        final matchesQuery = book.title.toLowerCase().contains(queryLower) ||
               book.author.toLowerCase().contains(queryLower) ||
               book.category.toLowerCase().contains(queryLower);
        final matchesRating = book.rating >= _minRating;
        return matchesQuery && matchesRating;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchField(context, isDark),
        actions: [
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              child: const Text('إلغاء', style: TextStyle(color: AppColors.primaryButton)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _searchController.text.isEmpty ? _buildDiscoveryView(context, isDark) : _buildResultsView(context),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: false,
        onChanged: _performSearch,
        decoration: InputDecoration(
          hintText: 'ابحث عن الكتب، المؤلفين أو التصنيفات...',
          hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDiscoveryView(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader('اكتشف تصنيفات تهمك'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCategoryChip('تطوير ذات', Icons.psychology_outlined),
                  _buildCategoryChip('إدارة أعمال', Icons.business_center_outlined),
                  _buildCategoryChip('علم نفس', Icons.favorite_border_rounded),
                  _buildCategoryChip('تاريخ', Icons.history_edu_rounded),
                  _buildCategoryChip('تكنولوجيا', Icons.biotech_outlined),
                  _buildCategoryChip('روايات', Icons.auto_stories_outlined),
                ],
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('عمليات البحث الشائعة'),
              const SizedBox(height: 16),
              _buildTrendingItem('الذكاء العاطفي'),
              _buildTrendingItem('ريادة الأعمال في العصر الرقمي'),
              _buildTrendingItem('فن اللامبالاة'),
              _buildTrendingItem('قوة العادات'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          FilterChip(
            label: const Text('الكل', style: TextStyle(fontSize: 12)),
            selected: _minRating == 0,
            onSelected: (v) => setState(() {
               _minRating = 0;
               if (_searchController.text.isNotEmpty) _performSearch(_searchController.text);
            }),
            selectedColor: AppColors.primaryButton.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primaryButton,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('4.5+ ⭐', style: TextStyle(fontSize: 12)),
            selected: _minRating == 4.5,
            onSelected: (v) => setState(() {
               _minRating = v ? 4.5 : 0;
               if (_searchController.text.isNotEmpty) _performSearch(_searchController.text);
            }),
            selectedColor: AppColors.primaryButton.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primaryButton,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('4.8+ ⭐', style: TextStyle(fontSize: 12)),
            selected: _minRating == 4.8,
            onSelected: (v) => setState(() {
               _minRating = v ? 4.8 : 0;
               if (_searchController.text.isNotEmpty) _performSearch(_searchController.text);
            }),
            selectedColor: AppColors.primaryButton.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primaryButton,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return ActionChip(
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
      avatar: Icon(icon, size: 16, color: AppColors.primaryButton),
      label: Text(label),
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.secondaryText.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildTrendingItem(String text) {
    return ListTile(
      leading: const Icon(Icons.trending_up, color: AppColors.secondaryText, size: 20),
      title: Text(text, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_outward_rounded, size: 14, color: AppColors.secondaryText),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
    );
  }

  Widget _buildResultsView(BuildContext context) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('لم نجد نتائج مطابقة لبحثك', style: TextStyle(color: AppColors.secondaryText)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, heroTag: 'search-${book.id}')),
            );
          },
          leading: Hero(
            tag: 'search-${book.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(book.cover, width: 50, height: 70, fit: BoxFit.cover),
            ),
          ),
          title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.author, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(book.category, style: const TextStyle(color: AppColors.primaryButton, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          isThreeLine: true,
        );
      },
    );
  }
}
