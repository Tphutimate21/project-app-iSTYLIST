import 'package:flutter/material.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'cart_page.dart';
import 'setting_page.dart';
import 'order_history_page.dart';
import 'log_out_page.dart';

class MenuPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  MenuPage({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.category,
            title: 'Categories',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.shopping_cart,
            title: 'Cart',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: cartItems, userId: 'userIdPlaceholder'),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Order History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogOutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
