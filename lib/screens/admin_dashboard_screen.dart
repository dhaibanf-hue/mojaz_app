import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants.dart';
import '../services/supabase_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  PlatformFile? _coverFile;
  PlatformFile? _audioFile;
  bool _isUploading = false;
  String? _statusText;

  final _supabaseService = SupabaseService();

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _coverFile = result.files.first);
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() => _audioFile = result.files.first);
    }
  }

  Future<void> _uploadBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty || _coverFile == null || _audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول واختيار الملفات')));
      return;
    }

    setState(() {
      _isUploading = true;
      _statusText = 'جاري رفع الملفات...';
    });

    try {
      // 1. Upload Cover
      final coverResult = await _supabaseService.uploadFile(_coverFile!, 'covers');
      if (!coverResult['success']) throw 'فشل رفع الغلاف: ${coverResult['error']}';
      final coverUrl = coverResult['url'];

      setState(() => _statusText = 'تم رفع الغلاف، جاري رفع ملف الصوت...');

      // 2. Upload Audio
      final audioResult = await _supabaseService.uploadFile(_audioFile!, 'audio');
      if (!audioResult['success']) throw 'فشل رفع ملف الصوت: ${audioResult['error']}';
      final audioUrl = audioResult['url'];

      setState(() => _statusText = 'جاري حفظ البيانات في قاعدة البيانات...');

      // 3. Save to DB
      final dbResult = await _supabaseService.addBook({
        'title': _titleController.text,
        'author': _authorController.text,
        'summary': _descriptionController.text, // تم التغيير من content_text إلى summary
        'category': _categoryController.text,
        'cover_image': coverUrl,                // تم التغيير من cover_url إلى cover_image
        'audio_file': audioUrl,                 // تم التغيير من audio_url إلى audio_file
        'is_published': true,                   // إضافة حالة النشر لضمان الظهور
        'rating': 4.5,
        'page_count': 0,
        'is_premium': false,
      });

      if (dbResult['success']) {
        setState(() {
          _isUploading = false;
          _statusText = 'تم رفع الكتاب بنجاح!';
          _clearForm();
        });
        // Refresh books in provider
        if (mounted) {
           Provider.of<AppProvider>(context, listen: false).fetchBooks();
        }
      } else {
        throw 'فشل حفظ بيانات الكتاب: ${dbResult['error']}';
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusText = 'خطأ: $e';
      });
    }
  }

  void _clearForm() {
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _coverFile = null;
    _audioFile = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم - رفع كتب جيدة'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('عنوان الكتاب', _titleController),
            const SizedBox(height: 16),
            _buildTextField('اسم الكاتب', _authorController),
            const SizedBox(height: 16),
            _buildTextField('التصنيف (مثال: تطوير ذات)', _categoryController),
            const SizedBox(height: 16),
            _buildTextField('ملخص النص', _descriptionController, maxLines: 5),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _buildFilePicker('صورة الغلاف', _coverFile?.name, _pickCover, Icons.image),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilePicker('ملف الصوت', _audioFile?.name, _pickAudio, Icons.audio_file),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (_statusText != null) 
              Text(_statusText!, textAlign: TextAlign.center, style: TextStyle(color: _statusText!.contains('خطأ') ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isUploading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('رفع الكتاب إلى التطبيق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildFilePicker(String label, String? fileName, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBg.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryBg.withValues(alpha: 0.02),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBg),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (fileName != null) 
              Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
