import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Book>> _booksFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _booksFuture = _apiService.getBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = _apiService.getBooks();
    });
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
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari koleksi buku...',
            prefixIcon: const Icon(Icons.search, color: navyColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          style: TextStyle(color: navyColor, fontSize: 14.sp),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshBooks();
        },
        child: FutureBuilder<List<Book>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No books available.'));
            }

            final allBooks = snapshot.data!;
            final books = allBooks.where((book) {
              if (_searchQuery.isEmpty) return true;
              return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                     book.author.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'Jelajahi Koleksi',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'serif',
                      color: navyColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: GridView.builder(
                      itemCount: books.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.55,
                      ),
                      itemBuilder: (context, index) {
                        return _buildGridBookCard(context, books[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridBookCard(BuildContext context, Book book) {
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                  child: book.imageUrl != null
                      ? Image.network(book.imageUrl!, fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: const Color(0xFF1E1E50),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Rp ${book.price.toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: const Color(0xFF1E1E50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
