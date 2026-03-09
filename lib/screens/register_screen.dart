import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'login_screen.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'interest/interest_flow_screen.dart';
import '../widgets/page_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/route_transitions.dart';
import 'package:animations/animations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  String? _emailError;
  bool _isPasswordVisible = false;

  void _register() async {
    setState(() {
      _error = null;
    });

    if (_nameController.text.isEmpty) {
      setState(() => _error = 'الاسم الكامل حقل مطلوب');
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _emailError = 'يرجى إدخال بريد إلكتروني صحيح');
      return;
    } else {
      setState(() => _emailError = null);
    }

    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      setState(() => _error = 'يرجى إدخال رقم هاتف صحيح (10 أرقام على الأقل)');
      return;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 6 خانات على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      if (mounted && res.user != null) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.loginAsUser(
          _nameController.text.trim(),
          res.user!.email ?? _emailController.text,
          password: _passwordController.text,
        );

        Navigator.of(context).pushAndRemoveUntil(
          FadeThroughPageRoute(page: const InterestFlowScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('already registered') || e.message.contains('already been registered')) {
          _error = 'هذا البريد الإلكتروني مسجل بالفعل، حاول تسجيل الدخول';
        } else if (e.message.contains('Password should be')) {
          _error = 'كلمة المرور ضعيفة جداً، يرجى استخدام 6 أحرف أو أكثر';
        } else {
          _error = 'حدث خطأ: ${e.message}';
        }
      });
    } catch (e) {
      setState(() => _error = 'فشل الاتصال، يرجى المحاولة لاحقاً');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() {
     final provider = Provider.of<AppProvider>(context, listen: false);
     provider.logout(); // Ensure guest mode
     Navigator.pushReplacement(
       context,
       FadeThroughPageRoute(page: const InterestFlowScreen()),
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
        appBar: AppBar(
          title: Text(
            'موجز',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: AppColors.newPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.newPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Text
                Text(
                  'إنشاء حساب جديد',
                  textAlign: TextAlign.right, // RTL
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'انضم إلى مجتمع القراء في موجز واستمتع بأفضل الملخصات.',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
    
                // Form
                _buildTextField(
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'example@mail.com',
                  icon: Icons.alternate_email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  errorText: _emailError,
                  onChanged: (v) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'رقم الهاتف',
                  hint: '05xxxxxxxx',
                  icon: Icons.phone_android_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'كلمة المرور',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  isDark: isDark,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  isPasswordVisible: _isPasswordVisible,
                ),
    
                const SizedBox(height: 16),
                // Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: true, 
                      onChanged: (v){},
                      activeColor: AppColors.newPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: GoogleFonts.manrope(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          children: [
                            const TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'الشروط والأحكام',
                              style: const TextStyle(color: AppColors.newPrimary, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' و '),
                            const TextSpan(text: 'سياسة الخصوصية'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Register Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.newPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.newPrimary.withValues(alpha: 0.3),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'إنشاء الحساب',
                          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
    
                const SizedBox(height: 32),
                
                // Social Divider
                 Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[200])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'أو التسجيل عبر',
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
                
                const SizedBox(height: 24),
    
                 // Social Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        context,
                        "Google", 
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuBLD0VFWq_G3z4UHEmkHQzDElAz7EXWyFMyQB4DaIJ9WGp5mqiTAhpFv7JN8VvsmELcspN3_eUPNuq0rNmaNv7uTQ1fFxQGjihePOtt6HHjjdofy1wLg8YGDCtiELNotz7ROP17WU1RgrGc_VMeX1rxG3BH2LxSfl_DuOpTTs3FRT_eZlqIzmVAtr44Qtn9zGWDE1ugdMRcdi6anKUaDyGNc5laMnhixWFAmDGH-YwV0QnYbotfhnc69e36_90H97DWv3PHgMyO-1Nw",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSocialButton(
                        context, 
                        "Apple", 
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuDjKskdolejGswTETFwo0iYw12SE_bhE2dvXsW_xPt2JzOw_Yy0NXPkxWM4MPrpRf_wF-ee2vRokv7lLKW7zb02WNiFOPo2ahJnXci_m8_RbNEMIPL3LKkp1n_68lVPdvYcXDUJL463yAnsTVum7tGr-8Ne1qM9SJdZo7tZZZlb6F-VA8D7fg6shI_VRgJIt-wxjrvZm4tB8D3oA1sDRSUSu1cSWl6-_mumw-ou1uf68LGkpGreGtKug6pwXC-yo-rrCc5-K6vTU2QD",
                      ),
                    ),
                  ],
                ),
    
                const SizedBox(height: 32),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: GoogleFonts.manrope(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          SharedAxisPageRoute(
                            page: const LoginScreen(),
                            transitionType: SharedAxisTransitionType.horizontal,
                          ),
                        );
                      },
                      child: Text(
                        'سجل دخولك',
                        style: GoogleFonts.manrope(
                          color: AppColors.newPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
    
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDark,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onToggleVisibility,
    bool isPasswordVisible = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            textAlign: TextAlign.right, // RTL
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
              errorText: errorText,
              errorStyle: const TextStyle(height: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
              suffixIcon: Icon(icon, color: errorText != null ? Colors.red : Colors.grey[400]),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(BuildContext context, String label, String imageUrl) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageUrl, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
