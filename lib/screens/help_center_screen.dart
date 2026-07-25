import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
          'Pusat Bantuan',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: navyColor,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFaqItem('Bagaimana cara melacak pesanan saya?', 'Anda dapat melacak pesanan Anda melalui menu "Pesanan Saya" di halaman profil. Di sana Anda akan melihat status terkini dari pesanan Anda.'),
          _buildFaqItem('Berapa lama waktu pengiriman?', 'Waktu pengiriman bervariasi tergantung lokasi Anda. Biasanya membutuhkan 2-5 hari kerja untuk area Jabodetabek, dan 3-7 hari kerja untuk luar Jabodetabek.'),
          _buildFaqItem('Apakah saya bisa membatalkan pesanan?', 'Pesanan hanya dapat dibatalkan jika statusnya belum "Diproses". Jika sudah diproses, Anda tidak dapat membatalkan pesanan tersebut.'),
          _buildFaqItem('Bagaimana cara mengembalikan buku yang rusak?', 'Silakan hubungi layanan pelanggan kami melalui email di support@librarium.com dengan menyertakan foto buku yang rusak beserta nomor pesanan dalam waktu 2x24 jam setelah barang diterima.'),
          
          SizedBox(height: 32.h),
          Text(
            'Hubungi Kami',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: navyColor,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: navyColor),
                  title: Text('Email', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                  subtitle: Text('support@librarium.com', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: navyColor)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone, color: navyColor),
                  title: Text('Telepon', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                  subtitle: Text('0800-1-999-999 (Bebas Pulsa)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: navyColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E50),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
