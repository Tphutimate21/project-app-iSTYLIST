import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String _apiUrl = 'http://192.168.1.7'; // URL ของ Backend

  Future<List<Map<String, dynamic>>> loadCart() async {
    try {
      // ดึงข้อมูลจาก SharedPreferences ก่อน (ในกรณีที่ไม่มีการเชื่อมต่อกับ Backend)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cartData = prefs.getString('cartItems');
      if (cartData != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(cartData));
      }
      
      // ดึงข้อมูล Cart จาก Backend
      var response = await http.get(Uri.parse('$_apiUrl/load_cart.php'));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        return cartItems;
      } else {
        throw Exception('Failed to load cart from server');
      }
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    try {
      // บันทึกข้อมูลลง SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cartData = jsonEncode(cartItems);
      await prefs.setString('cartItems', cartData);

      // บันทึกข้อมูล Cart ไปยัง Backend
      var response = await http.post(
        Uri.parse('$_apiUrl/save_cart.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cartItems': cartItems}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save cart to server');
      }
    } catch (e) {
      print('Error saving cart: $e');
    }
  }
}
