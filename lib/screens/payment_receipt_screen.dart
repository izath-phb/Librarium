import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'main_dashboard.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final List<String> orderIds;
  final double totalAmount;
  final String paymentMethod;

  const PaymentReceiptScreen({
    super.key,
    required this.orderIds,
    required this.totalAmount,
    required this.paymentMethod,
  });

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'qris': return 'QRIS (Gopay, Dana, OVO, LinkAja)';
      case 'va_bca': return 'Virtual Account BCA';
      case 'va_mandiri': return 'Virtual Account Mandiri';
      case 'credit_card': return 'Kartu Kredit / Debit';
      default: return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color bgColor = Color(0xFFFAF9F6);
    final String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevents going back to payment process
        title: Text(
          'Struk Pembayaran',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 64.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'Pembayaran Berhasil!',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: navyColor),
              ),
              SizedBox(height: 8.h),
              Text(
                'Terima kasih telah berbelanja di Librarium.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
              ),
              SizedBox(height: 32.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Detail Transaksi',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: navyColor),
                      ),
                    ),
                    Divider(height: 32.h, thickness: 1, color: Colors.grey.withOpacity(0.2)),
                    _buildDetailRow('Tanggal', formattedDate),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Metode Pembayaran', _getPaymentMethodName(paymentMethod)),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Order ID', orderIds.join(', ')),
                    Divider(height: 32.h, thickness: 1, color: Colors.grey.withOpacity(0.2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          'Rp ${totalAmount.toInt()}',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: navyColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainDashboard()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: navyColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
