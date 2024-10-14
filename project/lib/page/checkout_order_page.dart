import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'address_page.dart';
import 'payment_page.dart';

class CheckoutOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final String userId;  // Add the userId parameter

  CheckoutOrderPage({required this.cartItems, required this.totalPrice, required this.userId});  // Add userId to constructor

  @override
  _CheckoutOrderPageState createState() => _CheckoutOrderPageState();
}

class _CheckoutOrderPageState extends State<CheckoutOrderPage> {
  String? selectedAddress;
  String? selectedPaymentMethod;

  // Function to select an address
  void _selectAddress() async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectAddressPage()),
    );

    if (address != null) {
      setState(() {
        selectedAddress = address;
      });
    }
  }

  // Function to select payment method
  void _selectPaymentMethod() async {
    final paymentMethod = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectPaymentPage()),
    );

    if (paymentMethod != null) {
      setState(() {
        selectedPaymentMethod = paymentMethod;
      });
    }
  }

  // Function to place the order
  Future<void> _placeOrder() async {
    if (selectedAddress == null || selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an address and payment method.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Use userId from the widget
    String userId = widget.userId;

    // Preparing data to be sent to the server
    List<Map<String, dynamic>> items = widget.cartItems.map((item) {
      return {
        'product_id': item['product_id'],
        'product_name': item['title'], // Mapping title as product_name
        'quantity': item['quantity'],
        'price': item['price'],
      };
    }).toList();

    final orderData = {
      'user_id': userId, // Now using the correct userId from the constructor
      'address': selectedAddress,
      'payment_method': selectedPaymentMethod,
      'items': items,
      'total_price': widget.totalPrice,
    };

    final url = Uri.parse('http://192.168.1.9/place_order.php'); // Update URL as needed

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'}, // Sending JSON data
            body: jsonEncode(orderData),
          )
          .timeout(const Duration(seconds: 10)); // Set a timeout of 10 seconds

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
          Navigator.pop(context); // Navigate back after successful order
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error occurred: $e"); // Log the error to the console
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          item['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Price: \$${item['price']} x${item['quantity']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text('Selected Address'),
                subtitle: Text(
                  selectedAddress ?? 'No address selected',
                  style: TextStyle(
                    color: selectedAddress == null ? Colors.red : Colors.black,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onPressed: _selectAddress,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text('Payment Method'),
                subtitle: Text(
                  selectedPaymentMethod ?? 'No payment method selected',
                  style: TextStyle(
                    color: selectedPaymentMethod == null
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onPressed: _selectPaymentMethod,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Price: \$${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
