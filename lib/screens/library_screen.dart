import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/book.dart';
import '../providers/app_provider.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _tabController = TabController(length: 4, vsync: this, initialIndex: provider.libraryInitialTab);
    
    // Listen for tab changes from other screens (like Profile)
    provider.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (_tabController.index != provider.libraryInitialTab) {
      _tabController.animateTo(provider.libraryInitialTab);
    }
  }

  @override
  void dispose() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.removeListener(_onProviderChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    final inProgress = dummyBooks.take(2).toList();
    final completed = dummyBooks.skip(2).take(1).toList();
    final saved = dummyBooks.where((b) => provider.downloadedBookIds.contains(b.id)).toList();
    final favorites = dummyBooks.where((b) => provider.favoriteBookIds.contains(b.id)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'مكتبتي',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color, 
            fontWeight: FontWeight.bold
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryButton,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primaryButton,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorWeight: 3,
          onTap: (index) => provider.setLibraryTab(index),
          tabs: const [
            Tab(text: 'قيد القراءة'),
            Tab(text: 'تم الإنجاز'),
            Tab(text: 'المحملة'),
            Tab(text: 'المفضلة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookList(context, inProgress, true),
          _buildBookList(context, completed, false),
          _buildBookList(context, saved, false),
          _buildBookList(context, favorites, false),
        ],
      ),
    );
  }

  Widget _buildBookList(BuildContext context, List<Book> books, bool showProgress) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text(
              'مكتبتك تنتظر أول كتاب!', 
              style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: books.length,
      separatorBuilder: (c, i) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => BookDetailScreen(book: book),
               ),
             );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(color: AppColors.secondaryText.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'lib-${book.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      book.cover,
                      width: 70,
                      height: 100,
                      fit: BoxFit.cover,
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 16),
                      if (showProgress) 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('أنهيت 60%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryButton)),
                                Text('باقي 5 دقائق', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: 0.6,
                                minHeight: 6,
                                backgroundColor: AppColors.primaryButton.withValues(alpha: 0.1),
                                color: AppColors.primaryButton,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: AppColors.success.withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: const Text('مكتمل', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text('15 يناير 2024', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
