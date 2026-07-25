import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class CartItem {
  final Book book;
  int quantity;
  String format;

  CartItem({required this.book, this.quantity = 1, this.format = 'Hardcover'});

  Map<String, dynamic> toJson() {
    return {
      'book': book.toJson(),
      'quantity': quantity,
      'format': format,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      book: Book.fromJson(json['book']),
      quantity: json['quantity'] ?? 1,
      format: json['format'] ?? 'Hardcover',
    );
  }
}

class CartService extends ChangeNotifier {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    _loadCart();
  }

  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + (item.book.price * item.quantity));

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decoded = jsonDecode(cartData);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items', encoded);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  void addItem(Book book, {int quantity = 1, String format = 'Hardcover'}) {
    final index = _items.indexWhere((item) => item.book.id == book.id && item.format == format);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(book: book, quantity: quantity, format: format));
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(Book book, String format, int newQuantity) {
    final index = _items.indexWhere((item) => item.book.id == book.id && item.format == format);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void removeItem(Book book, String format) {
    _items.removeWhere((item) => item.book.id == book.id && item.format == format);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}
