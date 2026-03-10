import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/app_provider.dart';
import '../../utils/route_transitions.dart';

// ============================================================
// الشاشة الرئيسية الموحدة - 4 خطوات
// ============================================================
class InterestFlowScreen extends StatefulWidget {
  const InterestFlowScreen({super.key});

  @override
  State<InterestFlowScreen> createState() => _InterestFlowScreenState();
}

class _InterestFlowScreenState extends State<InterestFlowScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0; // 0-3 (4 steps)
  final PageController _pageController = PageController();

  // ---- Step 1: Reading Goal ----
  String _selectedGoal = 'growth';

  // ---- Step 2: Curiosity Fields ----
  final List<String> _selectedInterests = [];

  // ---- Step 3: Learning Style ----
  String _selectedStyle = 'audio';

  // ---- Step 4: Daily Commitment ----
  int _selectedTime = 1; // 0:5min, 1:15min, 2:30min

  // ---- Data ----
  final List<_GoalItem> _goals = [
    _GoalItem(id: 'growth', label: 'تطوير الذات', description: 'تحسين المهارات الشخصية والمهنية', icon: Icons.trending_up),
    _GoalItem(id: 'knowledge', label: 'اكتساب المعرفة', description: 'التعلم واستكشاف مجالات جديدة', icon: Icons.lightbulb_outline),
    _GoalItem(id: 'habit', label: 'بناء عادة القراءة', description: 'الالتزام بالقراءة اليومية المنتظمة', icon: Icons.auto_stories),
    _GoalItem(id: 'career', label: 'التقدم المهني', description: 'تعزيز مسيرتك الوظيفية', icon: Icons.work_outline),
  ];

  final List<_InterestItem> _interests = [
    _InterestItem(id: 'psychology', label: 'علم النفس', icon: Icons.psychology),
    _InterestItem(id: 'entrepreneurship', label: 'ريادة الأعمال', icon: Icons.rocket_launch),
    _InterestItem(id: 'history', label: 'التاريخ', icon: Icons.history_edu),
    _InterestItem(id: 'technology', label: 'التكنولوجيا', icon: Icons.devices),
    _InterestItem(id: 'leadership', label: 'القيادة', icon: Icons.groups),
    _InterestItem(id: 'finance', label: 'المال', icon: Icons.payments),
    _InterestItem(id: 'health', label: 'الصحة', icon: Icons.self_improvement),
    _InterestItem(id: 'science', label: 'العلوم', icon: Icons.biotech),
    _InterestItem(id: 'literature', label: 'الأدب', icon: Icons.menu_book),
    _InterestItem(id: 'arts', label: 'الفنون', icon: Icons.palette),
  ];

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    // Validate step 2: minimum 3 interests
    if (_currentStep == 1 && _selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار 3 مجالات على الأقل'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
    } else {
      // الخطوة الأخيرة: حفظ البيانات ثم الانتقال لشاشة التحميل
      final provider = Provider.of<AuthProvider>(context, listen: false);
      provider.saveInterestData(_selectedGoal, _selectedInterests, _selectedStyle, _selectedTime);

      Navigator.push(
        context,
        FadeThroughPageRoute(page: const LoadingPlanScreen()),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== الهيدر الثابت: رقم الخطوة + شريط التقدم =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الرجوع
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward, size: 20, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                          onPressed: _prevStep,
                        ),
                      ),
                      // رقم الخطوة
                      Text(
                        'الخطوة ${_currentStep + 1} من 4',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      // Spacer
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // شريط التقدم المتحرك
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF27272A) : Colors.grey[200],
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: constraints.maxWidth * ((_currentStep + 1) / 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.newPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== المحتوى المتغير =====
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // التنقل بالزر فقط
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildStep1GoalScreen(isDark),
                  _buildStep2CuriosityScreen(isDark),
                  _buildStep3StyleScreen(isDark),
                  _buildStep4TimeScreen(isDark),
                ],
              ),
            ),

            // ===== الزر السفلي الثابت =====
            Container(
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF27272A) : Colors.grey[100]!)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.newPrimary,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: AppColors.newPrimary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 3 ? 'ابدأ رحلتي المعرفية' : 'التالي',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(_currentStep == 3 ? Icons.auto_stories : Icons.chevron_left, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الخطوة 1: ما هدفك من القراءة؟
  // ============================================================
  Widget _buildStep1GoalScreen(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          'ما هدفك الرئيسي من القراءة؟',
          textAlign: TextAlign.right,
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر الهدف الذي يمثلك لنخصص محتواك.',
          textAlign: TextAlign.right,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 32),

        ...List.generate(_goals.length, (index) {
          final goal = _goals[index];
          final isSelected = _selectedGoal == goal.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.newPrimary.withValues(alpha: isDark ? 0.2 : 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.newPrimary
                        : (isDark ? const Color(0xFF27272A) : Colors.grey[200]!),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.newPrimary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Row(
                  children: [
                    // Radio
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
                          ? const Center(child: Icon(Icons.check, color: Colors.white, size: 14))
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.newPrimary.withValues(alpha: 0.15)
                            : (isDark ? const Color(0xFF27272A) : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        goal.icon,
                        size: 24,
                        color: isSelected ? AppColors.newPrimary : (isDark ? Colors.grey[400] : Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.label,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.newPrimary : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ============================================================
  // الخطوة 2: ما المجالات التي تثير فضولك؟
  // ============================================================
  Widget _buildStep2CuriosityScreen(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(item.id);
                  } else {
                    _selectedInterests.add(item.id);
                  }
                });
              },
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
                      color: isSelected ? Colors.white : AppColors.newPrimary,
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
          },
        ),
      ],
    );
  }

  // ============================================================
  // الخطوة 3: كيف تفضل استهلاك المعرفة؟
  // ============================================================
  Widget _buildStep3StyleScreen(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'كيف تفضل استهلاك المعرفة؟',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'اختر النمط الذي يناسب أسلوب حياتك اليومي.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 48),

          _buildStyleCard(
            id: 'audio',
            title: 'الاستماع للملخصات الصوتية',
            subtitle: 'مثالي أثناء القيادة أو ممارسة الرياضة',
            icon: Icons.headset,
            isSelected: _selectedStyle == 'audio',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildStyleCard(
            id: 'reading',
            title: 'قراءة الملخصات المكتوبة',
            subtitle: 'للتركيز العميق وتدوين الملاحظات',
            icon: Icons.auto_stories,
            isSelected: _selectedStyle == 'reading',
            isDark: isDark,
          ),

          const SizedBox(height: 32),
          Text(
            'يمكنك دائماً تغيير هذا الاختيار لاحقاً من الإعدادات',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : (isDark ? const Color(0xFF18181B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.newPrimary : (isDark ? const Color(0xFF27272A) : Colors.grey[200]!),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.newPrimary.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
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
              child: Icon(icon, size: 32, color: isSelected ? AppColors.newPrimary : Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[500]),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(Icons.check_circle, color: AppColors.newPrimary, size: 28),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الخطوة 4: كم وقت تود تخصيصه يومياً؟
  // ============================================================
  Widget _buildStep4TimeScreen(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'كم من الوقت تود تخصيصه يومياً لموجز؟',
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سنساعدك في الوصول لأهدافك المعرفية بناءً على وقتك المتاح.',
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),

          _buildTimeOption(index: 0, label: '5 دقائق', description: 'سريع - ملخص واحد يومياً', isDark: isDark),
          const SizedBox(height: 16),
          _buildTimeOption(index: 1, label: '15 دقيقة', description: 'متعمق - المستوى المثالي للتعلم', isDark: isDark, isRecommended: true),
          const SizedBox(height: 16),
          _buildTimeOption(index: 2, label: '30 دقيقة', description: 'نهم - لمحبي القراءة والاستكشاف', isDark: isDark),

          const SizedBox(height: 32),

          // Visual Tip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.newPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.insights, size: 36, color: AppColors.newPrimary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'اختيارك يساعدنا في تخصيص مكتبتك المعرفية بشكل أفضل.',
                    style: GoogleFonts.manrope(
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
        ],
      ),
    );
  }

  Widget _buildTimeOption({
    required int index,
    required String label,
    required String description,
    required bool isDark,
    bool isRecommended = false,
  }) {
    bool isSelected = _selectedTime == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTime = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.newPrimary.withValues(alpha: isDark ? 0.2 : 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.newPrimary : (isDark ? const Color(0xFF27272A) : Colors.grey[200]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio
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
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.newPrimary : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.newPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'موصى به',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.newPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.manrope(
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

// ============================================================
// شاشة التحميل مع أنيميشن المهام
// ============================================================
class LoadingPlanScreen extends StatefulWidget {
  const LoadingPlanScreen({super.key});

  @override
  State<LoadingPlanScreen> createState() => _LoadingPlanScreenState();
}

class _LoadingPlanScreenState extends State<LoadingPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;

  // حالة كل مهمة: 0=waiting, 1=active, 2=completed  
  final List<int> _taskStates = [0, 0, 0, 0];

  final List<_LoadingTask> _tasks = [
    _LoadingTask(label: 'تحليل اهتماماتك', icon: Icons.analytics_outlined),
    _LoadingTask(label: 'اختيار أفضل الملخصات لك', icon: Icons.auto_stories_outlined),
    _LoadingTask(label: 'تنسيق جدولك اليومي', icon: Icons.calendar_today_outlined),
    _LoadingTask(label: 'تجهيز خطتك المعرفية', icon: Icons.rocket_launch_outlined),
  ];

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // بدء تسلسل المهام
    _startTaskSequence();
  }

  Future<void> _startTaskSequence() async {
    for (int i = 0; i < _tasks.length; i++) {
      if (!mounted) return;

      // تفعيل المهمة الحالية
      setState(() => _taskStates[i] = 1);

      // انتظار قبل إكمالها
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      // إكمال المهمة
      setState(() => _taskStates[i] = 2);

      // انتظار قصير قبل المهمة التالية
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // انتظار لحظة بعد انتهاء جميع المهام ثم الانتقال
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      body: Stack(
        children: [
          // خلفية متدرجة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.newPrimary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الكتاب مع حلقة التحميل
                Container(
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
                      ),
                    ],
                    border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.2)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.auto_stories, size: 48, color: AppColors.newPrimary),
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: RotationTransition(
                          turns: _spinController,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.newPrimary.withValues(alpha: 0.4)),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // العنوان
                Text(
                  'جاري إعداد خطتك المعرفية المخصصة...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 32),

                // قائمة المهام المتحركة
                ...List.generate(_tasks.length, (index) {
                  return _buildAnimatedTask(index, isDark);
                }),
              ],
            ),
          ),

          // اقتباس سفلي
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Icon(Icons.format_quote, color: AppColors.newPrimary.withValues(alpha: 0.5), size: 30),
                const SizedBox(height: 8),
                Text(
                  '"المعرفة هي القوة، ونحن نجهز لك أقصر الطرق إليها"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
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

  Widget _buildAnimatedTask(int index, bool isDark) {
    final state = _taskStates[index];
    final task = _tasks[index];

    // waiting=شفاف, active=يظهر, completed=مكتمل
    double opacity = state == 0 ? 0.0 : 1.0;
    Color iconBg = state == 2
        ? AppColors.newPrimary
        : Colors.transparent;
    Color borderColor = state == 2
        ? AppColors.newPrimary
        : (state == 1 ? AppColors.newPrimary.withValues(alpha: 0.5) : Colors.grey[400]!);
    Color textColor = state == 2
        ? (isDark ? Colors.white : Colors.black87)
        : (state == 1
            ? (isDark ? Colors.white : Colors.black87)
            : (isDark ? Colors.grey[600]! : Colors.grey[400]!));
    FontWeight fontWeight = state == 1 ? FontWeight.bold : FontWeight.w500;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: opacity,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: state == 0 ? const Offset(0, 0.3) : Offset.zero,
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
          child: Row(
            children: [
              // دائرة الحالة
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: state == 2
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : (state == 1
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.newPrimary),
                            ),
                          )
                        : null),
              ),
              const SizedBox(width: 16),
              // النص
              Expanded(
                child: Text(
                  task.label,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Data Classes
// ============================================================
class _GoalItem {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  _GoalItem({required this.id, required this.label, required this.description, required this.icon});
}

class _InterestItem {
  final String id;
  final String label;
  final IconData icon;

  _InterestItem({required this.id, required this.label, required this.icon});
}

class _LoadingTask {
  final String label;
  final IconData icon;

  _LoadingTask({required this.label, required this.icon});
}
