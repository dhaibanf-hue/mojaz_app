class Book {
  final String id;
  final String title;
  final String author;
  final String cover;
  final double rating;
  final String description;
  final String category;
  final int pageCount;
  final bool isPremium;
  final String? targetAudience;
  final String audioUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.rating,
    required this.description,
    required this.category,
    required this.pageCount,
    this.isPremium = false,
    this.targetAudience,
    required this.audioUrl,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      author: map['author'] ?? 'Unknown Author',
      cover: _fixUrl(map['cover_image_url']) ?? 'https://picsum.photos/200/300',
      rating: 4.5,
      description: map['summary'] ?? '',
      category: map['category'] != null ? map['category']['name'] : 'عام',
      pageCount: 15,
      isPremium: false,
      audioUrl: _fixUrl(map['audio_file_url']) ?? '',
    );
  }

  // Helper helper to make localhost URLs work on Android Emulator
  static String? _fixUrl(String? url) {
    if (url == null) return null;
    // Current machine IP for physical device testing
    const String machineIp = '192.168.88.249'; 
    if (url.contains('127.0.0.1') || url.contains('localhost')) {
      return url.replaceFirst(RegExp(r'(127\.0\.0\.1|localhost)'), machineIp);
    }
    return url;
  }
}
