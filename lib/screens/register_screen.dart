import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import '../services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  Future<void> _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final errorMsg = await _apiService.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      
      setState(() => _isLoading = false);

      if (errorMsg == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan masuk.')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $errorMsg')),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan')),
      );
      return;
    }

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        setState(() => _isLoading = true);
        final success = await _apiService.loginWithGoogle(idToken);
        setState(() => _isLoading = false);

        if (success && mounted) {
          // Because they registered via Google, just log them in and go to Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainDashboard()), // Note: need to import main_dashboard.dart
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Google gagal di server.')),
          );
        }
      }
    } catch (error) {
      if (error is GoogleSignInException && error.code == GoogleSignInExceptionCode.canceled) {
        return; // User canceled
      }
      print('Error Google Sign In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Google Sign In. Pastikan konfigurasi sudah benar.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1B226A); // Slightly lighter navy for register button
    const Color titleColor = Color(0xFF0B195C);
    const Color goldColor = Color(0xFF907040);
    const Color bgColor = Color(0xFFF9F8F4);
    const Color textColor = Color(0xFF4A4A4A);
    const Color iconBgColor = Color(0xFFBEC9FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const SizedBox.shrink(), // Remove back button as per design? Design doesn't show back button explicitly.
        leadingWidth: 0,
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: titleColor, size: 24),
            SizedBox(width: 8.w),
            Text(
              'Librarium',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 20.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Form Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    )
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header in Card
                      Center(
                        child: Container(
                          width: 64.w,
                          height: 64.h,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Icon(Icons.menu_book, color: titleColor, size: 32),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Center(
                        child: Text(
                          'Buat Akun Baru',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: Text(
                          'Lengkapi detail Anda untuk memulai\nperjalanan.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: textColor,
                            height: 1.5.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Nama Lengkap Field
                      Text(
                        'Nama Lengkap',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'cth: Ahmad Dahlan',
                          hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14.sp),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Masukkan nama lengkap' : null,
                      ),
                      SizedBox(height: 20.h),

                      // Email Field
                      Text(
                        'Email',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'nama@email.com',
                          hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14.sp),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'Masukkan email' : null,
                      ),
                      SizedBox(height: 20.h),

                      // No Telepon Field
                      Text(
                        'No. Telepon',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 16.w, right: 12.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '+62',
                                  style: GoogleFonts.inter(
                                    color: Colors.black87,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '812 3456 7890',
                          hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14.sp),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),

                      // Password Field
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14.sp),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.black54,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        ),
                        obscureText: _obscurePassword,
                        validator: (val) => val == null || val.length < 8 ? 'Password minimal 8 karakter' : null,
                      ),
                      SizedBox(height: 24.h),

                      // Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                              activeColor: titleColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.black87, height: 1.4.h),
                                children: [
                                  const TextSpan(text: 'Saya menyetujui '),
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: const TextStyle(color: goldColor, fontWeight: FontWeight.w600),
                                    recognizer: TapGestureRecognizer()..onTap = () {},
                                  ),
                                  const TextSpan(text: ' serta\n'),
                                  TextSpan(
                                    text: 'Kebijakan Privasi',
                                    style: const TextStyle(color: goldColor, fontWeight: FontWeight.w600),
                                    recognizer: TapGestureRecognizer()..onTap = () {},
                                  ),
                                  const TextSpan(text: ' Librarium.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                              ? SizedBox(height: 20.h, width: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Daftar', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[200])),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              'Atau daftar dengan',
                              style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[500]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[200])),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      
                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            side: BorderSide(color: Colors.grey[300]!),
                            backgroundColor: const Color(0xFFFAFAFA),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/images/google_logo.svg', width: 24.w, height: 24.h),
                              SizedBox(width: 12.w),
                              Text('Daftar dengan Google', style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      const Divider(color: Color(0xFFEEEEEE)),
                      SizedBox(height: 24.h),
                      
                      // Login Link
                      Center(
                        child: Column(
                          children: [
                            Text("Sudah punya akun?", style: GoogleFonts.inter(fontSize: 13.sp, color: textColor)),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Go back to login
                              },
                              child: Text(
                                'Masuk Sekarang',
                                style: GoogleFonts.inter(fontSize: 14.sp, color: titleColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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
