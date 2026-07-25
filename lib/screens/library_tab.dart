import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Book> _myBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchLibrary();
  }

  Future<void> _fetchLibrary() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _apiService.getMyOrders();
      final allBooks = await _apiService.getBooks();
      
      final orderedBookIds = orders.map((o) => o.bookId).toSet();
      _myBooks = allBooks.where((b) => orderedBookIds.contains(b.id)).toList();
    } catch (e) {
      print('Error fetching library: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: Text(
          'My Library',
          style: TextStyle(
            color: navyColor,
            fontWeight: FontWeight.w900,
            fontSize: 20.sp,
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books_outlined, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'Your library is empty.',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Books you order will appear here.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: _myBooks.length,
                  itemBuilder: (context, index) {
                    final book = _myBooks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(book: book),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                image: DecorationImage(
                                  image: NetworkImage(book.imageUrl ?? 'https://via.placeholder.com/150'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: navyColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
