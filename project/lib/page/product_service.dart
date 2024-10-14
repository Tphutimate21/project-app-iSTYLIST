import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String detail;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.detail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['product_name'] ?? 'No Name Available',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      imageUrl: json['profile_image'] ?? '',
      detail: json['detail'] ?? 'No Details Available',
    );
  }
}

class ProductService {
  static const String _baseUrl = 'http://192.168.1.9';

  // Fetch random products
  Future<List<Product>> fetchRandomProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_random_products.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Check if the data is a list and contains valid items
        if (data is List && data.isNotEmpty) {
          return data.map((item) => Product.fromJson(item)).toList();
        } else {
          throw Exception('Invalid data format received or empty data');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Fetch product by ID
  Future<Product?> fetchProductById(int productId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_product_by_id.php?id=$productId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        // Ensure the data is a valid map and not empty
        if (data.isNotEmpty && data is Map<String, dynamic>) {
          return Product.fromJson(data);
        } else {
          throw Exception('Invalid data format received or empty data');
        }
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
