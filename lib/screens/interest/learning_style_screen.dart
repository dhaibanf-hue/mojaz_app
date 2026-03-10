import 'package:flutter/material.dart';
import '../../constants.dart';
// Just using logic for flow, next is actually daily_commitment in design
import 'daily_commitment_screen.dart';
import '../../utils/route_transitions.dart';

class LearningStyleScreen extends StatefulWidget {
  const LearningStyleScreen({super.key});

  @override
  State<LearningStyleScreen> createState() => _LearningStyleScreenState();
}

class _LearningStyleScreenState extends State<LearningStyleScreen> {
  String _selectedStyle = 'audio'; // audio or reading

  void _next() {
    Navigator.push(
      context,
      FadeThroughPageRoute(page: const DailyCommitmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgLight = AppColors.newBackgroundLight;
    Color bgDark = AppColors.newBackgroundDark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.newPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'خطوة 3 من 4',
          style: TextStyle(
            color: AppColors.newPrimary.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600
          ),
        ),
        actions: [
          TextButton(
            onPressed: _next,
            child: const Text('تخطي', style: TextStyle(color: AppColors.newPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF27272A) : Colors.grey[200],
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: 0.75, // Step 3 of 4 = 75%
                    child: Container(color: AppColors.newPrimary),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'كيف تفضل استهلاك المعرفة؟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'اختر النمط الذي يناسب أسلوب حياتك اليومي لنقوم بتخصيص تجربتك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Audio Option
                    _buildStyleCard(
                      id: 'audio',
                      title: 'الاستماع للملخصات الصوتية',
                      subtitle: 'مثالي أثناء القيادة أو ممارسة الرياضة',
                      icon: Icons.headset,
                      isSelected: _selectedStyle == 'audio',
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: 16),

                    // Reading Option
                    _buildStyleCard(
                      id: 'reading',
                      title: 'قراءة الملخصات المكتوبة',
                      subtitle: 'للتركيز العميق وتدوين الملاحظات',
                      icon: Icons.auto_stories,
                      isSelected: _selectedStyle == 'reading',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.newPrimary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.newPrimary.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'التالي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.chevron_left), // RTL Next
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'يمكنك دائماً تغيير هذا الاختيار لاحقاً من الإعدادات',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    Color selectedBorderColor = AppColors.newPrimary;
    Color unselectedBorderColor = isDark ? const Color(0xFF27272A) : Colors.grey[200]!;
    Color bg = isSelected 
        ? (isDark ? const Color(0xFF1E293B) : Colors.white) 
        : (isDark ? const Color(0xFF18181B) : Colors.white);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected 
             ? [BoxShadow(color: AppColors.newPrimary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
             : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.newPrimary.withValues(alpha: 0.1) : (isDark ? const Color(0xFF27272A) : Colors.grey[50]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.newPrimary : (isDark ? Colors.grey[400] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (isSelected) 
              Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.check_circle, color: AppColors.newPrimary, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}
