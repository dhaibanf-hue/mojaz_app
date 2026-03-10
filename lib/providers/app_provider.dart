/// AppProvider - Backward Compatibility Facade
/// 
/// This file delegates to the new split providers for backward compatibility.
/// New code should import the specific providers directly:
///   - AuthProvider (auth_provider.dart)
///   - BooksProvider (books_provider.dart)
///   - AudioPlayerProvider (audio_player_provider.dart)
///   - ThemeProvider (theme_provider.dart)

export 'auth_provider.dart';
export 'books_provider.dart';
export 'audio_player_provider.dart';
export 'theme_provider.dart';
