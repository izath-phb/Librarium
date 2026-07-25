import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_service.dart';

class SaveForLaterService extends ChangeNotifier {
  static final SaveForLaterService _instance = SaveForLaterService._internal();
  factory SaveForLaterService() => _instance;
  
  SaveForLaterService._internal() {
    _loadSavedItems();
  }

  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  Future<void> _loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('saved_for_later_items');
    if (itemsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(itemsJson);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print("Error loading saved items: $e");
      }
    }
  }

  Future<void> _persistSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_items.map((i) => i.toJson()).toList());
    await prefs.setString('saved_for_later_items', encoded);
  }

  void saveForLater(CartItem item) {
    // Check if it already exists
    final existingIndex = _items.indexWhere((i) => i.book.id == item.book.id && i.format == item.format);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    _persistSavedItems();
    notifyListeners();
  }

  void moveToCart(CartItem item) {
    _items.remove(item);
    _persistSavedItems();
    notifyListeners();
    CartService().addItem(item.book, format: item.format, quantity: item.quantity);
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    _persistSavedItems();
    notifyListeners();
  }
}
