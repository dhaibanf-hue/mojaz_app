
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/app_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _phoneController = TextEditingController(text: "+966 50 123 4567");
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.userName);
    _emailController = TextEditingController(text: provider.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.newBackgroundDark : AppColors.newBackgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.newBackgroundDark : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
            child: IconButton(
              icon: Icon(Icons.chevron_left_rounded, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'تعديل الملف الشخصي',
          style: GoogleFonts.notoKufiArabic(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.1), width: 4),
                      boxShadow: [
                         BoxShadow(color: AppColors.newPrimary.withValues(alpha: 0.1), blurRadius: 20),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/seed/user/200/200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.newPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.newBackgroundDark : Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تغيير صورة الملف الشخصي',
              style: GoogleFonts.notoKufiArabic(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),

            // Form
            _buildTextField(context, 'الاسم الكامل', Icons.person_outline_rounded, _nameController, isDark),
            const SizedBox(height: 16),
            _buildTextField(context, 'البريد الإلكتروني', Icons.mail_outline_rounded, _emailController, isDark, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(context, 'رقم الهاتف', Icons.phone_iphone_rounded, _phoneController, isDark, keyboardType: TextInputType.phone),
            
            const SizedBox(height: 32),
            
            // Password Section
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.newPrimary, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text(
                    'تغيير كلمة المرور',
                    style: GoogleFonts.notoKufiArabic(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(context, 'كلمة المرور الحالية', _currentPassController, isDark, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
            const SizedBox(height: 16),
            _buildPasswordField(context, 'كلمة المرور الجديدة', _newPassController, isDark, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4),
                child: Text('يجب أن تحتوي على ٨ أحرف على الأقل', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              ),
            ),

            const SizedBox(height: 48),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                   // Save logic: update AppProvider immediately
                   final provider = Provider.of<AppProvider>(context, listen: false);
                   provider.loginAsUser(
                     _nameController.text.trim(),
                     _emailController.text.trim(),
                     password: _newPassController.text.isNotEmpty
                         ? _newPassController.text
                         : provider.userPassword,
                   );
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(
                       content: Text('تم حفظ التغييرات بنجاح'),
                       behavior: SnackBarBehavior.floating,
                     ),
                   );
                   Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                label: Text('حفظ التغييرات', style: GoogleFonts.notoKufiArabic(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.newPrimary.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.notoKufiArabic(color: Colors.grey[500], fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon, TextEditingController controller, bool isDark, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.notoKufiArabic(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
               if(!isDark) BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
            ],
            border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.right, // RTL
            style: GoogleFonts.notoKufiArabic(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[400]), 
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, String label, TextEditingController controller, bool isDark, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.notoKufiArabic(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
             color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
             borderRadius: BorderRadius.circular(12),
             boxShadow: [
                if(!isDark) BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
             ],
             border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            textAlign: TextAlign.right,
            style: GoogleFonts.notoKufiArabic(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(obscure ? Icons.lock_outline_rounded : Icons.lock_open_rounded, color: Colors.grey[400]),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[400]),
                onPressed: toggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
