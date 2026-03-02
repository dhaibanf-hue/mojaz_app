import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import 'login_screen.dart';
import '../widgets/page_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: "خلاصة المعرفة\nبين يديك",
      highlightedText: "بين يديك",
      description: "نقدم لك زبدة الكتب العالمية في ملخصات ذكية توفر عليك ساعات من القراءة",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAnT6CFxJc1c0FdwGaHaFuhfwUe_ulWq3Lzf4g0H23ekrFQFeSARla3v3ofG1Ac7EnhlAN1yPQ7VhRqSDqfGxg2BOO_vMrvBI9bOh-vWewjZiHm6row35NkozPIEe0FEAAFl8BOiL1QThuKH17b9r2er1-LGfzmGpyu8daq020lRjF9UTRLiJ_Iy2X6qpoQeGV5j3DdB2xYoGkgyYmakQvp6p35sXvcmKuO-gfjL5W-S6KofwvugtM-qGnl5QAjub4Q_vo5JDd_IZWD",
      topIcon: Icons.lightbulb,
      bottomIcon: Icons.auto_stories,
    ),
    OnboardingSlideData(
      title: "استمع وتعلم في أي وقت",
      description: "حوّل وقت تنقلك أو ممارسة الرياضة إلى رحلة معرفية مع ملخصاتنا الصوتية الاحترافية.",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBek89dE_lEzQTRUGVha3g3_RRpn5INvHHAMdQVeyI0kcQ1BvL_8HK8Yp6Mt55kI0xOo8MECUTWfoVerTh5DAMLIvj7LKJWEbUEOt--Y_sBYu4qkPAzCpwK7aWHaCDrsFW_pJrQNmzOXOsZn_EduhdpFDuLHDHf52OwU7JwaPwh8j_Z9xq9CcKx7TEWYBTqDJcY-pSfiNJwSzOUOUuyHl2hL0ZxeXcozWw_uc1auc9T0XrB-7cgq4_ts8gZITLLXZJCLxFz-UjRXNeB",
      topIcon: Icons.headset,
      bottomIcon: Icons.volume_up,
      isImageRounded: true,
    ),
    OnboardingSlideData(
      title: "مساعدك الذكي الخاص",
      description: "اسأل مساعد موجز الذكي عن أي فكرة داخل الكتاب وسيجيبك بدقة بفضل تقنيات الذكاء الاصطناعي",
      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDc1d97_c8kAh9zc94XoKUB6vUb_tF9RaVhUcCIJTbtGgFVWC-YymIEHh41nmfCKI-N6lgXDcY-m3tlIAIINMZBBQcTNaW14UvnLE9oFxi1rp9B7_HcFe9kGmcqvVX-YfhShKznla2JY3tSh9CZAvuXnos6cytDlUNpMPkFV2EXxjzUyLfcvYZuZXrz3s2-6WJgJsY3R2GGk3nb1VU2WTMY0C5SiCrasd9coZBTiLwd1iE6PlvvtdAn9k7lD4VS88canioJ60DUzN_v",
      topIcon: Icons.psychology,
      bottomIcon: Icons.auto_awesome,
      isCircleImage: true,
    ),
    // Fourth slide is custom defined in the builder
    OnboardingSlideData(
      title: "مكتبتك الشاملة بدون إنترنت",
      description: "حمل ملخصاتك المفضلة واستمتع بقراءتها والاستماع إليها في أي مكان حتى بدون اتصال بالإنترنت",
      imageUrl: "", // Placeholder
      topIcon: Icons.offline_pin,
      bottomIcon: Icons.cloud_download,
    ),
  ];

  void _onComplete() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgLight = AppColors.newBackgroundLight;
    Color bgDark = AppColors.newBackgroundDark;
    Color textColor = isDark ? Colors.white : AppColors.newTextMain;
    Color subTextColor = isDark ? Colors.grey[400]! : AppColors.newTextMuted;

    return PageWrapper(
      child: Scaffold(
        backgroundColor: isDark ? bgDark : bgLight,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Skip button usually on left in RTL if "Start" is right
                  child: TextButton(
                    onPressed: _onComplete,
                    child: Text(
                      'تخطي',
                      style: GoogleFonts.manrope(
                        color: isDark ? Colors.grey : Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
                    // Special case for the offline reading screen (Index 3)
                    if (index == 3) {
                      return _buildOfflineSlide(context, _slides[index]);
                    }
                    return _buildRegularSlide(context, _slides[index]);
                  },
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentSlide == index ? 32 : 8,
                          decoration: BoxDecoration(
                            color: _currentSlide == index
                                ? AppColors.newPrimary
                                : AppColors.newPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _nextSlide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newPrimary,
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shadowColor: AppColors.newPrimary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentSlide == _slides.length - 1 ? 'ابدأ رحلتك الآن' : 'التالي',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentSlide == _slides.length - 1 ? Icons.rocket_launch : Icons.arrow_back,
                               textDirection: TextDirection.ltr, // Force arrow direction
                            ),
                          ],
                        ),
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
  }

  Widget _buildRegularSlide(BuildContext context, OnboardingSlideData slide) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Illustration Container
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.newPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                // Main Image
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: slide.isCircleImage 
                      ? BorderRadius.circular(1000) 
                      : slide.isImageRounded 
                        ? BorderRadius.circular(24) 
                        : BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.newPrimary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                     borderRadius: slide.isCircleImage 
                      ? BorderRadius.circular(1000) 
                      : slide.isImageRounded 
                        ? BorderRadius.circular(20) 
                        : BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: slide.imageUrl,
                      fit: slide.isCircleImage ? BoxFit.contain : BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator(color: AppColors.newPrimary)),
                      ),
                    ),
                  ),
                ),
                // Floating Icons
                Positioned(
                  top: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.newPrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(slide.topIcon, color: Colors.white, size: 24),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.newPrimary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.newPrimary.withOpacity(0.1)),
                    ),
                    child: Icon(slide.bottomIcon, color: AppColors.newPrimary, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            // Text Content
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.newTextMain,
                  height: 1.2,
                ),
                children: [
                  TextSpan(text: slide.title.replaceAll(slide.highlightedText ?? "", "")),
                  if (slide.highlightedText != null)
                     TextSpan(
                      text: slide.highlightedText,
                      style: const TextStyle(color: AppColors.newPrimary),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                slide.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : AppColors.newTextMuted,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSlide(BuildContext context, OnboardingSlideData slide) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Mock Phone UI Container
            SizedBox(
              height: 320,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Glow
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.newPrimary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // The Card
                  Container(
                    width: 260,
                    height: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.newPrimary.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Mock Header
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.newPrimary, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Container(width: 60, height: 8, decoration: BoxDecoration(color: AppColors.newPrimary.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildMockBookItem(
                                "https://lh3.googleusercontent.com/aida-public/AB6AXuCo7rdsL0Ek89Kh5VGvn08e6dV-_zklqNAIMP1XICA4hgyOSDKwJrqvIQgfC-Dkmd4_BtoOt3Zwsab8v7Zetn2OKUPGLBJrQ5oHOK-ugGIy9oC9MB1yYAb4Cl2UmO1oubl7HkFczgm5NYZ7owGD6UV_pIW2FFwdaQeEqcpKY8G-SEvrv4AfpF0uTZEdkhf-T6Xt5H7RLrGEzO4grbzMdUUm8Ssnox6f2Wt0oWW16EdphrDZsnDEz4JMlKD5iaDeRAWkTqs3CzUzUQJp",
                                false,
                                isDark
                              ),
                              _buildMockBookItem(
                                "https://lh3.googleusercontent.com/aida-public/AB6AXuDfpY5v5b1ryQyHitip4cYZ8pjhfDD70ZvM0vm35oTM__R2vBT1rOX0HfJEd1SzySyP2H0X2OJBpFsTd3pPlQUp2W3ZBKABdJ_xQIb37HH2QJuyKjDdR35F44kBjLjff5FLTPn6UxPF3NZY3LDhP2FKL_3TbwSUG9p2jBRsaPMhwNsprDcdyECMssy_qtaZAp_d9hiURjA-YONqo2jMqb8Ed1jgXZ8sJO81lH4-OcFQ4Mm2U3j5k9um9EgKew5gTNfdbcANRn0ZbxWN",
                                false,
                                isDark
                              ),
                              _buildMockBookItem(null, true, isDark), // Downloaded
                              _buildMockBookItem(null, false, isDark), // Skeleton
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Badge
                  Positioned(
                    top: 100,
                    left: 0,
                    child: Transform.rotate(
                      angle: -0.2, // -12 degrees approx
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.newPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.offline_pin, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 48),

            // Text Content
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.newTextMain,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                slide.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : AppColors.newTextMuted,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockBookItem(String? imageUrl, bool isDownloaded, bool isDark) {
    Color itemBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: imageUrl != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl, 
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : isDownloaded 
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.newPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(child: Icon(Icons.cloud_download, color: AppColors.newPrimary)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDownloaded ? AppColors.newPrimary.withOpacity(0.3) : (isDark ? Colors.grey[700] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String? highlightedText;
  final String description;
  final String imageUrl;
  final IconData topIcon;
  final IconData bottomIcon;
  final bool isCircleImage;
  final bool isImageRounded;

  OnboardingSlideData({
    required this.title,
    this.highlightedText,
    required this.description,
    required this.imageUrl,
    required this.topIcon,
    required this.bottomIcon,
    this.isCircleImage = false,
    this.isImageRounded = false,
  });
}
