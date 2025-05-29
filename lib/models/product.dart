import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int stock;
  final String status;
  final String catalogueId;
  final List<dynamic> infos;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.status,
    required this.catalogueId,
    required this.infos,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['nomProduit'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['photoProduit'] ?? '',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
      catalogueId: json['Catalogueid'] ?? '',
      infos: json['infos'] ?? [],
    );
  }

  static Future<List<Product>> fetchProductsByCatalogue(
    String boutiqueId,
    String catalogueId,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No auth token found');
      print(
        'Fetching products for boutique: $boutiqueId, catalogue: $catalogueId',
      );
      final url = Uri.parse(
        'http://192.168.154.195:7777/service-commande/boutiques/$boutiqueId/catalogues/$catalogueId/produits?token=$token',
      );
      print('Fetching products from URL: $url'); // Debug print
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 30));

      print('API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        print('API Response Body: $productsJson');
        final products = productsJson.map((p) => Product.fromJson(p)).toList();
        print('Parsed ${products.length} products');
        return products;
      } else {
        print('Failed to load products: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  static Future<List<Product>> fetchAllProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No auth token found');
      final url = Uri.parse(
        'http://192.168.154.195:7777/service-commande/products',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final products = productsJson.map((p) => Product.fromJson(p)).toList();
        return products;
      } else {
        print('Failed to load products: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
