import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/database_service.dart';
import '../models/appointment.dart';
import '../models/patient.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Appointment>> _events = {};
  List<Appointment> _selectedAppointments = [];
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allAppointments = await _db.getAllAppointments();
    final patients = await _db.getAllPatients();
    setState(() {
      _patients = patients;
      _events = {};
      for (var apt in allAppointments) {
        final date = DateTime(apt.startTime.year, apt.startTime.month, apt.startTime.day);
        if (!_events.containsKey(date)) _events[date] = [];
        _events[date]!.add(apt);
      }
      _selectedAppointments = _events[_selectedDay] ?? [];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedAppointments = _events[selectedDay] ?? [];
    });
  }

  Future<void> _addAppointment() async {
    // بسيط: نختار مريضاً من القائمة
    if (_patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الرجاء إضافة مريض أولاً')));
      return;
    }
    final selectedPatient = await showDialog<Patient>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('اختر المريض'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _patients.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(_patients[i].fullName),
              subtitle: Text(_patients[i].phone),
              onTap: () => Navigator.pop(context, _patients[i]),
            ),
          ),
        ),
      ),
    );
    if (selectedPatient == null) return;

    final doctorController = TextEditingController(text: 'د. أحمد');
    final serviceController = TextEditingController(text: 'استشارة');
    final costController = TextEditingController(text: '30');
    final paidController = TextEditingController(text: '30');
    final notesController = TextEditingController();
    final startTime = _selectedDay.add(Duration(hours: 10));
    final endTime = startTime.add(Duration(minutes: 30));

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('حجز موعد جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: doctorController, decoration: InputDecoration(labelText: 'اسم الطبيب')),
              TextField(controller: serviceController, decoration: InputDecoration(labelText: 'الخدمة')),
              TextField(controller: costController, decoration: InputDecoration(labelText: 'التكلفة'), keyboardType: TextInputType.number),
              TextField(controller: paidController, decoration: InputDecoration(labelText: 'المدفوع'), keyboardType: TextInputType.number),
              TextField(controller: notesController, decoration: InputDecoration(labelText: 'ملاحظات')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'doctorName': doctorController.text,
              'service': serviceController.text,
              'totalCost': double.parse(costController.text),
              'paid': double.parse(paidController.text),
              'notes': notesController.text,
            }),
            child: Text('حفظ'),
          ),
        ],
      ),
    );
    if (result == null) return;

    final newAppointment = Appointment(
      patientId: selectedPatient.id,
      patientName: selectedPatient.fullName,
      doctorName: result['doctorName'],
      service: result['service'],
      startTime: startTime,
      endTime: endTime,
      status: 'scheduled',
      totalCost: result['totalCost'],
      paid: result['paid'],
      notes: result['notes'],
    );
    await _db.insertAppointment(newAppointment);
    _loadData();
  }

  Future<void> _updateStatus(Appointment apt, String newStatus) async {
    final updated = Appointment(
      id: apt.id,
      patientId: apt.patientId,
      patientName: apt.patientName,
      doctorName: apt.doctorName,
      service: apt.service,
      startTime: apt.startTime,
      endTime: apt.endTime,
      status: newStatus,
      totalCost: apt.totalCost,
      paid: apt.paid,
      notes: apt.notes,
    );
    await _db.updateAppointment(updated);
    _loadData();
  }

  Future<void> _deleteAppointment(int id) async {
    await _db.deleteAppointment(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المواعيد')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            eventLoader: (day) => _events[day] ?? [],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedAppointments.length,
              itemBuilder: (_, i) {
                final apt = _selectedAppointments[i];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _updateStatus(apt, 'completed'),
                        backgroundColor: Colors.green,
                        icon: Icons.check,
                        label: 'مكتمل',
                      ),
                      SlidableAction(
                        onPressed: (_) => _updateStatus(apt, 'cancelled'),
                        backgroundColor: Colors.red,
                        icon: Icons.cancel,
                        label: 'ملغي',
                      ),
                      SlidableAction(
                        onPressed: (_) => _deleteAppointment(apt.id!),
                        backgroundColor: Colors.grey,
                        icon: Icons.delete,
                        label: 'حذف',
                      ),
                    ],
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text('${apt.patientName} - ${apt.doctorName}'),
                      subtitle: Text('${DateFormat('hh:mm a').format(apt.startTime)} - ${apt.service} - ${apt.status}'),
                      trailing: Text('${apt.totalCost} ريال'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        child: Icon(Icons.add),
        tooltip: 'حجز موعد',
      ),
    );
  }
}
