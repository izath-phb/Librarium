import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String? initialAvatarUrl;

  const EditProfileScreen({super.key, required this.initialName, this.initialAvatarUrl});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  late TextEditingController _nameController;
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final Map<String, dynamic> data = {'full_name': name};
    if (_passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
    }
    
    if (_selectedImage != null) {
      final avatarUrl = await _apiService.uploadAvatar(_selectedImage!.path);
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
      }
    }

    final success = await _apiService.updateProfile(data);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Lengkap', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            SizedBox(height: 8.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: navyColor), borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Foto Profil', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            SizedBox(height: 8.h),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: navyColor, width: 2),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : widget.initialAvatarUrl != null && widget.initialAvatarUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(ApiService.getFullImageUrl(widget.initialAvatarUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop'),
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: navyColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text('Password Baru (Opsional)', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            SizedBox(height: 8.h),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Biarkan kosong jika tidak ingin mengubah',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: navyColor), borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
