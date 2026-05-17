import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/patient.dart';

class QuickSearchScreen extends StatefulWidget {
  @override
  _QuickSearchScreenState createState() => _QuickSearchScreenState();
}

class _QuickSearchScreenState extends State<QuickSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Patient> _results = [];
  final DatabaseService _db = DatabaseService.instance;

  void _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }
    final patients = await _db.searchPatients(query);
    setState(() => _results = patients);
  }

  void _addPatient() async {
    // نموذج بسيط لإضافة مريض
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إضافة مريض جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'الاسم الكامل')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'رقم الجوال')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newPatient = Patient(id: 0, fullName: nameController.text, phone: phoneController.text, fileNumber: DateTime.now().millisecondsSinceEpoch.toString());
              await _db.insertPatient(newPatient);
              Navigator.pop(context);
              _onSearchChanged(_controller.text);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بحث سريع')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'اسم أو جوال أو رقم ملف',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty ? null : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onSearchChanged('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(_results[i].fullName),
                subtitle: Text(_results[i].phone),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    // الانتقال إلى شاشة حجز موعد مع patientId
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('سيتم حجز موعد قريباً')));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPatient,
        child: Icon(Icons.person_add),
        tooltip: 'إضافة مريض',
      ),
    );
  }
}
