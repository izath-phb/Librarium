import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import 'main_dashboard.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final List<String> orderIds;
  final double totalAmount;

  const PaymentGatewayScreen({super.key, required this.orderIds, required this.totalAmount});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  bool _isProcessing = false;
  String _selectedMethod = 'qris';

  void _processPayment() async {
    setState(() => _isProcessing = true);
    final apiService = ApiService();
    bool allSuccess = true;

    for (String orderId in widget.orderIds) {
      final success = await apiService.payOrder(orderId, _selectedMethod);
      if (!success) allSuccess = false;
    }

    setState(() => _isProcessing = false);

    if (allSuccess) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          content: Text(
            'Pembayaran Berhasil!\nTerima kasih telah berbelanja di Librarium.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainDashboard()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E50)),
                child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat memproses pembayaran.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color bgColor = Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: navyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pembayaran',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
              child: Column(
                children: [
                  Text('Total Tagihan', style: TextStyle(color: Colors.black54, fontSize: 14.sp)),
                  SizedBox(height: 8.h),
                  Text(
                    'Rp ${widget.totalAmount.toInt()}',
                    style: TextStyle(color: navyColor, fontWeight: FontWeight.w900, fontSize: 32.sp, fontFamily: 'serif'),
                  ),
                  SizedBox(height: 16.h),
                  Text('Order ID: ${widget.orderIds.join(', ').take(20)}...', style: TextStyle(color: Colors.black38, fontSize: 10.sp)),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  SizedBox(height: 16.h),
                  _buildPaymentMethod('QRIS (Gopay, Dana, OVO, LinkAja)', 'qris', Icons.qr_code_2),
                  SizedBox(height: 12.h),
                  _buildPaymentMethod('Virtual Account BCA', 'va_bca', Icons.account_balance),
                  SizedBox(height: 12.h),
                  _buildPaymentMethod('Virtual Account Mandiri', 'va_mandiri', Icons.account_balance),
                  SizedBox(height: 12.h),
                  _buildPaymentMethod('Kartu Kredit / Debit', 'credit_card', Icons.credit_card),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          height: 50.h,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: navyColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: _isProcessing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String value, IconData icon) {
    final bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4F4F8) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF1E1E50) : Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF1E1E50) : Colors.black54),
            SizedBox(width: 16.w),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF1E1E50) : Colors.grey),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String take(int limit) {
    return length <= limit ? this : substring(0, limit);
  }
}
