import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _apiService.getBooks();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = _apiService.getBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Librarium Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBooks,
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: ListTile(
                  leading: const Icon(Icons.book, size: 40),
                  title: Text(book.title),
                  subtitle: Text('${book.author}\n\$${book.price.toStringAsFixed(2)}'),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(book: book),
                        ),
                      );
                    },
                    child: const Text('Buy'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
