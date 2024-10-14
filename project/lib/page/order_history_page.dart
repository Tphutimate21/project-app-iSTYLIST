import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ดึง user_id จาก SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in.';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.9/get_order_history.php'),
        body: {'user_id': userId},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            _orderHistory = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else if (data is Map && data.containsKey("message")) {
          setState(() {
            _isLoading = false;
            _errorMessage = data["message"];
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No order history found.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load order history. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please check your internet connection and try again.';
      });
      print('Error: $e');
    }
  }

  Future<void> _deleteOrderById(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9/delete_order.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'order_id': orderId.toString()},
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success']) {
        setState(() {
          _orderHistory.removeWhere((order) => order['id'] == orderId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete order: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrderHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _orderHistory.isEmpty
                    ? const Center(child: Text('No order history found'))
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _orderHistory.length,
                        itemBuilder: (context, index) {
                          final order = _orderHistory[index];
                          final orderId = order['id'] as int;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: Image.network(
                                order['image_url'] ?? '',
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error, color: Colors.red);
                                },
                              ),
                              title: Text(
                                'Order Date: ${order['date']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Name: ${order['name']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total: \$${order['price']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteConfirmation(orderId);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  void _showDeleteConfirmation(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteOrderById(orderId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
