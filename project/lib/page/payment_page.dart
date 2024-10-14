import 'package:flutter/material.dart';

class SelectPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Payment Method',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue),
              title: Text('Credit Card'),
              onTap: () {
                Navigator.pop(context, 'Credit Card');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: Text('PayPal'),
              onTap: () {
                Navigator.pop(context, 'PayPal');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.money, color: Colors.blue),
              title: Text('Cash on Delivery'),
              onTap: () {
                Navigator.pop(context, 'Cash on Delivery');
              },
            ),
          ],
        ),
      ),
    );
  }
}
