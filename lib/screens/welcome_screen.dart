import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../widgets/page_wrapper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  
  // 0: waiting, 1: dot appears, 2: dot jumps, 3: morph to "م", 4: full logo, 5: final glow
  int _phase = 0;

  late AnimationController _tapPulseController;
  late AnimationController _dotAppearController;
  late AnimationController _dotJumpController;
  late AnimationController _morphController;
  late AnimationController _logoRevealController;
  late AnimationController _finalGlowController;

  late Animation<double> _tapOpacity;
  late Animation<double> _dotScale;
  late Animation<double> _dotJumpX;
  late Animation<double> _dotJumpY;
  late Animation<double> _morphProgress;
  late Animation<double> _logoSlide;
  late Animation<double> _logoFade;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    _tapPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _tapOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _tapPulseController, curve: Curves.easeInOut));

    _dotAppearController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _dotScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _dotAppearController, curve: Curves.elasticOut));

    _dotJumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _morphController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _morphProgress = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _morphController, curve: Curves.easeOutCubic));

    _logoRevealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoSlide = Tween<double>(begin: -30.0, end: 0.0).animate(CurvedAnimation(parent: _logoRevealController, curve: Curves.easeOutCubic));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoRevealController, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)));

    _finalGlowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _finalGlowController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _tapPulseController.dispose();
    _dotAppearController.dispose();
    _dotJumpController.dispose();
    _morphController.dispose();
    _logoRevealController.dispose();
    _finalGlowController.dispose();
    super.dispose();
  }

  Future<void> _startSequence() async {
    if (_phase != 0) return;

    setState(() => _phase = 1);
    _tapPulseController.stop();
    await _dotAppearController.forward();

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final centerX = screenW / 2;
    final centerY = screenH / 2;
    final targetX = centerX + (screenW * 0.12);
    final targetY = centerY - 10;

    _dotJumpX = Tween<double>(begin: centerX, end: targetX).animate(CurvedAnimation(parent: _dotJumpController, curve: Curves.easeInOutBack));
    _dotJumpY = Tween<double>(begin: centerY, end: targetY).animate(CurvedAnimation(parent: _dotJumpController, curve: _BounceCurve()));

    setState(() => _phase = 2);
    await _dotJumpController.forward();

    setState(() => _phase = 3);
    await _morphController.forward();

    setState(() => _phase = 4);
    await _logoRevealController.forward();

    setState(() => _phase = 5);
    await _finalGlowController.forward();

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight;
    Color primary = AppColors.newPrimary;

    return PageWrapper(
      child: Scaffold(
        backgroundColor: bg,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _startSequence,
          child: Stack(
            children: [
              // Tap Prompt
              if (_phase == 0)
                Center(
                  child: FadeTransition(
                    opacity: _tapOpacity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 48, color: primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'اضغط في أي مكان',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.newTextMain.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Moving Dot
              if (_phase >= 1 && _phase <= 2)
                AnimatedBuilder(
                  animation: Listenable.merge([_dotAppearController, _dotJumpController]),
                  builder: (context, child) {
                    double x = _phase == 1 ? MediaQuery.of(context).size.width / 2 : _dotJumpX.value;
                    double y = _phase == 1 ? MediaQuery.of(context).size.height / 2 : _dotJumpY.value;
                    return Positioned(
                      left: x - 12,
                      top: y - 12,
                      child: Transform.scale(
                        scale: _dotScale.value,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.5), blurRadius: 16)],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Morphing Letter Content
              if (_phase >= 3)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      // The "م"
                      AnimatedBuilder(
                        animation: _morphController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _phase >= 4 ? 1.0 : _morphProgress.value,
                            child: Text(
                              'م',
                              style: GoogleFonts.notoKufiArabic(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : primary,
                              ),
                            ),
                          );
                        },
                      ),
                      // The "وجز"
                      if (_phase >= 4)
                        ClipRect(
                          child: AnimatedBuilder(
                            animation: _logoRevealController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_logoSlide.value, 0),
                                child: Opacity(
                                  opacity: _logoFade.value,
                                  child: Text(
                                    'وجز',
                                    style: GoogleFonts.notoKufiArabic(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

              // Subtitle
              if (_phase >= 5)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _subtitleFade,
                    child: Column(
                      children: [
                        Text(
                          'ثقافة بلا حدود في زمن محدود',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 40,
                          height: 2,
                          child: LinearProgressIndicator(
                            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                            color: primary,
                          ),
                        ),
                      ],
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

class _BounceCurve extends Curve {
  @override
  double transformInternal(double t) {
    return (t - sin(t * pi) * 0.12).clamp(0.0, 1.0);
  }
}
