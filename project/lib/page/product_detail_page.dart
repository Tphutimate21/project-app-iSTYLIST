import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_page.dart';
import 'home_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String title;
  final List<String> images;
  final double price;
  final String description;

  const ProductDetailPage({
    Key? key,
    required this.title,
    required this.images,
    required this.price,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor: Colors.blue,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ProductImages(images: images),
          TopRoundedContainer(
            color: Colors.white,
            child: Column(
              children: [
                ProductDescription(
                  title: title,
                  description: description,
                  price: price,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C0FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? userId = prefs.getString('user_id'); // ดึง user_id จาก SharedPreferences
                      
                      if (userId != null) {
                        globalCartItems.add({
                          'title': title,
                          'price': price,
                          'image': images[0],
                          'description': description,
                          'quantity': 1, // กำหนดค่า quantity เริ่มต้นเป็น 1
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartPage(
                              cartItems: globalCartItems,
                              userId: userId,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login to add items to your cart.')),
                        );
                      }
                    },
                    child: const Text("Add To Cart"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ส่วนของ TopRoundedContainer
class TopRoundedContainer extends StatelessWidget {
  const TopRoundedContainer({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}

// ส่วนของการแสดงภาพสินค้า
class ProductImages extends StatefulWidget {
  final List<String> images;

  const ProductImages({Key? key, required this.images}) : super(key: key);

  @override
  _ProductImagesState createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int selectedImage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              widget.images[selectedImage],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 40),
                );
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (index) => SmallProductImage(
              isSelected: index == selectedImage,
              press: () {
                setState(() {
                  selectedImage = index;
                });
              },
              image: widget.images[index],
            ),
          ),
        ),
      ],
    );
  }
}

// ส่วนของ SmallProductImage สำหรับแสดงภาพขนาดเล็ก
class SmallProductImage extends StatelessWidget {
  final bool isSelected;
  final VoidCallback press;
  final String image;

  const SmallProductImage({
    Key? key,
    required this.isSelected,
    required this.press,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(4),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF00C0FF).withOpacity(isSelected ? 1 : 0),
          ),
        ),
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ส่วนของคำอธิบายสินค้า
class ProductDescription extends StatelessWidget {
  final String title;
  final String description;
  final double price;

  const ProductDescription({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00C0FF), // ใช้สีฟ้าแสดงราคา
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: const [
                Text(
                  "See More Detail",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF00C0FF)),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF00C0FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
