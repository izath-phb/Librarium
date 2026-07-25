import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/cart_service.dart';
import '../screens/cart_screen.dart'; // Ensure you navigate to cart if clicked

class CartBadgeIcon extends StatelessWidget {
  final Color color;

  const CartBadgeIcon({super.key, this.color = const Color(0xFF1E1E50)});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService(),
      builder: (context, child) {
        final int itemCount = CartService().itemCount;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: color),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            if (itemCount > 0)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.w,
                    minHeight: 16.w,
                  ),
                  child: Center(
                    child: Text(
                      itemCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
