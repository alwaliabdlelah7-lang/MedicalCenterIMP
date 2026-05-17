class Appointment {
  final int id;
  final int patientId;
  final String doctorName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // scheduled, completed, cancelled
  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}
