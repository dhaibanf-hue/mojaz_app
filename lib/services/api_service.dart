import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';

class ApiService {
  final _client = Supabase.instance.client;

  // 1. Fetch all books from Supabase 'books' table
  Future<List<Book>> fetchBooks() async {
    try {
      final List<dynamic> data = await _client
          .from('books')
          .select()
          .order('created_at', ascending: false);
          
      return data.map((item) => Book.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error fetching books from Supabase: $e');
      // Fallback to empty list or handle error in UI
      return [];
    }
  }

  // 2. Fetch specific book details
  Future<Book?> fetchBookDetails(String id) async {
    try {
      final data = await _client
          .from('books')
          .select()
          .eq('id', id)
          .single();
          
      return Book.fromMap(data);
    } catch (e) {
      debugPrint('Error fetching book details: $e');
      return null;
    }
  }

  // 3. User Progress Sync
  Future<void> syncProgress(String bookId, int seconds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('user_progress').upsert({
        'user_id': userId,
        'book_id': bookId,
        'last_position_seconds': seconds,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error syncing progress: $e');
    }
  }
}
