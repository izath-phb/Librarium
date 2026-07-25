import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'address_selection_screen.dart';
import '../widgets/cart_badge_icon.dart';
import 'edit_profile_screen.dart';
import 'wishlist_screen.dart';
import 'help_center_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ApiService apiService = ApiService();
  bool _isLoading = true;
  String _fullName = '';
  String _email = '';
  String? _avatarUrl;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await apiService.getUserProfile();
      if (profile != null) {
        setState(() {
          _fullName = profile['full_name'] ?? 'Unknown User';
          _email = profile['email'] ?? 'No Email';
          _avatarUrl = profile['avatar_url'];
          _address = profile['address'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        leading: null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
        centerTitle: true,
        actions: [
          const CartBadgeIcon(color: navyColor),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    // Profile Info
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: goldColor, width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(_avatarUrl != null && _avatarUrl!.isNotEmpty ? ApiService.getFullImageUrl(_avatarUrl!) : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        initialName: _fullName,
                                        initialAvatarUrl: _avatarUrl,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchUserProfile(); // Refresh after update
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: navyColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(Icons.edit, color: Colors.white, size: 12.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _fullName.isNotEmpty ? _fullName : 'Guest',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'serif',
                              color: navyColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE4B3),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars, color: const Color(0xFFC49A45), size: 16.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  '2,450 Loyalty Points',
                                  style: TextStyle(
                                    color: const Color(0xFF6B531C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // PENGATURAN AKUN
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PENGATURAN AKUN',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSettingsMenu(context, 'Pesanan Saya', Icons.inventory_2_outlined, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
                    }),
                    _buildSettingsMenu(context, 'Wishlist', Icons.favorite_border, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                    }),
                    _buildSettingsMenu(context, 'Alamat Tersimpan', Icons.location_on_outlined, () async {
                      final newAddress = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddressSelectionScreen(currentAddress: _address)));
                      if (newAddress != null && newAddress.toString().isNotEmpty && newAddress != _address) {
                        showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => const Center(child: CircularProgressIndicator()));
                        final success = await apiService.updateProfile({'address': newAddress});
                        Navigator.pop(context); // close dialog
                        if (success) {
                          _showSnackBar(context, 'Alamat berhasil diperbarui.');
                          _fetchUserProfile();
                        } else {
                          _showSnackBar(context, 'Gagal memperbarui alamat.');
                        }
                      }
                    }),
                    _buildSettingsMenu(context, 'Pusat Bantuan', Icons.help_outline, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                    }),

                    SizedBox(height: 16.h),
                    // Logout Button
                    GestureDetector(
                      onTap: () async {
                        await apiService.logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Librarian's Note
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF9F6),
                        border: Border(left: BorderSide(color: goldColor, width: 3.w)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"Welcome back, ${_fullName.isNotEmpty ? _fullName.split(' ')[0] : 'Guest'}. Based on your recent interest in 19th-century literature, we\'ve set aside a first-edition copy of \'Middlemarch\' for your review."',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14.sp,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '— LIBRARIAN\'S NOTE',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: goldColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Currently Reading
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
                          Text(
                            'CURRENTLY READING',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Container(
                                width: 50.w,
                                height: 75.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Image.network('https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=200&auto=format&fit=crop', fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'The Great Gatsby',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: navyColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'F. Scott Fitzgerald',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Progress', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                              Text('65%', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: navyColor)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          LinearProgressIndicator(
                            value: 0.65,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(navyColor),
                            minHeight: 4.h,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Membership Card
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: navyColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MEMBERSHIP',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Scholar Elite',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'serif',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Free shipping on all curated collections.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: () {
                                    _showSnackBar(context, 'Fitur View Benefits belum tersedia.');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: goldColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                  ),
                                  child: const Text('View Benefits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.menu_book, size: 80.sp, color: Colors.white.withValues(alpha: 0.1)),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Recent Activity
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'RECENT ACTIVITY',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildActivityItem(Icons.shopping_bag_outlined, 'Order #LIB-9902 Placed', '2 days ago • 3 books included'),
                    _buildActivityItem(Icons.rate_review_outlined, 'Review Posted: "The Alchemist"', '1 week ago • 4.5 Stars'),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F8),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1E1E50), size: 20.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1E1E50),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: const Color(0xFF1E1E50), size: 20.sp),
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
                    color: const Color(0xFF1E1E50),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
