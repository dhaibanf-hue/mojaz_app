import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/app_provider.dart';
import 'edit_profile_screen.dart';
import '../utils/route_transitions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final booksProvider = Provider.of<BooksProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // Header & Profile Card
               _buildModernHeader(context, authProvider, isDark),
              
              // Gamified Rank Card
              _buildRankCard(context, authProvider, isDark),

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نشاطك هذا الأسبوع',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(context, '${booksProvider.completedBookIds.length}', 'ملخصات منجزة', Icons.check_circle_rounded, isDark),
                        const SizedBox(width: 12),
                        _buildStatCard(context, '${booksProvider.totalListeningMinutes}', 'دقيقة استماع', Icons.timer_rounded, isDark),
                      ],
                    ),
                  ],
                ),
              ),

              // Achievements Section
              _buildAchievementsSection(context, isDark),

              // Menu Options
              _buildMenuSection(context, themeProvider, isDark),
              
              const SizedBox(height: 32),
              
              // Logout Button
              _buildLogoutButton(context, authProvider, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, AuthProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.newPrimary.withValues(alpha: 0.1),
            backgroundImage: const NetworkImage('https://picsum.photos/seed/user/200/200'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userName,
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'قارئ مثابر منذ 2024',
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_note_rounded, color: AppColors.newPrimary),
            onPressed: () => Navigator.push(context, FadeThroughPageRoute(page: const EditProfileScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard(BuildContext context, AuthProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFF0F3D3E), const Color(0xFF0A2627)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.newPrimary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رتبة القارئ',
                    style: GoogleFonts.notoKufiArabic(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'خبير المعرفة',
                    style: GoogleFonts.notoKufiArabic(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRankStat(provider.points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'), 'نقطة إنجاز', Icons.auto_awesome_rounded),
              _buildRankDivider(),
              _buildRankStat('${provider.streak}', 'أيام استمرار', Icons.local_fire_department_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.notoKufiArabic(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRankDivider() {
    return Container(height: 30, width: 1, color: Colors.white12);
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.newPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.newPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.notoKufiArabic(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, bool isDark) {
    final achievements = [
      {'icon': '🦉', 'label': 'بومة المعرفة'},
      {'icon': '🔥', 'label': 'المثابر'},
      {'icon': '🎧', 'label': 'المستمع الذهبي'},
      {'icon': '📚', 'label': 'دودة كتب'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'الأوسمة المستحقة',
            style: GoogleFonts.notoKufiArabic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(achievements[index]['icon']!, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      achievements[index]['label']!,
                      style: GoogleFonts.notoKufiArabic(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, ThemeProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'الوضع الليلي',
            trailing: Switch(
              value: provider.isDarkMode,
              onChanged: (v) => provider.toggleTheme(),
              activeColor: AppColors.newPrimary,
            ),
            isDark: isDark,
          ),
          _buildMenuItem(
            icon: Icons.language_rounded,
            title: 'اللغة',
            trailing: const Text('العربية', style: TextStyle(color: Colors.grey)),
            isDark: isDark,
          ),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'مركز المساعدة',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, Widget? trailing, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.newPrimary),
        title: Text(
          title,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton.icon(
        onPressed: () {
          provider.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
        label: Text(
          'تسجيل الخروج',
          style: GoogleFonts.notoKufiArabic(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.05),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
