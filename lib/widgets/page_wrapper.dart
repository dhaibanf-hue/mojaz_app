import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class PageWrapper extends StatefulWidget {
  final Widget child;
  const PageWrapper({super.key, required this.child});

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // إعداد التوقيت 0.4 ثانية كما طلبت
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // دالة محاكاة الفيزياء (Spring)
    // stiffness: 100, damping: 20
    final spring = SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 20,
    );
    
    final simulation = SpringSimulation(spring, 0, 1, 0);

    // 1. Fade Animation (0 to 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 2. Scale Animation (0.98 to 1)
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 3. Vertical Slide Animation (20px from bottom)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // يوازي تقريباً 20px في الشاشات العادية
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // بدء الحركة باستخدام محاكاة الفيزياء
    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
