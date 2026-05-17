import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/quick_search_screen.dart';
import 'screens/appointments_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Center',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.cairo().fontFamily,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    QuickSearchScreen(),
    AppointmentsScreen(),
    Center(child: Text('لوحة القيادة - سيتم إضافتها لاحقاً')),
    Center(child: Text('الإعدادات - سيتم إضافتها لاحقاً')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'مواعيد'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'رئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'إعدادات'),
        ],
      ),
    );
  }
}
