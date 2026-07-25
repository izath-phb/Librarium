import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/wishlist_service.dart';
import 'product_detail_screen.dart';
import '../widgets/cart_badge_icon.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WishlistService().addListener(_onWishlistChanged);
  }

  @override
  void dispose() {
    WishlistService().removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    final wishlist = WishlistService().items;

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
          'Wishlist',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
        actions: const [
          CartBadgeIcon(color: navyColor),
        ],
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text('Wishlist Anda masih kosong.', style: TextStyle(color: Colors.black54, fontSize: 14.sp)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final book = wishlist[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(book: book),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: book.imageUrl != null
                              ? Image.network(
                                  book.imageUrl!,
                                  width: 60.w,
                                  height: 90.h,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 60.w,
                                  height: 90.h,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book, color: Colors.grey),
                                ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: navyColor,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                book.author,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Rp ${book.price.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: const Color(0xFF8B7355),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            WishlistService().toggleWishlist(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${book.title} dihapus dari wishlist.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
