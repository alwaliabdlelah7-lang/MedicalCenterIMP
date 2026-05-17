import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final DatabaseService _db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المواعيد')),
      body: Center(child: Text('قريباً: إدارة المواعيد مع التقويم')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('إضافة موعد قيد التطوير')));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
