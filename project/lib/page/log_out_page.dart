import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iSTYLIST/page/login.dart';

class LogOutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true, // ปิดการทำงานของปุ่มย้อนกลับ
      child: Scaffold(
        appBar: AppBar(
          title: Text('Log Out'),
          automaticallyImplyLeading: true, // เอาปุ่มย้อนกลับออกจาก AppBar
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Confirm Log Out'),
            onPressed: () {
              // คุณอาจต้องลบข้อมูลของผู้ใช้หรือสถานะการล็อกอินที่จัดเก็บไว้ก่อน
              // (เช่น ลบข้อมูลจาก SharedPreferences หรือสถานะอื่น ๆ)

              // หลังจากที่คุณจัดการกับการล็อกเอาต์แล้ว
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // เปลี่ยนไปยังหน้า LoginPage
              );

              // แสดง Toast เพื่อแจ้งให้ผู้ใช้ทราบว่าการล็อกเอาต์สำเร็จ
              Fluttertoast.showToast(
                msg: 'You have been logged out.',
                backgroundColor: Colors.green,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
        ),
      ),
    );
  }
}