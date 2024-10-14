import 'package:flutter/material.dart';
import './page/login.dart';
import './page/register_page.dart';
import './page/order_history_page.dart';
import './page/home_page.dart'; // นำเข้าหน้า HomePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iSTYLIST',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/order_history': (context) => OrderHistoryPage(),
        '/home': (context) => HomePage(), 
      },
    );
  }
}
