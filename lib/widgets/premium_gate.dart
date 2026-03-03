import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

/// A widget that blocks premium content for non-premium users.
/// Shows an upgrade sheet when a free user tries to access a premium book.
class PremiumGate extends StatelessWidget {
  final bool isPremium;
  final bool userIsPremium;
  final Widget child;

  const PremiumGate({
    super.key,
    required this.isPremium,
    required this.userIsPremium,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium || userIsPremium) return child;

    // Show a locked overlay instead of the actual content
    return GestureDetector(
      onTap: () => _showPremiumSheet(context),
      child: Stack(
        children: [
          // Blurred/dimmed version of child
          IgnorePointer(child: Opacity(opacity: 0.3, child: child)),
          // Lock overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5C518),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded, color: Colors.black, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'محتوى مميز',
                      style: GoogleFonts.notoKufiArabic(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اضغط للترقية إلى موجز Pro',
                      style: GoogleFonts.notoKufiArabic(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showPremiumSheet(BuildContext context) => _showPremiumSheet(context);

  static void _showPremiumSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PremiumOfferSheet(),
    );
  }
}

class _PremiumOfferSheet extends StatelessWidget {
  const _PremiumOfferSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Crown icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5C518), Color(0xFFFF8C00)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5C518).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),

          Text(
            'موجز Pro',
            style: GoogleFonts.notoKufiArabic(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هذا الكتاب متاح للمشتركين المميزين فقط',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoKufiArabic(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 28),

          // Features
          ..._features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF0F3D3E), size: 20),
                const SizedBox(width: 12),
                Text(f, style: GoogleFonts.notoKufiArabic(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                )),
              ],
            ),
          )),

          const SizedBox(height: 28),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to subscription/payment screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري تطوير نظام الدفع...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.newPrimary,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.newPrimary.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'اشترك الآن — 29 ريال / شهرياً',
                style: GoogleFonts.notoKufiArabic(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ليس الآن',
              style: GoogleFonts.notoKufiArabic(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  static const _features = [
    'الوصول لجميع الكتب المميزة',
    'تنزيل الملخصات للاستماع بدون إنترنت',
    'مساعد الذكاء الاصطناعي بلا حدود',
    'إلغاء الإعلانات بالكامل',
  ];
}
