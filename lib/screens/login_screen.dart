import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'main_dashboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login failed. Please check your credentials.')),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        setState(() => _isLoading = true);
        final success = await _apiService.loginWithGoogle(idToken);
        setState(() => _isLoading = false);

        if (success && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainDashboard()),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Google gagal di server.')),
          );
        }
      }
    } catch (error) {
      if (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.canceled) {
        return; // User canceled
      }
      print('Error Google Sign In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error Google Sign In. Pastikan konfigurasi sudah benar.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF0B195C);
    const Color goldColor = Color(0xFF907040);
    const Color bgColor = Color(0xFFF9F8F4);
    const Color textColor = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 40.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100.w,
                height: 100.h,
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/librarium_logo.png',
                    fit: BoxFit.contain),
              ),
              SizedBox(height: 24.h),

              // Titles
              Text(
                'Selamat Datang',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: navyColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Masuk untuk melanjutkan perjalanan literasi\nAnda di arsip modern kami.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: textColor,
                  height: 1.5.h,
                ),
              ),
              SizedBox(height: 32.h),

              // Form Card
              Container(
                padding: EdgeInsets.all(24.w),
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
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          hintStyle: GoogleFonts.inter(
                              color: Colors.grey[400], fontSize: 14.sp),
                          prefixIcon: const Icon(Icons.mail_outline,
                              color: Colors.grey, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFFDFDFD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Masukkan email Anda'
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      // Password Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kata Sandi',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Lupa sandi?',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: goldColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.inter(
                              color: Colors.grey[400], fontSize: 14.sp),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.grey, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFDFDFD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        obscureText: _obscurePassword,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Masukkan kata sandi'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // Remember me
                      Row(
                        children: [
                          SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (val) =>
                                  setState(() => _rememberMe = val ?? false),
                              activeColor: navyColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Ingat saya di perangkat ini',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Masuk Sekarang',
                                  style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold)),
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
                              'Atau masuk dengan',
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp, color: Colors.grey[500]),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                            side: BorderSide(color: Colors.grey[300]!),
                            backgroundColor: const Color(0xFFFAFAFA),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google 'G' approximation
                              SvgPicture.asset('assets/images/google_logo.svg',
                                  width: 24.w, height: 24.h),
                              SizedBox(width: 12.w),
                              Text('Login dengan Google',
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Belum punya akun? ",
                              style: GoogleFonts.inter(
                                  fontSize: 13.sp, color: textColor)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            child: Text(
                              'Daftar Sekarang',
                              style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: navyColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Quote Block
              IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"Sebuah buku adalah saku\ntaman yang dibawa-bawa."',
                            style: GoogleFonts.lora(
                              fontSize: 15.sp,
                              fontStyle: FontStyle.italic,
                              color: textColor,
                              height: 1.5.h,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '— Pepatah Tua',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Footer Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bantuan',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: Colors.grey[500])),
                  SizedBox(width: 24.w),
                  Text('Privasi',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: Colors.grey[500])),
                  SizedBox(width: 24.w),
                  Text('Ketentuan',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: Colors.grey[500])),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
