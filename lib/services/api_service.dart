
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  // Use machine IP for physical device testing, 127.0.0.1 for browser
  static const String baseUrl = 'http://192.168.88.249:8000/api'; 

  Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data']; 
        return data.map((item) => Book.fromMap(item)).toList();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
      throw Exception('Error fetching books: $e');
    }
  }

  Future<Book> fetchBookDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return Book.fromMap(body['data']);
      } else {
        throw Exception('Failed to load book details');
      }
    } catch (e) {
      debugPrint('Error fetching book details: $e');
      throw Exception('Error fetching book details: $e');
    }
  }
}
