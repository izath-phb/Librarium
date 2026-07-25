import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/cart_service.dart';
import 'checkout_screen.dart';
import '../widgets/cart_badge_icon.dart';
import '../services/save_for_later_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final SaveForLaterService _saveForLaterService = SaveForLaterService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartUpdated);
    _saveForLaterService.addListener(_onCartUpdated);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartUpdated);
    _saveForLaterService.removeListener(_onCartUpdated);
    super.dispose();
  }

  void _onCartUpdated() {
    setState(() {}); // Rebuild when cart changes
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color goldColor = Color(0xFF8B7355);
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
        title: Text(
          'Librarium',
          style: TextStyle(
            color: navyColor,
            fontWeight: FontWeight.w900,
            fontSize: 20.sp,
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
        actions: [
          const CartBadgeIcon(color: navyColor),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios, size: 12, color: Colors.black54),
                    SizedBox(width: 4.w),
                    Text(
                      'Continue Browsing',
                      style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Keranjang\nBelanja',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: navyColor,
                      height: 1.1,
                      fontFamily: 'serif',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      '${_cartService.itemCount} Items\nSelected',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              if (_cartService.items.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _cartService.clearCart();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang berhasil dikosongkan.')));
                    },
                    icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 18),
                    label: Text('Hapus Semua', style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                  ),
                ),
              SizedBox(height: 8.h),
              const Divider(),
              SizedBox(height: 16.h),

              if (_cartService.items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      'Keranjang Anda kosong.',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = _cartService.items[index];
                    return _buildCartItem(item, navyColor);
                  },
                ),

              if (_cartService.items.isNotEmpty) ...[
                SizedBox(height: 32.h),
                // Curator Quote
                Container(
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: goldColor, width: 3)),
                  ),
                  padding: EdgeInsets.only(left: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"The selection in your basket suggests a deep appreciation for introspective narratives. We recommend pairing these with a quiet corner and a warm brew."',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '— Librarium Head Curator',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Order Summary Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                          color: navyColor,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildSummaryRow('Subtotal', 'Rp ${_cartService.subtotal.toInt()}'),
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Shipping', 'Rp 25.000'),
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Service Fee', 'Rp 2.000'),
                      SizedBox(height: 16.h),
                      const Divider(),
                      SizedBox(height: 16.h),
                      Text(
                        'Total',
                        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rp ${(_cartService.subtotal + 27000).toInt()}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: navyColor,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            color: const Color(0xFFFFF7E6),
                            child: Text(
                              'VAT Included',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Pass the first book for demonstration (in a real app, you'd pass the whole cart or create an order)
                                builder: (context) => CheckoutScreen(book: _cartService.items.first.book),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('CHECKOUT NOW', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              SizedBox(width: 8.w),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_cartService.items.isNotEmpty) {
                              for (var item in List.from(_cartService.items)) {
                                _saveForLaterService.saveForLater(item);
                                _cartService.removeItem(item.book, item.format);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua item dipindahkan ke Save for Later.')));
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          ),
                          child: Text('SAVE FOR LATER', style: TextStyle(color: navyColor, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text('Promo Code', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40.h,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter code',
                                  hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            height: 40.h,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                              ),
                              child: Text('Apply', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      const Divider(),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.verified_user_outlined, color: Colors.black54, size: 24.sp),
                          Icon(Icons.local_shipping_outlined, color: Colors.black54, size: 24.sp),
                          Icon(Icons.assignment_return_outlined, color: Colors.black54, size: 24.sp),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              if (_saveForLaterService.items.isNotEmpty) ...[
                SizedBox(height: 40.h),
                Text(
                  'Saved for Later',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: navyColor,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _saveForLaterService.items.length,
                  itemBuilder: (context, index) {
                    final item = _saveForLaterService.items[index];
                    return _buildSavedItem(item, navyColor);
                  },
                ),
              ],

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, Color navyColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            height: 160.h,
            width: 110.w,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: item.book.imageUrl != null
                  ? Image.network(item.book.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.book, size: 40)),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            item.book.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: navyColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            item.book.author,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: navyColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Text(
              item.format.toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuantityButton(Icons.remove, () {
                _cartService.updateQuantity(item.book, item.format, item.quantity - 1);
              }),
              Container(
                width: 40.w,
                height: 32.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Text('${item.quantity}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ),
              _buildQuantityButton(Icons.add, () {
                _cartService.updateQuantity(item.book, item.format, item.quantity + 1);
              }),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Rp ${(item.book.price * item.quantity).toInt()}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: navyColor,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              _cartService.removeItem(item.book, item.format);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 16.sp, color: Colors.black54),
                SizedBox(width: 4.w),
                Text('Remove', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, size: 16.sp, color: Colors.black54),
      ),
    );
  }

  Widget _buildSavedItem(CartItem item, Color navyColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: item.book.imageUrl != null
                ? Image.network(item.book.imageUrl!, width: 60.w, height: 90.h, fit: BoxFit.cover)
                : Container(width: 60.w, height: 90.h, color: Colors.grey[200], child: const Icon(Icons.book, size: 40)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.book.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: navyColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(item.book.author, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                SizedBox(height: 8.h),
                Text('Rp ${(item.book.price).toInt()}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: navyColor)),
              ],
            ),
          ),
          Column(
            children: [
              OutlinedButton(
                onPressed: () {
                  _saveForLaterService.moveToCart(item);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.book.title} dipindahkan ke Keranjang.')));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: navyColor),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  minimumSize: Size.zero,
                ),
                child: Text('Move to Cart', style: TextStyle(fontSize: 10.sp, color: navyColor, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  _saveForLaterService.removeItem(item);
                },
                child: Text('Remove', style: TextStyle(fontSize: 10.sp, color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
