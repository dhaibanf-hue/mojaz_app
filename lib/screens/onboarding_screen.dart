import 'package:flutter/material.dart';
import '../constants.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "ملخصات ذكية",
      "description": "نقدم لك زبدة الكتب العالمية في ملخصات نصية وصوتية لا تتجاوز 15 دقيقة، مصممة بعناية لتناسب وقتك.",
      "icon": "📖",
    },
    {
      "title": "استمع في أي مكان",
      "description": "سواء كنت في السيارة، النادي، أو قبل النوم، استمتع بتجربة استماع احترافية بجودة عالية تدعم التشغيل بلا إنترنت.",
      "icon": "🎧",
    },
    {
      "title": "مكتبتك الشاملة",
      "description": "آلاف الكتب في مختلف المجالات: تطوير الذات، الإدارة، التاريخ، وعلم النفس، كلها في متناول يدك.",
      "icon": "📱",
    },
  ];

  void _onComplete() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: _onComplete,
                child: const Text('تخطي', style: TextStyle(color: Colors.white60)),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            slide['icon']!,
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        slide['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          slide['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentSlide == index ? 32 : 8,
                        decoration: BoxDecoration(
                          color: _currentSlide == index ? AppColors.primaryButton : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _nextSlide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: AppColors.buttonText,
                         shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        _currentSlide == _slides.length - 1 ? 'ابدأ الآن' : 'التالي',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
