import 'package:flutter/material.dart';
import 'package:iSTYLIST/page/categories_page.dart';
import 'package:iSTYLIST/page/login.dart';
import 'package:iSTYLIST/page/order_history_page.dart';
import 'package:iSTYLIST/page/setting_page.dart';
import 'cart_page.dart';
import 'menu_page.dart';
import 'product_detail_page.dart';
import 'product_service.dart';
import 'product_page.dart';
// Global cart items list
List<Map<String, dynamic>> globalCartItems = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _randomProducts;

  @override
  void initState() {
    super.initState();
    _randomProducts = ProductService().fetchRandomProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'iSTYLIST',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(
        color: Colors.blue, 
      ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer เมื่ออยู่ในหน้า Home
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categories'),
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
              leading: Icon(Icons.history),
              title: Text('Order History'),
              onTap: () {
                // Navigate to Order History Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () {
                // Navigate to Log Out Page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingPage(),
                  ),
                  (route) => false, // ล้าง stack หน้าเก่าทั้งหมด
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                // Navigate to Log Out Page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (route) => false, // ล้าง stack หน้าเก่าทั้งหมด
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HomeHeader(),
              DiscountBanner(),
              Categories(),
              FutureBuilder<List<Product>>(
                future: _randomProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products available'));
                  } else {
                    final products = snapshot.data!;
                    return PopularProducts(products: products);
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// ส่วน Header ของหน้า Home
class HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SearchField(),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartItems: globalCartItems,
                    userId: 'yourUserIdHere', // Pass the actual user ID
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ส่วน SearchField
class SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search product',
        prefixIcon: Icon(Icons.search, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ส่วน Discount Banner
class DiscountBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(text: "A Summer Surprise\n"),
            TextSpan(
              text: "Cashback 20%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ส่วน Categories
class Categories extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {"icon": "https://img5.pic.in.th/file/secure-sv1/flash-sale197220841a76ffb2.png", "text": "Flash Deal"},
    {"icon": "https://img2.pic.in.th/pic/billf9cdf9b398edd94c.png", "text": "Bill"},
    {"icon": "https://img2.pic.in.th/pic/gift930a2cae9d9f8a8c.png", "text": "Daily Gift"},
    {"icon": "https://img2.pic.in.th/pic/application.png", "text": "More"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          categories.length,
          (index) => CategoryCard(
            imageUrl: categories[index]["icon"]!,
            text: categories[index]["text"]!,
            press: () {
              if (categories[index]["text"] == "More") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriesPage(),
                  ),
                );
              } else {
                // Handle other category taps if needed
                print('${categories[index]["text"]} tapped');
              }
            },
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imageUrl, text;
  final VoidCallback press;

  CategoryCard({required this.imageUrl, required this.text, required this.press});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.error, color: Colors.red, size: 40),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}


// ส่วน Popular Products (แสดงสินค้าแบบสุ่ม)
class PopularProducts extends StatelessWidget {
  final List<Product> products;

  PopularProducts({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(
          title: "Popular Products",
          press: () {
            print("See more tapped");
          },
        ),
        GridView.builder(
          padding: const EdgeInsets.all(10.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              imageUrl: product.imageUrl,
              title: product.name,
              price: product.price,
              description: product.detail,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      title: product.name,
                      images: [product.imageUrl],
                      price: product.price,
                      description: product.detail,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final String description;
  final VoidCallback onTap;

  ProductCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "\$${price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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

// ส่วนหัวข้อสำหรับแต่ละ Section
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback press;

  SectionTitle({required this.title, required this.press});

  @override
 Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            // ใช้ Navigator เพื่อเปลี่ยนไปหน้า CategoriesPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductsPage()),
            );
          },
          child: Text("See more", style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}

}
