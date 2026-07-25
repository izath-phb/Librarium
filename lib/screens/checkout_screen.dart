import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/book.dart';
import '../services/cart_service.dart';
import '../widgets/cart_badge_icon.dart';
import 'payment_method_screen.dart';
import 'address_selection_screen.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import 'payment_gateway_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Book? book; // Retained for compatibility, but we primarily use CartService

  const CheckoutScreen({super.key, this.book});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  String _selectedShipping = 'Ekspres';
  String _selectedPaymentMethod = 'Kartu Kredit / Debit';
  String _currentAddress = 'Jl. Kebon Sirih No. 45, Menteng, Jakarta Pusat, DKI Jakarta, 10340';

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      final apiService = ApiService();
      final profile = await apiService.getUserProfile();
      if (profile != null && profile['address'] != null && profile['address'].toString().isNotEmpty) {
        if (mounted) {
          setState(() {
            _currentAddress = profile['address'];
          });
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color goldColor = Color(0xFF8B7355);
    const Color bgColor = Color(0xFFFAF9F6);

    final items = _cartService.items;
    final double subtotal = _cartService.subtotal;
    final double shippingCost = _selectedShipping == 'Ekspres' ? 25000 : 12000;
    final double promoDiscount = 15000;
    final double total = subtotal + shippingCost - promoDiscount;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: navyColor),
                      SizedBox(width: 8.w),
                      Text(
                        'Alamat\nPengiriman',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: navyColor,
                          fontFamily: 'serif',
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final newAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressSelectionScreen(currentAddress: _currentAddress),
                        ),
                      );
                      if (newAddress != null && newAddress.toString().isNotEmpty) {
                        setState(() {
                          _currentAddress = newAddress as String;
                        });
                        final apiService = ApiService();
                        apiService.updateProfile({'address': newAddress});
                      }
                    },
                    child: Text('Ubah\nAlamat', textAlign: TextAlign.right, style: TextStyle(fontSize: 10.sp, color: navyColor)),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          color: const Color(0xFFFFD580),
                          child: Text('Rumah', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 8.w),
                        Text('Andi Pratama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(_currentAddress, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
                    SizedBox(height: 4.h),
                    Text('+62 812-3456-7890', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () async {
                        final newAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressSelectionScreen(currentAddress: _currentAddress),
                          ),
                        );
                        if (newAddress != null && newAddress.toString().isNotEmpty) {
                          setState(() {
                            _currentAddress = newAddress as String;
                          });
                          final apiService = ApiService();
                          apiService.updateProfile({'address': newAddress});
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Container(
                          height: 80.h,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Image.network(
                            'https://maps.googleapis.com/maps/api/staticmap?center=Jakarta&zoom=14&size=400x150&maptype=roadmap&markers=color:blue%7CJakarta&key=YOUR_API_KEY', // Placeholder
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000&auto=format&fit=crop',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: navyColor),
                  SizedBox(width: 8.w),
                  Text(
                    'Metode Pengiriman',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: navyColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  setState(() { _selectedShipping = 'Ekspres'; });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _selectedShipping == 'Ekspres' ? const Color(0xFFF4F4F8) : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: _selectedShipping == 'Ekspres' ? navyColor : Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ekspres (1-2 Hari)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Text('Kurir Kilat Librarium', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                          SizedBox(height: 8.h),
                          Text('Rp 25.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: navyColor)),
                        ],
                      ),
                      Icon(_selectedShipping == 'Ekspres' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: navyColor),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  setState(() { _selectedShipping = 'Reguler'; });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _selectedShipping == 'Reguler' ? const Color(0xFFF4F4F8) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: _selectedShipping == 'Reguler' ? navyColor : Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reguler (3-5 Hari)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Text('Layanan Standar Terpercaya', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                          SizedBox(height: 8.h),
                          Text('Rp 12.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: navyColor)),
                        ],
                      ),
                      Icon(_selectedShipping == 'Reguler' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              Row(
                children: [
                  const Icon(Icons.payment_outlined, color: navyColor),
                  SizedBox(width: 8.w),
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: navyColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedPaymentMethod = result as String;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance, color: Colors.black54),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedPaymentMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              SizedBox(height: 4.h),
                              Text('Pilih/Ubah Metode', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Order Summary Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F8),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: navyColor,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // List of items in cart
                    ...items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Row(
                        children: [
                          Container(
                            height: 60.h,
                            width: 40.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: item.book.imageUrl != null
                                  ? Image.network(item.book.imageUrl!, fit: BoxFit.cover)
                                  : const Icon(Icons.book, size: 20),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.book.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(item.book.author, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                                SizedBox(height: 4.h),
                                Text('Rp ${item.book.price.toInt()} (x${item.quantity})', style: TextStyle(fontSize: 12.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    
                    const Divider(),
                    SizedBox(height: 16.h),
                    _buildSummaryRow('Subtotal (${items.length} Produk)', 'Rp ${subtotal.toInt()}'),
                    SizedBox(height: 12.h),
                    _buildSummaryRow('Biaya Pengiriman', 'Rp ${shippingCost.toInt()}'),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Potongan Promo', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                        Text('- Rp ${promoDiscount.toInt()}', style: TextStyle(fontSize: 12.sp, color: Colors.red)),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: navyColor)),
                        Text('Rp ${total.toInt()}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: navyColor)),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Curator Quote
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: goldColor, width: 3)),
                      ),
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text(
                        '"Pesanan Anda dikemas menggunakan bahan ramah lingkungan dan melalui pengecekan kualitas manual oleh tim kurator kami."',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontSize: 11.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (items.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang kosong!')));
                            return;
                          }
                          
                          // Tampilkan loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(child: CircularProgressIndicator());
                            },
                          );

                          final apiService = ApiService();
                          bool success = true;
                          List<String> createdOrderIds = [];

                          for (var item in items) {
                            for (int i = 0; i < item.quantity; i++) {
                              final order = Order(
                                customerName: 'Andi Pratama',
                                customerAddress: _currentAddress,
                                latitude: -6.175110,
                                longitude: 106.865039,
                                bookId: item.book.id,
                                totalPrice: total / items.length, // approximation per item
                              );
                              final result = await apiService.createOrder(order);
                              if (result == null || result.id == null) {
                                success = false;
                              } else {
                                createdOrderIds.add(result.id!);
                              }
                            }
                          }
                          
                          // Tutup loading dialog
                          Navigator.pop(context);

                          if (success && createdOrderIds.isNotEmpty) {
                            _cartService.clearCart();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentGatewayScreen(
                                  orderIds: createdOrderIds,
                                  totalAmount: total,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Terjadi kesalahan saat memproses pesanan.'),
                                backgroundColor: Colors.red,
                              )
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8.w),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, size: 12.sp, color: Colors.black54),
                          SizedBox(width: 4.w),
                          Text('Transaksi Terenkripsi & Aman', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
}

