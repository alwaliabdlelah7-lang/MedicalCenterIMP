class Appointment {
  final int? id;
  final int patientId;
  final String patientName;
  final String doctorName;
  final String service;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // scheduled, completed, cancelled
  final double totalCost;
  final double paid;
  final String notes;

  Appointment({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.service,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalCost,
    required this.paid,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'service': service,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'totalCost': totalCost,
      'paid': paid,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      patientName: map['patientName'],
      doctorName: map['doctorName'],
      service: map['service'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      status: map['status'],
      totalCost: map['totalCost'],
      paid: map['paid'],
      notes: map['notes'] ?? '',
    );
  }
}
