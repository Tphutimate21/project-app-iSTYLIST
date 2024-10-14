import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'setting_page.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile data from the server
  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id'); // Get user ID from SharedPreferences

    if (userId != null) {
      final response = await http.get(Uri.parse('http://192.168.1.9/get_user_profile.php?user_id=$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            nameController.text = data['username'] ?? '';
            emailController.text = data['email'] ?? '';
          });
        }
      }
    }
  }

  // Update user profile data
  Future<void> _updateUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');  // Retrieve user ID

    if (userId == null) return;

    // Prepare the request body with data fields to update
    Map<String, String> body = {
      'user_id': userId,
    };

    if (nameController.text.isNotEmpty) {
      body['new_username'] = nameController.text;
    }

    if (emailController.text.isNotEmpty) {
      body['email'] = emailController.text;
    }

    if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
      body['current_password'] = oldPasswordController.text;
      body['new_password'] = newPasswordController.text;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9/update_profile.php'),
        body: body,
      );

      if (response.statusCode == 200) {
        // Navigate to SettingsPage after successful update
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingPage()),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  UserInfoEditField(
                    text: "Name",
                    child: TextFormField(
                      controller: nameController,
                      decoration: _buildInputDecoration(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  UserInfoEditField(
                    text: "Email",
                    child: TextFormField(
                      controller: emailController,
                      decoration: _buildInputDecoration(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  UserInfoEditField(
                    text: "Old Password",
                    child: TextFormField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: _buildPasswordDecoration(),
                    ),
                  ),
                  UserInfoEditField(
                    text: "New Password",
                    child: TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: _buildPasswordDecoration(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16.0),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C0FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Save Update"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF00C0FF).withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }

  InputDecoration _buildPasswordDecoration() {
    return InputDecoration(
      suffixIcon: const Icon(
        Icons.visibility_off,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFF00BF6D).withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }
}

// User Information Editable Fields Widget
class UserInfoEditField extends StatelessWidget {
  final String text;
  final Widget child;

  const UserInfoEditField({
    Key? key,
    required this.text,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: child,
          ),
        ],
      ),
    );
  }
}
