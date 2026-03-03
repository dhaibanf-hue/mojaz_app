import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import 'learning_style_screen.dart'; // Next Screen

class CuriosityFieldsScreen extends StatefulWidget {
  const CuriosityFieldsScreen({super.key});

  @override
  State<CuriosityFieldsScreen> createState() => _CuriosityFieldsScreenState();
}

class _CuriosityFieldsScreenState extends State<CuriosityFieldsScreen> {
  final List<String> _selectedInterests = [];

  final List<InterestItem> _interests = [
    InterestItem(id: 'psychology', label: 'علم النفس', icon: Icons.psychology),
    InterestItem(id: 'entrepreneurship', label: 'ريادة الأعمال', icon: Icons.rocket_launch, isPrimaryIcon: true),
    InterestItem(id: 'history', label: 'التاريخ', icon: Icons.history_edu, isPrimaryIcon: true),
    InterestItem(id: 'technology', label: 'التكنولوجيا', icon: Icons.devices),
    InterestItem(id: 'leadership', label: 'القيادة', icon: Icons.groups, isPrimaryIcon: true),
    InterestItem(id: 'finance', label: 'المال', icon: Icons.payments, isPrimaryIcon: true),
    InterestItem(id: 'health', label: 'الصحة', icon: Icons.self_improvement, isPrimaryIcon: true),
    InterestItem(id: 'science', label: 'العلوم', icon: Icons.biotech, isPrimaryIcon: true),
    InterestItem(id: 'literature', label: 'الأدب', icon: Icons.menu_book, isPrimaryIcon: true),
    InterestItem(id: 'arts', label: 'الفنون', icon: Icons.palette, isPrimaryIcon: true),
  ];

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

  void _next() {
      // In a real app, you might validate min 3 selection here
      // if (_selectedInterests.length < 3) return; 

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LearningStyleScreen()),
      );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgLight = AppColors.newBackgroundLight;
    Color bgDark = AppColors.newBackgroundDark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 40), // Spacer
                      Text(
                        'الخطوة ٢ من ٤',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward, size: 20, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                          onPressed: _next, // In design it's forward arrow, effectively "Next" or "Skip"
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF27272A) : Colors.grey[200],
                      child: FractionallySizedBox(
                        alignment: Alignment.centerRight, // RTL
                        widthFactor: 0.5, // Step 2 of 4 = 50%
                        child: Container(color: AppColors.newPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                children: [
                  Text(
                    'ما هي المجالات التي تثير فضولك؟',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر ٣ مجالات على الأقل لنخصص تجربتك.',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: _interests.length,
                    itemBuilder: (context, index) {
                      final item = _interests[index];
                      final isSelected = _selectedInterests.contains(item.id);
                      
                      return _buildInterestTile(item, isSelected, isDark);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: (isDark ? bgDark : bgLight).withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF27272A) : Colors.grey[100]!)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  child: Text(
                    'التالي',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 120,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestTile(InterestItem item, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => _toggleInterest(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.newPrimary 
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.newPrimary 
                : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF1F5F9)),
            width: 2,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.newPrimary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 32,
              color: isSelected 
                  ? Colors.white 
                  : (item.isPrimaryIcon ? AppColors.newPrimary : (isDark ? Colors.white : Colors.black87)),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.grey[200] : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InterestItem {
  final String id;
  final String label;
  final IconData icon;
  final bool isPrimaryIcon;

  InterestItem({
    required this.id,
    required this.label,
    required this.icon,
    this.isPrimaryIcon = false,
  });
}
