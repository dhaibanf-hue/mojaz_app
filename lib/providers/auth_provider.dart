import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles user authentication state, profile data, interests, and points.
class AuthProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _initialized = false;
  bool get initialized => _initialized;

  // User State
  bool _isGuest = true;
  String _userName = 'ضيف';
  String _userEmail = 'guest@moujaz.app';
  String _userPhone = '';

  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  // Points
  int _points = 0;
  int get points => _points;

  // Interests Data
  String _readingGoal = '';
  List<String> _selectedInterests = [];
  String _learningStyle = '';
  int _dailyTime = 0;

  String get readingGoal => _readingGoal;
  List<String> get selectedInterests => _selectedInterests;
  String get learningStyle => _learningStyle;
  int get dailyTime => _dailyTime;

  // Community
  int _communityCount = 1250;
  int get communityMembers => _communityCount;

  // Reminders
  bool _remindersEnabled = true;
  bool get remindersEnabled => _remindersEnabled;

  // Streaks & Challenges
  int streak = 5;
  double weeklyGoalProgress = 0.65;

  AuthProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _isGuest = _prefs.getBool('isGuest') ?? true;
    _userName = _prefs.getString('userName') ?? 'ضيف';
    _userEmail = _prefs.getString('userEmail') ?? 'guest@moujaz.app';
    _userPhone = _prefs.getString('userPhone') ?? '';

    // Load points
    _points = _prefs.getInt('points') ?? 0;

    // Load interests
    _readingGoal = _prefs.getString('readingGoal') ?? '';
    _selectedInterests = _prefs.getStringList('selectedInterests') ?? [];
    _learningStyle = _prefs.getString('learningStyle') ?? '';
    _dailyTime = _prefs.getInt('dailyTime') ?? 0;

    fetchCommunityCount();

    _initialized = true;
    notifyListeners();
  }

  void loginAsUser(String name, String email, {String phone = ''}) {
    _isGuest = false;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _prefs.setBool('isGuest', false);
    _prefs.setString('userName', name);
    _prefs.setString('userEmail', email);
    if (phone.isNotEmpty) _prefs.setString('userPhone', phone);
    notifyListeners();
  }

  Future<void> updateUserData({required String name, required String phone}) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    _userName = name;
    _userPhone = phone;
    _prefs.setString('userName', name);
    _prefs.setString('userPhone', phone);
    notifyListeners();

    if (userId != null) {
      try {
        await client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
              'phone': phone,
            },
          ),
        );
        await client.from('profiles').upsert({
          'id': userId,
          'full_name': name,
          'phone': phone,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint("Error updating user data in Supabase: $e");
      }
    }
  }

  void logout() {
    _isGuest = true;
    _userName = 'ضيف';
    _userEmail = 'guest@moujaz.app';
    _prefs.setBool('isGuest', true);
    _prefs.remove('userName');
    _prefs.remove('userEmail');
    _prefs.remove('userPhone');
    notifyListeners();
  }

  void updatePoints(int extraPoints) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    _points += extraPoints;
    _prefs.setInt('points', _points);
    notifyListeners();

    if (userId != null) {
      try {
        await client.rpc('increment_points', params: {'user_id': userId, 'amount': extraPoints});
      } catch (e) {
        debugPrint("Point sync error: $e");
      }
    }
  }

  void saveInterestData(String goal, List<String> interests, String style, int time) {
    _readingGoal = goal;
    _selectedInterests = interests;
    _learningStyle = style;
    _dailyTime = time;

    _prefs.setString('readingGoal', goal);
    _prefs.setStringList('selectedInterests', interests);
    _prefs.setString('learningStyle', style);
    _prefs.setInt('dailyTime', time);
    notifyListeners();
  }

  Future<void> fetchCommunityCount() async {
    try {
      final client = Supabase.instance.client;
      final List<dynamic> response = await client.from('profiles').select('id').limit(100);
      _communityCount = 1250 + response.length;
      notifyListeners();
    } catch (e) {
      _communityCount = 1250;
      notifyListeners();
      debugPrint("Error fetching community count: $e");
    }
  }

  void toggleReminders() {
    _remindersEnabled = !_remindersEnabled;
    notifyListeners();
  }
}
