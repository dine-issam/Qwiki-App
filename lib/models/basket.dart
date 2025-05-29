import 'package:delivery_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/models/commande.dart';
import 'dart:convert';

class BasketItem {
  final Product product;
  int quantity;
  final String size;

  BasketItem({required this.product, this.quantity = 1, required this.size});

  Map<String, dynamic> toJson() => {
    'product': {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'image': product.image,
      'stock': product.stock,
      'status': product.status,
      'catalogueId': product.catalogueId,
    },
    'quantity': quantity,
    'size': size,
  };

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      product: Product(
        id: json['product']['id'],
        name: json['product']['name'],
        description: json['product']['description'],
        price: json['product']['price'].toDouble(),
        image: json['product']['image'],
        stock: json['product']['stock'],
        status: json['product']['status'],
        catalogueId: json['product']['catalogueId'],
        infos: [],
      ),
      quantity: json['quantity'],
      size: json['size'],
    );
  }
}

class BasketModel extends ChangeNotifier {
  List<BasketItem> _items = [];
  int? _userId;
  static const String _storageKeyPrefix = 'basket_items_user_';

  BasketModel() {
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != _userId) {
      _userId = userId;
      await loadFromStorage();
    }
  }

  String get _storageKey => '$_storageKeyPrefix${_userId ?? "guest"}';

  List<BasketItem> get items => List.unmodifiable(_items);

  double get totalPrice {
    return _items.fold(
      0.0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }

  double get deliveryFee {
    // Free delivery over $50, otherwise $5 delivery fee
    return totalPrice >= 50 ? 0 : 5.0;
  }

  double get grandTotal => totalPrice + deliveryFee;

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  int getItemQuantity(Product product) {
    final item = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => BasketItem(product: product, quantity: 0, size: ''),
    );
    return item.quantity;
  }

  Future<void> addItem(BasketItem newItem) async {
    if (_userId == null) {
      await _initializeUserId();
    }

    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == newItem.product.id && item.size == newItem.size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> removeItem(String productId, String size) async {
    _items.removeWhere(
      (item) => item.product.id == productId && item.size == size,
    );
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateQuantity(
    String productId,
    String size,
    int quantity,
  ) async {
    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.size == size,
    );

    if (index >= 0) {
      if (quantity <= 0) {
        await removeItem(productId, size);
      } else {
        _items[index].quantity = quantity;
        await _saveToStorage();
        notifyListeners();
      }
    }
  }

  Future<void> clearBasket() async {
    _items.clear();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _items = jsonList.map((json) => BasketItem.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    if (_userId != null) {
      // Only save if we have a userId
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(
        _items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    }
  }

  // Call this when user logs out
  Future<void> clearOnLogout() async {
    _items.clear();
    _userId = null;
    notifyListeners();

    // Clear the storage for the previous user
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<bool> confirmOrder({
    required Address pickUpAddress,
    required Address dropOffAddress,
    required String idBoutique,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id')?.toString() ?? '';

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Convert basket items to CommandeItems
      final commandeItems =
          _items
              .map(
                (item) => CommandeItem(
                  produit: item.product.id,
                  quantity: item.quantity,
                  infos: item.product.name,
                ),
              )
              .toList();
      final commande = Commande(
        idBoutique: idBoutique,
        pickUpAddress: pickUpAddress,
        dropOffAddress: dropOffAddress,
        idClient: userId,
        produits: commandeItems,
        livraisontype: 'Express',
      );

      final requestBody = jsonEncode(commande.toJson());
      print('Sending order to server: $requestBody');

      final response = await http.post(
        Uri.parse(
          'http://192.168.154.195:7777/service-commande/commandes',
        ), // API endpoint for orders
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(commande.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Clear the basket after successful order
        await clearBasket();
        return true;
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error confirming order: $e');
      return false;
    }
  }
}
