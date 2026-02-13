import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showPlaceholder(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: const Text('هذه الميزة ستكون متاحة قريباً في التحديث القادم!', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, provider),
            const SizedBox(height: 80),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard(
                    context, 
                    'سلسلة القراءة', 
                    '${provider.streak} أيام', 
                    Icons.local_fire_department_rounded, 
                    Colors.orange,
                    isDark
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context, 
                    'تحدي الأسبوع', 
                    '${(provider.weeklyGoalProgress * 100).toInt()}%', 
                    Icons.emoji_events_rounded, 
                    AppColors.gold,
                    isDark
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Premium Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildPremiumCard(context),
            ),

            const SizedBox(height: 32),

            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   _buildSettingsItem(
                    context, 
                    Icons.dark_mode_outlined, 
                    'الوضع الليلي', 
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: provider.isDarkMode,
                        onChanged: (_) => provider.toggleTheme(),
                        activeColor: AppColors.primaryButton,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    isDark: isDark
                  ),
                  _buildSettingsItem(
                    context, 
                    Icons.auto_awesome_outlined, 
                    'التصميم المطور (V2)', 
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: provider.isModernDesign,
                        onChanged: (_) => provider.toggleDesign(),
                        activeColor: AppColors.primaryButton,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    isDark: isDark
                  ),
                  _buildSettingsItem(
                    context, 
                    Icons.favorite_border_rounded, 
                    'كتبي المفضلة', 
                    showArrow: true, 
                    isDark: isDark,
                    onTap: () {
                      provider.setLibraryTab(3); // Favorites tab index
                      provider.setMainTab(2); // Library screen index
                    }
                  ),
                  _buildSettingsItem(context, Icons.watch_outlined, 'مزامنة الساعة الذكية', showArrow: true, isDark: isDark, onTap: () => _showPlaceholder(context, 'مزامنة الساعة')),
                  _buildSettingsItem(context, Icons.person_add_alt_1_outlined, 'ادعُ الأصدقاء (نظام الإحالات)', showArrow: true, isDark: isDark, onTap: () => _showPlaceholder(context, 'نظام الإحالات')),
                  _buildSettingsItem(context, Icons.notifications_none_rounded, 'تنبيهات القراءة', showArrow: true, isDark: isDark, onTap: () => _showPlaceholder(context, 'تنبيهات القراءة')),
                  _buildSettingsItem(context, Icons.help_outline_rounded, 'مركز المساعدة', showArrow: true, isDark: isDark, onTap: () => _showPlaceholder(context, 'مركز المساعدة')),
                  
                  if (provider.isGuest)
                     _buildSettingsItem(
                       context, 
                       Icons.login_rounded, 
                       'تسجيل الدخول', 
                       isDark: isDark,
                       onTap: () {
                         Navigator.of(context).pushAndRemoveUntil(
                           MaterialPageRoute(builder: (context) => const LoginScreen()),
                           (route) => false,
                         );
                       },
                     )
                  else
                    _buildSettingsItem(
                      context, 
                      Icons.logout_rounded, 
                      'تسجيل الخروج', 
                      isDestructive: true, 
                      isDark: isDark,
                      onTap: () {
                        provider.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryBg, 
                AppColors.primaryBg.withValues(alpha: 0.8)
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50), 
              bottomRight: Radius.circular(50)
            ),
          ),
        ),
        Positioned(
          top: 60, left: 24, right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الملف الشخصي', 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white), 
                  onPressed: () {
                    if (provider.isGuest) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    }
                  }
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -60, left: 0, right: 0,
          child: Column(
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)
                  ],
                  image: DecorationImage(
                    image: NetworkImage(provider.isGuest ? 'https://picsum.photos/seed/guest/150/150' : 'https://i.pravatar.cc/300'), 
                    fit: BoxFit.cover
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                provider.userName, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : AppColors.primaryBg,
                )
              ),
              Text(
                provider.isGuest ? 'حساب ضيف' : provider.userEmail,
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Text(
              title, 
              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF323232)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10)
          )
        ]
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, top: -20,
            child: Icon(Icons.star_rounded, size: 100, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Text(
                            'PREMIUM', 
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'موجز بريميوم', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'وصول غير محدود لجميع الملخصات والحصريات الصباحية', 
                      style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4)
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _showPlaceholder(context, 'الاشتراك في بريميوم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold, 
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                ),
                child: const Text('اشترك الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    {Widget? trailing, bool showArrow = false, bool isDestructive = false, required bool isDark, VoidCallback? onTap}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.primaryBg.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon, 
            color: isDestructive ? Colors.red : (isDark ? Colors.white : AppColors.primaryBg), 
            size: 20
          ),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: isDestructive ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        trailing: trailing ?? (showArrow ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText) : null),
        onTap: onTap,
      ),
    );
  }
}
