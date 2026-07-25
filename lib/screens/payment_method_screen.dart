import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/cart_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'Kartu Kredit / Debit';

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color goldColor = Color(0xFF8B7355);
    const Color bgColor = Color(0xFFFAF9F6);

    final double total = CartService().subtotal + 25000 - 15000; // Mock total using ekspres & promo

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Metode Pembayaran',
              style: TextStyle(
                color: navyColor,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
                fontFamily: 'serif',
              ),
            ),
            Text(
              'Librarium Secure Checkout',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                  Text(
                    'Rp ${total.toInt()}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: navyColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Kartu Tersimpan
              Text(
                'Kartu Tersimpan',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: navyColor,
                ),
              ),
              SizedBox(height: 16.h),
              _buildPaymentOption(
                'Kartu Kredit / Debit',
                '•••• •••• •••• 4242',
                Icons.credit_card,
                true,
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: goldColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Tambah Kartu Baru',
                      style: TextStyle(fontSize: 12.sp, color: goldColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Transfer Bank
              Text(
                'Transfer Bank (Virtual Account)',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: navyColor,
                ),
              ),
              SizedBox(height: 16.h),
              _buildPaymentOption('BCA Virtual Account', 'Otomatis dicek', Icons.account_balance, false),
              SizedBox(height: 12.h),
              _buildPaymentOption('Mandiri Virtual Account', 'Otomatis dicek', Icons.account_balance, false),
              SizedBox(height: 12.h),
              _buildPaymentOption('BNI Virtual Account', 'Otomatis dicek', Icons.account_balance, false),
              SizedBox(height: 12.h),
              _buildPaymentOption('BRI Virtual Account', 'Otomatis dicek', Icons.account_balance, false),
              SizedBox(height: 32.h),

              // E-Wallet
              Text(
                'E-Wallet',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: navyColor,
                ),
              ),
              SizedBox(height: 16.h),
              _buildPaymentOption('GoPay', 'Hubungkan akun', Icons.account_balance_wallet, false),
              SizedBox(height: 12.h),
              _buildPaymentOption('OVO', 'Hubungkan akun', Icons.account_balance_wallet, false),
              SizedBox(height: 12.h),
              _buildPaymentOption('DANA', 'Hubungkan akun', Icons.account_balance_wallet, false),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, bool isDefaultSelected) {
    final bool isSelected = _selectedMethod == title || (isDefaultSelected && _selectedMethod == 'Kartu Kredit / Debit' && title == 'Kartu Kredit / Debit');
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = title;
        });
        Navigator.pop(context, title);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4F4F8) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: isSelected ? const Color(0xFF1E1E50) : Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black54),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    SizedBox(height: 4.h),
                    Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF1E1E50) : Colors.grey),
          ],
        ),
      ),
    );
  }
}
