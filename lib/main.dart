import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Center',
      home: Scaffold(body: Center(child: Text('تم بناء التطبيق بنجاح'))),
    );
  }
}
