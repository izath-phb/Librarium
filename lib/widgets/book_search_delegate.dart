import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../screens/product_detail_screen.dart';

class BookSearchDelegate extends SearchDelegate<Book?> {
  final ApiService _apiService = ApiService();

  @override
  String get searchFieldLabel => 'Cari buku, penulis...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF9F6),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1E1E50)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: const Color(0xFF1E1E50), fontSize: 16.sp),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Book>>(
      future: _apiService.getBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada buku tersedia.'));
        }

        final allBooks = snapshot.data!;
        final books = allBooks.where((book) {
          if (query.isEmpty) return true;
          return book.title.toLowerCase().contains(query.toLowerCase()) || 
                 book.author.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (books.isEmpty) {
          return Center(
            child: Text(
              'Buku tidak ditemukan untuk "$query"',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              leading: Container(
                width: 50.w,
                height: 70.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: book.imageUrl != null
                      ? Image.network(book.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.book, color: Colors.grey),
                ),
              ),
              title: Text(
                book.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: const Color(0xFF1E1E50)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    book.author,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Rp ${book.price.toInt()}',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E1E50)),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(book: book),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
