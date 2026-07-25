import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal() {
    _loadWishlist();
  }

  List<Book> _items = [];

  List<Book> get items => _items;

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('wishlist_items');
    if (itemsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(itemsJson);
        _items = decoded.map((item) => Book.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print("Error loading wishlist: $e");
      }
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_items.map((b) => b.toJson()).toList());
    await prefs.setString('wishlist_items', encoded);
  }

  void toggleWishlist(Book book) {
    if (isInWishlist(book.id)) {
      _items.removeWhere((b) => b.id == book.id);
    } else {
      _items.add(book);
    }
    _saveWishlist();
    notifyListeners();
  }

  bool isInWishlist(String bookId) {
    return _items.any((b) => b.id == bookId);
  }
}
