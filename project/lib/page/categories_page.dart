import 'package:flutter/material.dart';
import 'package:iSTYLIST/page/home_page.dart';
import 'package:iSTYLIST/page/menu_page.dart';

class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        backgroundColor: Colors.black87, // ใช้สีที่สดใสและดึงดูด
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Explore Fashion Categories',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Discover the latest fashion trends and styles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildCategoryCard(
                    context,
                    'Fashion for Women',
                    'https://i.pinimg.com/736x/60/07/c0/6007c009a2106eb74f49f7b341993e50.jpg',
                    'Explore the latest trends in women\'s fashion',
                  ),
                  _buildCategoryCard(
                    context,
                    'Fashion for Men',
                    'https://i.pinimg.com/474x/e0/55/3f/e0553f404f46058563426dd3149174e6.jpg',
                    'Find the best styles and tips for men\'s fashion',
                  ),
                  _buildCategoryCard(
                    context,
                    'Accessories',
                    'https://bobbysfashions.com/wp-content/uploads/2018/05/Style-Accessories-for-Men.jpg',
                    'Perfect accessories to complete your look',
                  ),
                  _buildCategoryCard(
                    context,
                    'Beauty & Makeup',
                    'https://img.freepik.com/premium-photo/makeup-products-isolated-black-background_962635-588.jpg',
                    'Top beauty tips and products for every occasion',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String categoryName, String imageUrl, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: $categoryName'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
