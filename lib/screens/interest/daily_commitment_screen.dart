import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../utils/route_transitions.dart';

class DailyCommitmentScreen extends StatefulWidget {
  const DailyCommitmentScreen({super.key});

  @override
  State<DailyCommitmentScreen> createState() => _DailyCommitmentScreenState();
}

class _DailyCommitmentScreenState extends State<DailyCommitmentScreen> {
  int _selectedOption = 1; // 1: 15min default

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgLight = AppColors.newBackgroundLight;
    Color bgDark = AppColors.newBackgroundDark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        title: Text(
          'الخطوة 4 من 4',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_forward, size: 20, color: isDark ? Colors.grey[300] : Colors.grey[700]), // Back arrow RTL but icon is forward in design usually in RTL apps
             onPressed: () => Navigator.pop(context), 
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF27272A) : Colors.grey[100],
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: 1.0, // Step 4 of 4 = 100%
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
                    const SizedBox(height: 24),
                    Text(
                      'كم من الوقت تود تخصيصه يومياً لموجز؟',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سنساعدك في الوصول لأهدافك المعرفية بناءً على وقتك المتاح.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    _buildOption(
                      index: 0,
                      label: '5 دقائق',
                      description: 'سريع - ملخص واحد يومياً',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      index: 1,
                      label: '15 دقيقة',
                      description: 'متعمق - المستوى المثالي للتعلم',
                      isDark: isDark,
                      isRecommended: true,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      index: 2,
                      label: '30 دقيقة',
                      description: 'نهم - لمحبي القراءة والاستكشاف',
                      isDark: isDark,
                    ),
                    
                    const Spacer(),
                    
                    // Visual Support
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.newPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.insights, size: 36, color: AppColors.newPrimary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'اختيارك يساعدنا في تخصيص مكتبتك المعرفية بشكل أفضل.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[300] : Colors.grey[800],
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Footer Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to loading/plan creation screen
                    Navigator.push(
                      context,
                      FadeThroughPageRoute(page: const LoadingPlanScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newPrimary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.newPrimary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                       Text(
                        'ابدأ رحلتي المعرفية',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.auto_stories),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required int index,
    required String label,
    required String description,
    required bool isDark,
    bool isRecommended = false,
  }) {
    bool isSelected = _selectedOption == index;
    Color borderCol = isSelected 
        ? AppColors.newPrimary 
        : (isDark ? const Color(0xFF27272A) : Colors.grey[200]!);
    Color bgCol = isSelected 
        ? AppColors.newPrimary.withValues(alpha: isDark ? 0.2 : 0.05)
        : Colors.transparent;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderCol,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.newPrimary : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                  width: 2,
                ),
                color: isSelected ? AppColors.newPrimary : Colors.transparent,
              ),
              child: isSelected 
                  ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.newPrimary : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontStyle: FontStyle.italic,
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
}

// Minimal Loading Screen for transition
class LoadingPlanScreen extends StatefulWidget {
  const LoadingPlanScreen({super.key});

  @override
  State<LoadingPlanScreen> createState() => _LoadingPlanScreenState();
}

class _LoadingPlanScreenState extends State<LoadingPlanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    // Simulate loading finishing
    Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
             Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     AppColors.newPrimary.withValues(alpha: 0.05),
                     Colors.transparent
                   ]
                 )
               ),
             ),
          ),
          
          Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               // Animated Book Icon
               Center(
                 child: Container(
                   width: 120,
                   height: 120,
                   decoration: BoxDecoration(
                     color: isDark ? const Color(0xFF1E293B) : Colors.white,
                     borderRadius: BorderRadius.circular(24),
                     boxShadow: [
                       BoxShadow(
                         color: AppColors.newPrimary.withValues(alpha: 0.2),
                         blurRadius: 20,
                         spreadRadius: 5,
                       )
                     ],
                     border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.2)),
                   ),
                   child: Stack(
                     alignment: Alignment.center,
                     children: [
                        Icon(Icons.auto_stories, size: 48, color: AppColors.newPrimary),
                        // Loading Ring
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.newPrimary.withValues(alpha: 0.5)),
                            strokeWidth: 2,
                          ),
                        ),
                     ],
                   ),
                 ),
               ),
               const SizedBox(height: 40),
               
               Text(
                 'جاري إعداد خطتك المعرفية المخصصة...',
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: isDark ? Colors.white : const Color(0xFF1E293B),
                 ),
               ),
               
               const SizedBox(height: 20),
               
               // Checklist
               _buildCheckItem("تحليل اهتماماتك", true, isDark),
               _buildCheckItem("اختيار أفضل الملخصات لك", true, isDark, isActive: true),
               _buildCheckItem("تنسيق جدولك اليومي", false, isDark),
               
             ],
          ),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                 Icon(Icons.format_quote, color: AppColors.newPrimary.withValues(alpha: 0.5), size: 30),
                 const SizedBox(height: 8),
                 Text(
                   '"المعرفة هي القوة، ونحن نجهز لك أقصر الطرق إليها"',
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     fontStyle: FontStyle.italic,
                     color: Colors.grey[500],
                     fontSize: 14,
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, bool isCompleted, bool isDark, {bool isActive = false}) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
       child: Row(
         children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.newPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: isCompleted ? null : Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child: isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                 color: isActive 
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
            ),
         ],
       ),
     );
  }
}
