import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'onboarding_screen.dart';
import 'main_dashboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Show splash for at least 3 seconds for branding
    await Future.delayed(const Duration(seconds: 3));

    // TEMPORARY: Clear login session to force showing the login screen
    await _apiService.logout();

    final bool isLoggedIn = await _apiService.isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF0B195C);
    const Color goldColor = Color(0xFF907040);
    const Color textColor = Color(0xFF4A4A4A);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/splash_bg1.png',
            fit: BoxFit.cover,
          ),

          // Light Overlay
          Container(
            color: Colors.white.withValues(alpha: 0.85),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo Glassmorphism Box
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 200.w,
                        height: 200.h,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5.w,
                          ),
                        ),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16.w),
                          child: Image.asset(
                            'assets/images/librarium_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Title
                  Text(
                    'Librarium',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w900,
                      color: navyColor,
                      letterSpacing: 1.0,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Divider
                  Container(
                    width: 60.w,
                    height: 1.5.h,
                    color: goldColor,
                  ),

                  SizedBox(height: 16.h),

                  // Subtitle
                  Text(
                    'Dunia dalam genggaman Anda',
                    style: GoogleFonts.lora(
                      fontSize: 18.sp,
                      fontStyle: FontStyle.italic,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // Quote Block
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '"Buku adalah pesawat, kereta api, dan jalan. Mereka adalah tujuan, dan perjalanan. Mereka adalah rumah."',
                                style: GoogleFonts.lora(
                                  fontSize: 16.sp,
                                  fontStyle: FontStyle.italic,
                                  color: navyColor,
                                  height: 1.5.h,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                '— KURATOR LIBRARIUM',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: goldColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Progress Bar
                  SizedBox(
                    width: 200.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFFDCDCDC),
                        valueColor: AlwaysStoppedAnimation<Color>(navyColor),
                        minHeight: 2,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Status Text
                  Text(
                    'MENYIAPKAN KOLEKSI ANDA',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
