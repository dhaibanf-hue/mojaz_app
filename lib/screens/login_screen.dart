import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'interest/interest_flow_screen.dart';
import '../widgets/page_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isPasswordVisible = false;

  void _login() {
    setState(() {
      _error = null;
    });

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _error = 'يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 6 خانات على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Mock user from provider
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.loginAsUser('أحمد محمد', _emailController.text);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InterestFlowScreen()),
          (route) => false,
        );
      }
    });
  }

  void _continueAsGuest() {
     final provider = Provider.of<AppProvider>(context, listen: false);
     provider.loginAsUser('ضيف', 'guest@moujaz.app');
     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => const InterestFlowScreen()),
     );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgLight = AppColors.newBackgroundLight;
    Color bgDark = AppColors.newBackgroundDark;
    
    return PageWrapper(
      child: Scaffold(
        backgroundColor: isDark ? bgDark : bgLight,
        body: Column(
          children: [
            // iOS Status Bar Spacer
            SizedBox(height: MediaQuery.of(context).padding.top),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo & Header
                    const SizedBox(height: 32),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? bgDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border.all(color: AppColors.newPrimary.withOpacity(0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.network(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuDxH9X4b2wDM2xDzvrUcssgvR_BBQBX4nJ1JGvo1IaSRYbfKG9Jrj6xfafbOb7cTrgduZRhRj0-DAtKWtkoPqr_dYi5t-pK9ayoYG-Y7jFQuIN5RuxosFF5XhfYBNjDH8XyZYKqs0B3E4wrEKC14OOuID7RU3DUYP5XcZ56uIqCdRFJ52CIPGeSTiJJsKqKlpK1AzKmmwJpBdH1KGhcNCV7Ubh2NvDnIoo8n_1AogcLQ6jjs07y91_IhzRVcHwoPi_uKx1MfWkapZYq",
                          fit: BoxFit.contain,
                           errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_stories, color: AppColors.newPrimary, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'تسجيل الدخول',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'مرحباً بعودتك!\nأكمل رحلتك المعرفية مع موجز',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'البريد الإلكتروني',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                          ),
                          child: TextField(
                            controller: _emailController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'name@example.com',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[300]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              suffixIcon: Icon(Icons.mail_outline, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Password
                        Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'كلمة المرور',
                            style: GoogleFonts.manrope(
                               fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                             style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[300]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              suffixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                              prefixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft, // RTL Left
                          child: TextButton(
                            onPressed: () {
                              // Forgot Password Navigation (Optional, not requested to implement fully but link is there)
                            },
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: GoogleFonts.manrope(
                                color: AppColors.newPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error Display
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 24),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newPrimary,
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shadowColor: AppColors.newPrimary.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'دخول',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.login, size: 20),
                            ],
                          ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[200])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'أو من خلال',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[200])),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Social Login
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            context,
                            "جوجل", 
                            "https://lh3.googleusercontent.com/aida-public/AB6AXuA1Zfq7i3YsfQsL9Y5CqQ8Mx6lRfuJdu4mpQaihvrT6zaxJEEo3QyZWKjNKtbh3A-t-2ISRf1NPO6V7rTHYjEdbUFCcSPJEJrio4tEAiXpx-ETjpk0POQWkOGDzcqXibUl1tRKXCWR2JOJ2jDVsKjmBMoJoYbonLjh80Y_wCNtjQK-QcHtzVmGV1HhuMmR1ns20UjB_JpD-gJgU8o3Q6xbp6Lss49uHXW6UoGd779GIr3rhuVMQ0-mESTTUrKMQIyRsPInk04F_W61i",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSocialButton(
                            context, 
                            "أبل", 
                            null, // Use icon for Apple
                            icon: Icons.apple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟',
                          style: GoogleFonts.manrope(
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (context) => const RegisterScreen())
                            );
                          },
                          child: Text(
                            'اشترك الآن',
                            style: GoogleFonts.manrope(
                              color: AppColors.newPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Guest Mode
                    TextButton(
                      onPressed: _continueAsGuest,
                      child: Text(
                        'المتابعة كضيف',
                        style: GoogleFonts.manrope(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String label, String? imageUrl, {IconData? icon}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageUrl != null) 
                Image.network(imageUrl, width: 24, height: 24)
              else if (icon != null)
                Icon(icon, color: isDark ? Colors.white : Colors.black87),
              
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
