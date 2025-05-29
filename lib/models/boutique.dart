import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Boutique {
  final String name;
  final String photo;
  final String description;
  final String phone;
  final String status;
  final Map<String, dynamic> address;
  final String id;
  final List<Map<String, dynamic>> catalogues;

  Boutique({
    required this.name,
    required this.photo,
    required this.description,
    required this.phone,
    required this.status,
    required this.address,
    required this.id,
    required this.catalogues,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    final address = Map<String, dynamic>.from(json['address'] ?? {});

    // Convert coordinates to double
    if (address['latitude'] != null) {
      address['latitude'] =
          (address['latitude'] is num)
              ? (address['latitude'] as num).toDouble()
              : 0.0;
    }
    if (address['longitude'] != null) {
      address['longitude'] =
          (address['longitude'] is num)
              ? (address['longitude'] as num).toDouble()
              : 0.0;
    }

    return Boutique(
      id: json['_id'] ?? '',
      name: json['nomBoutique']?.replaceAll('"', '') ?? '',
      photo: json['photo'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      address: address,
      catalogues: List<Map<String, dynamic>>.from(json['catalogues'] ?? []),
    );
  }

  static Future<List<Boutique>> fetchBoutiques() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception("No token found");

      final url = Uri.parse(
        "http://192.168.154.195:7777/service-commande/boutiques?status=accepte",
      );
      final response = await http
          .get(url, headers: {"Authorization": "Bearer $token"})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Boutique.fromJson(item)).toList();
      } else {
        print('Failed to fetch boutiques: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching boutiques: $e');
      return [];
    }
  }

  static Future<Boutique?> fetchBoutiquesById(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("No token found");

      // Get user role from SharedPreferences
      final userRole = prefs.getString('user_role') ?? '';
      print('User Role: $userRole'); // Debug log
      print('Token: $token'); // Debug log

      final url = Uri.parse(
        "http://192.168.154.195:7777/service-commande/boutiques/$id?token=$token",
      );
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "X-User-Role": userRole, // Add user role in header
            },
          )
          .timeout(const Duration(seconds: 30));
      print('Fetching boutique with id: $id');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Request URL: ${url.toString()}');
      print('Request headers: ${response.request?.headers}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Boutique.fromJson(data);
      } else if (response.statusCode == 500) {
        print(
          'Server error while fetching boutique. Please check server logs.',
        );
        throw Exception('Server error: ${response.body}');
      } else {
        print('Failed to fetch boutique: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching boutique: $e');
      return null;
    }
  }
}
