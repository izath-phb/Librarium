import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../widgets/cart_badge_icon.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Book book;

  const ProductDetailScreen({super.key, required this.book});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedFormat = 'Hardcover';
  
  final ApiService _apiService = ApiService();
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  
  final TextEditingController _commentController = TextEditingController();
  String? _replyingToId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final data = await _apiService.getComments(widget.book.id);
      setState(() {
        _comments = data.map((c) => Comment.fromJson(c)).toList();
      });
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final text = _commentController.text.trim();
    _commentController.clear();
    
    // Optimistic UI could be added, but we just re-fetch for simplicity
    final newComment = await _apiService.postComment(widget.book.id, text, parentId: _replyingToId);
    
    if (newComment != null) {
      _fetchComments();
      setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar berhasil ditambahkan.')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambahkan komentar. Pastikan Anda sudah login.')));
      }
    }
  }

  void _addToCart() {
    CartService().addItem(widget.book, format: _selectedFormat);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.book.title} ($_selectedFormat) ditambahkan ke keranjang.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color goldColor = Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        leadingWidth: 150.w,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black54),
          label: Text(
            'Back to Catalog',
            style: TextStyle(color: Colors.black54, fontSize: 12.sp),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E1E50)),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Pencarian belum tersedia.')));
            },
          ),
          const CartBadgeIcon(color: Color(0xFF1E1E50)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Book Cover Image
              Center(
                child: Container(
                  width: 220.w,
                  height: 320.h,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: widget.book.imageUrl != null
                        ? Image.network(widget.book.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.book, size: 80, color: Colors.grey)),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('PAGES', '432', Icons.book_outlined),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard('LANGUAGE', 'EN', Icons.language_outlined),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard('RATING', '4.9', Icons.star_border),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Badges / Format Selection
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBadge('New Arrival', const Color(0xFFFFD580), false, () {}),
                    SizedBox(width: 8.w),
                    _buildBadge('Hardcover', _selectedFormat == 'Hardcover' ? navyColor : Colors.grey[200]!, _selectedFormat == 'Hardcover', () {
                      setState(() { _selectedFormat = 'Hardcover'; });
                    }),
                    SizedBox(width: 8.w),
                    _buildBadge('Audiobook', _selectedFormat == 'Audiobook' ? navyColor : Colors.grey[200]!, _selectedFormat == 'Audiobook', () {
                      setState(() { _selectedFormat = 'Audiobook'; });
                    }),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Title and Author
              Text(
                widget.book.title,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: navyColor,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              RichText(
                text: TextSpan(
                  text: 'by ',
                  style: TextStyle(color: Colors.black54, fontSize: 16.sp),
                  children: [
                    TextSpan(
                      text: widget.book.author,
                      style: TextStyle(
                        color: goldColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${widget.book.price.toInt()}',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: navyColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'Rp ${(widget.book.price * 1.2).toInt()}', 
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Rating Stars
              Row(
                children: [
                  ...List.generate(4, (index) => const Icon(Icons.star, color: goldColor, size: 16)),
                  const Icon(Icons.star_half, color: goldColor, size: 16),
                  SizedBox(width: 8.w),
                  Text('(1,348 Reviews)', style: TextStyle(color: Colors.black54, fontSize: 12.sp)),
                ],
              ),
              SizedBox(height: 32.h),

              // Synopsis
              Text(
                'SYNOPSIS',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.book.description ?? 'No description available for this book.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 32.h),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CartService().addItem(widget.book, format: _selectedFormat);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(book: widget.book),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  label: Text('Beli Sekarang', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0B45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF1E1E50), size: 20),
                  label: Text('Tambah ke Keranjang', style: TextStyle(color: Color(0xFF1E1E50), fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E1E50)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Comments Section
              const Divider(),
              SizedBox(height: 16.h),
              Text(
                'DISKUSI & KOMENTAR',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: navyColor,
                ),
              ),
              SizedBox(height: 16.h),
              
              if (_isLoadingComments)
                const Center(child: CircularProgressIndicator())
              else if (_comments.isEmpty)
                Text(
                  'Belum ada komentar. Jadilah yang pertama!',
                  style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                )
              else
                _buildCommentList(),
                
              SizedBox(height: 24.h),
              
              // Comment Input
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_replyingToId != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Membalas $_replyingToName', style: TextStyle(fontSize: 10.sp, color: navyColor, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _replyingToId = null;
                                _replyingToName = null;
                              });
                            },
                            child: Icon(Icons.close, size: 14.sp, color: Colors.black54),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar Anda...',
                              hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 12.sp),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF1E1E50)),
                          onPressed: _submitComment,
                        ),
                      ],
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

  Widget _buildCommentList() {
    // Group comments into root comments and replies
    final rootComments = _comments.where((c) => c.parentId == null).toList();
    final replies = _comments.where((c) => c.parentId != null).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rootComments.length,
      itemBuilder: (context, index) {
        final comment = rootComments[index];
        final commentReplies = replies.where((r) => r.parentId == comment.id).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSingleComment(comment, false),
            if (commentReplies.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 32.w),
                child: Column(
                  children: commentReplies.map((r) => _buildSingleComment(r, true)).toList(),
                ),
              ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }

  Widget _buildSingleComment(Comment comment, bool isReply) {
    String timeAgo = 'Baru saja';
    try {
      final date = DateTime.parse(comment.createdAt);
      timeAgo = DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
    } catch (_) {}

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isReply ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(isReply ? 0.0 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.userName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: const Color(0xFF1E1E50)),
              ),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.text,
            style: TextStyle(fontSize: 12.sp, color: Colors.black87),
          ),
          SizedBox(height: 8.h),
          if (!isReply)
            GestureDetector(
              onTap: () {
                setState(() {
                  _replyingToId = comment.id;
                  _replyingToName = comment.userName;
                });
              },
              child: Text(
                'Balas',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF8B7355)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F8),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8B7355)),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 9.sp, color: Colors.black54, letterSpacing: 0.5),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E1E50)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
