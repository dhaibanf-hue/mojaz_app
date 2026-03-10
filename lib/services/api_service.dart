import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../utils/app_exception.dart';

class ApiService {
  final _client = Supabase.instance.client;

  /// Default timeout for all API requests.
  static const _requestTimeout = Duration(seconds: 15);

  /// Maximum retry attempts for failed requests.
  static const _maxRetries = 1;

  /// Internal helper: executes a request with timeout and retry logic.
  /// Throws [AppException] subtypes on failure.
  Future<T> _executeWithRetry<T>(
    Future<T> Function() request, {
    String operationName = 'request',
  }) async {
    int attempts = 0;

    while (true) {
      try {
        return await request().timeout(_requestTimeout, onTimeout: () {
          throw TimeoutException();
        });
      } on TimeoutException {
        rethrow;
      } on AppException {
        rethrow;
      } catch (e) {
        attempts++;
        if (attempts > _maxRetries) {
          // Classify the error
          final errorMsg = e.toString().toLowerCase();
          if (errorMsg.contains('socket') ||
              errorMsg.contains('connection') ||
              errorMsg.contains('network') ||
              errorMsg.contains('host')) {
            throw NetworkException();
          }
          throw ServerException(
              'فشل في $operationName: ${e.toString()}');
        }
        debugPrint('[$operationName] Attempt $attempts failed: $e. Retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // 1. Fetch all books from Supabase 'books' table
  Future<List<Book>> fetchBooks() async {
    return _executeWithRetry(
      () async {
        final List<dynamic> data = await _client
            .from('books')
            .select()
            .order('created_at', ascending: false);

        try {
          return data.map((item) => Book.fromMap(item)).toList();
        } catch (e) {
          throw ParseException('خطأ في تحويل بيانات الكتب: $e');
        }
      },
      operationName: 'جلب الكتب',
    );
  }

  // 2. Fetch specific book details
  Future<Book?> fetchBookDetails(String id) async {
    return _executeWithRetry(
      () async {
        final data = await _client
            .from('books')
            .select()
            .eq('id', id)
            .single();

        try {
          return Book.fromMap(data);
        } catch (e) {
          throw ParseException('خطأ في تحويل تفاصيل الكتاب: $e');
        }
      },
      operationName: 'جلب تفاصيل الكتاب',
    );
  }

  // 3. Search books by title or author
  Future<List<Book>> searchBooks(String query) async {
    return _executeWithRetry(
      () async {
        final List<dynamic> response = await _client
            .from('books')
            .select()
            .or('title.ilike.%$query%,author.ilike.%$query%');

        try {
          return response.map((json) => Book.fromMap(json)).toList();
        } catch (e) {
          throw ParseException('خطأ في تحويل نتائج البحث: $e');
        }
      },
      operationName: 'البحث في الكتب',
    );
  }

  // 4. User Progress Sync
  Future<void> syncProgress(String bookId, int seconds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    return _executeWithRetry(
      () async {
        await _client.from('user_progress').upsert({
          'user_id': userId,
          'book_id': bookId,
          'last_position_seconds': seconds,
          'updated_at': DateTime.now().toIso8601String(),
        });
      },
      operationName: 'مزامنة التقدم',
    );
  }
}
