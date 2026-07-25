import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/order.dart';
import '../models/book.dart';

class TrackOrderScreen extends StatelessWidget {
  final Order order;
  final Book book;

  const TrackOrderScreen({super.key, required this.order, required this.book});

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
          icon: const Icon(Icons.arrow_back, color: navyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lacak Pesanan',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Header
            Container(
              padding: EdgeInsets.all(24.w),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: NetworkImage(book.imageUrl ?? 'https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id?.substring(0, 8).toUpperCase()}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          book.title,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: navyColor),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Rp ${order.totalPrice.toInt()}',
                          style: TextStyle(fontSize: 14.sp, color: navyColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Tracking Timeline
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Riwayat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: navyColor)),
                  SizedBox(height: 24.h),
                  _buildTimelineItem(
                    title: 'Pesanan Dibuat',
                    subtitle: 'Pesanan telah diterima oleh sistem.',
                    date: _formatDate(order.createdAt),
                    isCompleted: true,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Pembayaran Berhasil',
                    subtitle: 'Pembayaran telah dikonfirmasi.',
                    date: _formatDate(order.createdAt), // Simulate slightly later time if needed
                    isCompleted: order.status == 'paid' || order.status == 'shipped' || order.status == 'delivered',
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Pesanan Diproses',
                    subtitle: 'Buku sedang disiapkan dan dikemas.',
                    date: '',
                    isCompleted: order.status == 'shipped' || order.status == 'delivered',
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Sedang Dikirim',
                    subtitle: 'Pesanan telah diserahkan ke pihak kurir.',
                    date: '',
                    isCompleted: order.status == 'shipped' || order.status == 'delivered',
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Pesanan Selesai',
                    subtitle: 'Pesanan telah tiba di tujuan.',
                    date: '',
                    isCompleted: order.status == 'delivered',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}-${d.month}-${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String date,
    required bool isCompleted,
    required bool isLast,
  }) {
    const Color navyColor = Color(0xFF1E1E50);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? navyColor : Colors.grey[300],
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 50.h,
                color: isCompleted ? navyColor : Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isCompleted ? navyColor : Colors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
              SizedBox(height: 4.h),
              if (date.isNotEmpty && isCompleted)
                Text(
                  date,
                  style: TextStyle(fontSize: 10.sp, color: Colors.black38),
                ),
              if (!isLast) SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }
}
