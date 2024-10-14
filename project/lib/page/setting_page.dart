import 'package:flutter/material.dart';
import 'home_page.dart';
import './menu_page.dart';
import 'profile_edit_page.dart';
import 'categories_page.dart';
import 'login.dart';
import 'order_history_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String profileImage = 'https://www.pngall.com/wp-content/uploads/15/User-PNG-Images-HD.png'; // Placeholder image
  String username = 'Loading...';
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      
      if (userId == null) {
        _showError('User not logged in');
        return;
      }

      // ส่ง user_id เป็น query parameter ไปยัง API
      final response = await http.get(Uri.parse('http://192.168.1.9/get_user_profile.php?user_id=$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('username')) {
          setState(() {
            username = data['username'] ?? 'User';
            email = data['email'] ?? '';
            profileImage = data['profile_image_url'] ?? profileImage; // ดึง URL รูปโปรไฟล์จากฐานข้อมูล
          });
        } else {
          _showError(data['error'] ?? 'Error fetching user data');
        }
      } else {
        _showError('Failed to load profile');
      }
    } catch (e) {
      _showError('An error occurred while fetching the profile');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildMenuSection(
              context,
              title: "Profile",
              items: [
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  text: "Edit Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildMenuSection(
              context,
              title: "Notifications",
              items: [
                _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  text: "Enable Notifications",
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  text: "Notification Options",
                  onTap: () {},
                ),
              ],
            ),
            _buildMenuSection(
              context,
              title: "Addresses",
              items: [
                _buildMenuItem(
                  context,
                  icon: Icons.location_on,
                  text: "Addresses",
                  onTap: () {},
                ),
              ],
            ),
            _buildMenuSection(
              context,
              title: "Support",
              items: [
                _buildMenuItem(
                  context,
                  icon: Icons.chat,
                  text: "Help & Chat",
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.question_answer,
                  text: "Preferences",
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profileImage), // แสดงรูปโปรไฟล์จากฐานข้อมูล
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context,
      {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black87,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderHistoryPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Setting'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
