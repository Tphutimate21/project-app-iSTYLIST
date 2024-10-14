import 'package:flutter/material.dart';
import 'checkout_order_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String userId; // Pass userId from the parent or login page

  CartPage({required this.cartItems, required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Removing item from cart
  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  // Increasing item quantity
  void _increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity']++;
    });
  }

  // Decreasing item quantity
  void _decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity']--;
      }
    });
  }

  // Navigating to the checkout order page
  void _placeOrder() {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No items in the cart to place an order.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to CheckoutOrderPage and pass the necessary data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutOrderPage(
          cartItems: List<Map<String, dynamic>>.from(widget.cartItems), // Clone the cartItems list
          totalPrice: _calculateTotalPrice(),
          userId: widget.userId, // Pass the userId here
        ),
      ),
    );
  }

  // Calculate the total price of items in the cart
  double _calculateTotalPrice() {
    return widget.cartItems.fold<double>(0.0, (sum, item) {
      double itemPrice = (item['price'] as double?) ?? 0.0;
      return sum + itemPrice * (item['quantity'] as int);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Count total number of items in the cart
    int totalItems = widget.cartItems.fold<int>(0, (sum, item) {
      return sum + (item['quantity'] as int);
    });

    // Calculate total price for display
    double totalPrice = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Cart",
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "$totalItems items",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: widget.cartItems.length,
          itemBuilder: (context, index) {
            final item = widget.cartItems[index];
            return Dismissible(
              key: Key(item['title']),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _removeItem(index); // Remove item on swipe
              },
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                  ],
                ),
              ),
              child: _buildCartItem(item, index),
            );
          },
        ),
      ),
      // Build the bottom checkout card
      bottomNavigationBar: _buildCheckoutCard(totalItems, totalPrice),
    );
  }

  // Display each item in the cart with options to increase/decrease quantity
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${item['price']} x${item['quantity']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () => _increaseQuantity(index),
                ),
                Text('${item['quantity']}'),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.black),
                  onPressed: () => _decreaseQuantity(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Checkout button to proceed to the checkout page
  Widget _buildCheckoutCard(int totalItems, double totalPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt, color: Colors.blue),
                ),
                const Spacer(),
                const Text("Add voucher code", style: TextStyle(color: Colors.black)),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "Total:\n",
                      children: [
                        TextSpan(
                          text: "\$${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _placeOrder, // Proceed to checkout
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    child: const Text("Check Out"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
