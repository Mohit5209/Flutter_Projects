import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, Object>> cart = [];

  void addToCart(Map<String, Object> product) {
    cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Map<String, Object> product) {
    cart.remove(product);
    notifyListeners();
  }
}
