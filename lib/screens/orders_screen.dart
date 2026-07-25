import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import '../models/book.dart';
import '../models/order.dart';
import '../widgets/cart_badge_icon.dart';
import 'track_order_screen.dart';

class DisplayOrder {
  final Order order;
  final Book book;
  final String status;
  final String date;
  final String title;
  final String author;
  final String infoText;
  final IconData infoIcon;
  final String imageUrl;
  final bool isOngoing;

  DisplayOrder({
    required this.order,
    required this.book,
    required this.status,
    required this.date,
    required this.title,
    required this.author,
    required this.infoText,
    required this.infoIcon,
    required this.imageUrl,
    required this.isOngoing,
  });
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<DisplayOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _apiService.getMyOrders();
      final books = await _apiService.getBooks();
      
      final Map<String, Book> bookMap = {
        for (var b in books) b.id: b
      };

      List<DisplayOrder> displayOrders = [];
      for (var order in orders) {
        final book = bookMap[order.bookId];
        if (book != null) {
          String formattedDate = 'Baru saja';
          if (order.createdAt != null) {
            try {
              final date = DateTime.parse(order.createdAt!);
              formattedDate = '${date.day}-${date.month}-${date.year}';
            } catch (_) {}
          }
          
          String displayStatus = 'DIPROSES';
          String infoText = 'Pesanan sedang disiapkan';
          IconData infoIcon = Icons.inventory_2_outlined;
          bool isOngoing = true;

          if (order.status == 'pending') {
            displayStatus = 'MENUNGGU PEMBAYARAN';
            infoText = 'Menunggu pembayaran diselesaikan';
            infoIcon = Icons.payment;
          } else if (order.status == 'shipped') {
            displayStatus = 'DIKIRIM';
            infoText = 'Pesanan sedang dalam perjalanan';
            infoIcon = Icons.local_shipping_outlined;
          } else if (order.status == 'delivered') {
            displayStatus = 'SELESAI';
            infoText = 'Pesanan telah sampai tujuan';
            infoIcon = Icons.check_circle_outline;
            isOngoing = false;
          }

          displayOrders.add(DisplayOrder(
            order: order,
            book: book,
            status: displayStatus,
            date: formattedDate,
            title: book.title,
            author: 'Oleh ${book.author}',
            infoText: infoText,
            infoIcon: infoIcon,
            imageUrl: book.imageUrl ?? 'https://via.placeholder.com/150',
            isOngoing: isOngoing,
          ));
        }
      }
      
      setState(() {
        _orders = displayOrders;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color bgColor = Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: navyColor),
            SizedBox(width: 8.w),
            Text(
              'Librarium',
              style: TextStyle(
                color: navyColor,
                fontWeight: FontWeight.w900,
                fontSize: 20.sp,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
        actions: [
          const CartBadgeIcon(color: navyColor),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Saya',
                      style: TextStyle(
                        color: navyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                        fontFamily: 'serif',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Pantau status pengiriman buku Anda atau lihat kembali koleksi yang telah Anda beli di arsip modern kami.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.sp,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: navyColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: navyColor,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Berlangsung'),
                    Tab(text: 'Selesai'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(_orders),
            _buildOrderList(_orders.where((o) => o.isOngoing).toList()),
            _buildOrderList(_orders.where((o) => !o.isOngoing).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<DisplayOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pesanan.',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      itemCount: orders.length + 1,
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return _buildCuratorQuote();
        }
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(DisplayOrder order) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color goldColor = Color(0xFF8B7355);

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Container(
            height: 250.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 16.h,
                  child: Text(
                    order.isOngoing ? '11:45 AM\nPesanan Sedang Dikirim' : '11:45 AM\nPesanan Selesai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
                  child: Container(
                    width: 140.w,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.network(order.imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          
          // Details Area
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: order.isOngoing ? goldColor : navyColor,
                      ),
                    ),
                    Text(
                      order.date,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  order.title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                    color: navyColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  order.author,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(order.infoIcon, size: 16.sp, color: navyColor),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        order.infoText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: navyColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                if (order.isOngoing)
                  SizedBox(
                    width: 140.w,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackOrderScreen(order: order.order, book: order.book),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: navyColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text('Lacak Pesanan', style: TextStyle(color: navyColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showSnackBar('Menambahkan ke keranjang...'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text('Beli Lagi', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showSnackBar('Buka form ulasan...'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text('Beri Ulasan', style: TextStyle(color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratorQuote() {
    return Container(
      margin: EdgeInsets.only(top: 16.h, bottom: 40.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        border: Border(left: BorderSide(color: const Color(0xFF8B7355), width: 3.w)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesan Kurator',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: const Color(0xFF1E1E50),
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '"Buku adalah saksi bisu dari perjalanan pikiran kita. Setiap pesanan yang Anda terima adalah awal dari percakapan baru antara Anda dan penulisnya. Selamat menikmati setiap halaman yang Anda buka."',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFAF9F6),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
