import 'package:flutter/material.dart';
import 'package:damping/features/home/views/home/component/map.dart';

class CartItem {
  final dynamic product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  Merchant? _currentMerchant;
  List<CartItem> _items = [];

  Merchant? get currentMerchant => _currentMerchant;
  List<CartItem> get items => _items;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (double.tryParse(item.product['price'].toString()) ?? 0.0) * item.quantity);
  }

  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addToCart(Merchant merchant, dynamic product) {
    if (_currentMerchant != null && _currentMerchant!.id != merchant.id) {
      // Clear cart if adding from a different merchant
      _items.clear();
      _currentMerchant = merchant;
    } else if (_currentMerchant == null) {
      _currentMerchant = merchant;
    }

    final existingIndex = _items.indexWhere((item) => item.product['id'] == product['id']);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(dynamic product) {
    final existingIndex = _items.indexWhere((item) => item.product['id'] == product['id']);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity -= 1;
      } else {
        _items.removeAt(existingIndex);
      }
      
      if (_items.isEmpty) {
        _currentMerchant = null;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentMerchant = null;
    notifyListeners();
  }
}
