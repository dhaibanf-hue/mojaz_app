import 'package:flutter/material.dart';
import '../constants.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

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
  String _authMethod = 'email'; // email or phone
  String? _error;

  void _register() {
    setState(() {
      _error = null;
    });

    if (_nameController.text.isEmpty) {
      setState(() => _error = 'الاسم الكامل حقل مطلوب');
      return;
    }

    if (_authMethod == 'email') {
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        setState(() => _error = 'يرجى إدخال بريد إلكتروني صحيح');
        return;
      }
    } else {
        if (_phoneController.text.isEmpty) {
             setState(() => _error = 'يرجى إدخال رقم الهاتف');
             return;
        }
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
        
        // Save user data to provider
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.loginAsUser(
          _nameController.text, 
          _emailController.text.isNotEmpty ? _emailController.text : (_phoneController.text.isNotEmpty ? _phoneController.text : 'user@moujaz.app'),
          password: _passwordController.text,
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44, 
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'أهلاً بك في موجز',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اختر الطريقة المفضلة للبدء في رحلتك المعرفية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Social Buttons (Mock)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text('التسجيل عبر جوجل'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          foregroundColor: AppColors.primaryBg,
                          side: const BorderSide(color: Color(0xFFF0F0F0), width: 2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFF0F0F0))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'أو عبر',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryText.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFF0F0F0))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Toggle
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                    _authMethod = 'email';
                                    _error = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _authMethod == 'email' ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _authMethod == 'email' ? [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
                                    ] : [],
                                  ),
                                  child: Text(
                                    'البريد الإلكتروني',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _authMethod == 'email' ? AppColors.primaryBg : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                    _authMethod = 'phone';
                                    _error = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _authMethod == 'phone' ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _authMethod == 'phone' ? [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
                                    ] : [],
                                  ),
                                  child: Text(
                                    'رقم الهاتف',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _authMethod == 'phone' ? AppColors.primaryBg : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error Message
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),

                      // Inputs
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'الاسم الكامل',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: const Icon(Icons.person_outline, color: AppColors.secondaryText),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_authMethod == 'email')
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'البريد الإلكتروني',
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryText),
                          ),
                        )
                      else
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '05X XXX XXXX',
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: const Icon(Icons.phone_android, color: AppColors.secondaryText),
                          ),
                        ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryText),
                        ),
                      ),


                      const SizedBox(height: 24),
                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButton,
                            foregroundColor: AppColors.buttonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'إنشاء الحساب',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'لديك حساب بالفعل؟ ',
                            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'سجل دخولك',
                              style: TextStyle(
                                color: AppColors.primaryButton,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
