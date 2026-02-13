import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Book>> fetchBooks() async {
    try {
      final response = await supabase.from('books').select().order('created_at', ascending: false);
      return (response as List).map((b) => Book.fromMap(b)).toList();
    } catch (e) {
      debugPrint('Error fetching books: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> uploadFile(PlatformFile file, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = '$folder/$fileName';

    try {
      if (kIsWeb) {
        if (file.bytes == null) return {'success': false, 'error': 'لم يتم العثور على بيانات الملف (bytes is null)'};
        
        // جلب نوع الملف (MIME Type) بشكل يدوي للويب
        final extension = file.extension?.toLowerCase();
        String contentType = 'application/octet-stream';
        if (extension == 'jpg' || extension == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (extension == 'png') {
          contentType = 'image/png';
        } else if (extension == 'mp3') {
          contentType = 'audio/mpeg';
        }

        // استخدام uploadBinary فهو الأنسب للبيانات الرقمية (Uint8List) على الويب
        await supabase.storage.from('book-assets').uploadBinary(
          path, 
          file.bytes!,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );
      } else {
        await supabase.storage.from('book-assets').upload(
          path, 
          File(file.path!),
          fileOptions: const FileOptions(upsert: true),
        );
      }
      return {'success': true, 'url': supabase.storage.from('book-assets').getPublicUrl(path)};
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addBook(Map<String, dynamic> bookData) async {
    try {
      await supabase.from('books').insert(bookData);
      return {'success': true};
    } catch (e) {
      debugPrint('Error adding book: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
