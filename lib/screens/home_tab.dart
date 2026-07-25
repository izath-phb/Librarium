import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Book>> _booksFuture;
  
  String _selectedCategory = 'Semua';
  final Set<String> _favoriteBookIds = {};
  
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['Semua', 'Fiksi', 'Non-Fiksi', 'Bisnis', 'Sejarah'];

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

  void _toggleFavorite(String bookId) {
    setState(() {
      if (_favoriteBookIds.contains(bookId)) {
        _favoriteBookIds.remove(bookId);
      } else {
        _favoriteBookIds.add(bookId);
      }
    });
  }

  List<Book> _filterBooks(List<Book> allBooks) {
    List<Book> filtered = allBooks;

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((book) {
        final query = _searchQuery.toLowerCase();
        return book.title.toLowerCase().contains(query) || 
               book.author.toLowerCase().contains(query);
      }).toList();
    }

    // Mock Filter by Category using Deterministic Hash
    if (_selectedCategory != 'Semua') {
      int catIndex = _categories.indexOf(_selectedCategory);
      filtered = filtered.where((book) {
        // Assign a mock category based on book title length or ID hash to simulate filtering
        int mockCat = (book.title.length) % 4 + 1; // 1 to 4
        return mockCat == catIndex;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
                style: TextStyle(color: const Color(0xFF1E1E50), fontSize: 14.sp),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Row(
                children: [
                  const Icon(Icons.menu_book, color: Color(0xFF1E1E50)),
                  SizedBox(width: 8.w),
                  Text(
                    'Librarium',
                    style: TextStyle(
                      color: const Color(0xFF1E1E50),
                      fontWeight: FontWeight.w900,
                      fontSize: 20.sp,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFF1E1E50)),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1E1E50)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
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
            final books = _filterBooks(allBooks);
            
            final rekomendasiBooks = books.length >= 2 ? books.sublist(0, 2) : books;
            final terpopulerBooks = books.length > 2 ? books.sublist(2) : books;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSearching) ...[
                      SizedBox(height: 16.h),
                      // Hero Banner
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E50),
                          borderRadius: BorderRadius.circular(12.r),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=1000&auto=format&fit=crop'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesta Literasi:\nDiskon hingga 50%\nuntuk Novel Terlaris',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo diterapkan!')));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: const Text(
                                  'Lihat Promo',
                                  style: TextStyle(
                                    color: Color(0xFF1E1E50),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ] else SizedBox(height: 16.h),

                    // Kategori Populer
                    Text(
                      'Kategori Populer',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: const Color(0xFF1E1E50),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: _buildCategoryChip(cat),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    if (books.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Text(
                            'Tidak ada buku yang sesuai.',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                          ),
                        ),
                      )
                    else ...[
                      // Rekomendasi Untukmu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rekomendasi\nUntukmu',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              height: 1.2,
                              color: const Color(0xFF1E1E50),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menampilkan semua buku rekomendasi...')));
                            },
                            child: Text(
                              'Lihat Semua >',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF1E1E50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      if (rekomendasiBooks.isNotEmpty)
                        SizedBox(
                          height: 280.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: rekomendasiBooks.length,
                            itemBuilder: (context, index) {
                              return _buildHorizontalBookCard(context, rekomendasiBooks[index]);
                            },
                          ),
                        ),
                      SizedBox(height: 32.h),

                      // Quote Section
                      if (!_isSearching) ...[
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 3.w,
                                    height: 80.h,
                                    color: const Color(0xFF8B7355),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '"Buku ini mengubah cara saya memandang arsitektur modern dalam keseharian. Wajib dibaca bagi penikmat seni visual."',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14.sp,
                                            color: const Color(0xFF8B7355),
                                            height: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          '— Sarah, Kurator Librarium',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            color: const Color(0xFF8B7355),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],

                      // Buku Terpopuler
                      if (terpopulerBooks.isNotEmpty) ...[
                        Text(
                          'Buku Terpopuler',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                            color: const Color(0xFF1E1E50),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: terpopulerBooks.length,
                          itemBuilder: (context, index) {
                            return _buildVerticalBookCard(context, terpopulerBooks[index], index == 0 && !_isSearching);
                          },
                        ),
                      ],
                    ],
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4F4F8) : Colors.transparent,
          border: Border.all(color: isSelected ? const Color(0xFF1E1E50) : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E1E50) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBookCard(BuildContext context, Book book) {
    final bool isFavorite = _favoriteBookIds.contains(book.id);
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
        width: 160.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: book.imageUrl != null
                        ? Image.network(book.imageUrl!, fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(book.id),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? Colors.red : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: const Color(0xFF1E1E50),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Rp ${book.price.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: const Color(0xFF1E1E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBookCard(BuildContext context, Book book, bool isFirstHero) {
    if (isFirstHero) {
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
          margin: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 350.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: book.imageUrl != null
                        ? Image.network(book.imageUrl!, fit: BoxFit.cover)
                        : Container(color: Colors.grey[200], child: const Icon(Icons.book, size: 50)),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'PILIHAN EDITOR',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFF8B7355),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                book.title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  color: const Color(0xFF1E1E50),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                book.description ?? 'Kisah epik tentang seorang pemimpi yang mampu merajut realitas baru melalui benang-benang kosmik. Sebuah...',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${book.price.toInt()}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E50),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(
                      'Rp ${(book.price * 1.2).toInt()}', // Mock original price
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(book: book),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B0B45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: Text('Beli Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
            ],
          ),
        ),
      );
    } else {
      // Regular horizontal list item for popular books
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
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: book.imageUrl != null
                      ? Image.network(book.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.book, color: Colors.grey),
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
                        color: const Color(0xFF1E1E50),
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
}

