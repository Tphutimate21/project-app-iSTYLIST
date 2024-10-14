import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectAddressPage extends StatefulWidget {
  @override
  _SelectAddressPageState createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  String? _selectedAddress;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://192.168.1.9/get_addresses.php?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _addresses = List<Map<String, dynamic>>.from(data['addresses']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load addresses: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading addresses.')),
      );
    }
  }

  Future<void> _addNewAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final postalCode = _postalCodeController.text.trim();
    final country = _countryController.text.trim();

    if (address.isEmpty || city.isEmpty || state.isEmpty || postalCode.isEmpty || country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.9/add_address.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'address': address,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _addresses.add({
              'address': address,
              'city': city,
              'state': state,
              'postal_code': postalCode,
              'country': country,
            });
            _addressController.clear();
            _cityController.clear();
            _stateController.clear();
            _postalCodeController.clear();
            _countryController.clear();
          });
          await _loadAddresses(); // โหลดที่อยู่ใหม่หลังจากเพิ่มสำเร็จ
          Navigator.pop(context); // ปิด modal หลังเพิ่มที่อยู่ใหม่
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add address. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
  }

  void _showAddAddressModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _stateController,
                decoration: InputDecoration(
                  hintText: 'State',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  hintText: 'Postal Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(
                  hintText: 'Country',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _addNewAddress();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add Address',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: _addresses.isNotEmpty
                        ? ListView.builder(
                            itemCount: _addresses.length,
                            itemBuilder: (context, index) {
                              final item = _addresses[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    "${item['address']}, ${item['city']}, ${item['state']}, ${item['postal_code']}, ${item['country']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedAddress == item['address']
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  trailing: _selectedAddress == item['address']
                                      ? Icon(Icons.check, color: Colors.blue)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedAddress = item['address'];
                                    });
                                  },
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No address found. Please add one.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAddress != null) {
                        Navigator.pop(context, _selectedAddress);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select or add an address.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    ),
                    child: Text(
                      'Confirm Address',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressModal,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
