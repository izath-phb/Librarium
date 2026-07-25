import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F5F0);
    const Color navyColor = Color(0xFF0B195C);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Logo
            Padding(
              padding: EdgeInsets.only(top: 20.0.h, bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/librarium_logo.png',
                    height: 30.h,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Librarium',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: navyColor,
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),

            // Navigation / Page Indicator (Optional, but good for UX)
            Padding(
              padding: EdgeInsets.only(bottom: 24.0.h, top: 12.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 24 : 8,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? navyColor
                          : navyColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    const Color navyColor = Color(0xFF0B195C);
    const Color goldColor = Color(0xFF907040);
    const Color lightGoldColor = Color(0xFFF5E6CC);
    const Color textColor = Color(0xFF4A4A4A);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          // Tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: lightGoldColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: goldColor, size: 16),
                SizedBox(width: 6.w),
                Text(
                  'EKSPLORASI LITERASI',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Koleksi Terlengkap',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: navyColor,
            ),
          ),
          Text(
            'Untuk Jiwa Pembaca',
            style: GoogleFonts.lora(
              fontSize: 24.sp,
              fontStyle: FontStyle.italic,
              color: goldColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Ribuan judul dari berbagai genre siap menemani hari Anda. Dari klasik yang tak lekang oleh waktu hingga literatur kontemporer yang menggugah pikiran.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: textColor,
              height: 1.5.h,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: navyColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Lanjut',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 8.w),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'GENRE POPULER',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Fiksi  •  Sains  •  Seni',
            style: GoogleFonts.playfairDisplay(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: navyColor,
            ),
          ),
          SizedBox(height: 16.h),
          // Quote Box
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"Perpustakaan bukan sekadar tumpukan buku, melainkan gerbang menuju ribuan dunia yang belum terjamah."',
                  style: GoogleFonts.lora(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '— Kurator Librarium',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Collage
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    'assets/images/splash_bg2.png',
                    height: 220.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        'assets/images/onboarding_books_stack.png',
                        height: 104.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        'assets/images/onboarding_open_book.png',
                        height: 104.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    const Color navyColor = Color(0xFF0B195C);
    const Color lightGoldColor = Color(0xFFF5E6CC);
    const Color goldColor = Color(0xFF907040);
    const Color textColor = Color(0xFF4A4A4A);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  'assets/images/onboarding_premium_box.png',
                  height: 450.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 16.h,
                right: 16.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: lightGoldColor,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          color: goldColor, size: 16),
                      SizedBox(width: 6.w),
                      Text(
                        'AMAN & TERPERCAYA',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            'Pengiriman Cepat & Aman',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: navyColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Setiap buku dikemas dengan perlindungan maksimal untuk memastikan koleksi berharga sampai di tangan Anda dalam kondisi sempurna. Kami bekerja sama dengan layanan logistik terpercaya di seluruh negeri.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: textColor,
              height: 1.5.h,
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: navyColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              ),
              child: Text('Lanjut',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    const Color navyColor = Color(0xFF0B195C);
    const Color goldColor = Color(0xFF907040);
    const Color textColor = Color(0xFF4A4A4A);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: navyColor.withValues(alpha: 0.05),
            ),
            child: const Icon(Icons.auto_awesome, color: goldColor, size: 80),
          ),
          SizedBox(height: 40.h),
          Text(
            'Mulai Petualangan Anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: navyColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Dunia dalam genggaman',
            style: GoogleFonts.lora(
              fontSize: 20.sp,
              fontStyle: FontStyle.italic,
              color: goldColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Bergabunglah dengan komunitas pembaca kami dan temukan jutaan kisah menarik setiap harinya. Koleksi pribadi Anda menunggu untuk diisi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: textColor,
              height: 1.5.h,
            ),
          ),
          SizedBox(height: 48.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                elevation: 0,
              ),
              child: Text(
                'Mulai Sekarang',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
