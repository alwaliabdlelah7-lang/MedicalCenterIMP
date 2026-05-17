class Patient {
  final int id;
  final String fullName;
  final String phone;
  final String fileNumber;
  final String? address;
  final DateTime? birthDate;
  Patient({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.fileNumber,
    this.address,
    this.birthDate,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'fileNumber': fileNumber,
    'address': address,
    'birthDate': birthDate?.toIso8601String(),
  };
}
