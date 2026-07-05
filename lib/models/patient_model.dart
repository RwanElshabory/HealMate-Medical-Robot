class PatientModel {
  final int patientId;
  final String fullName;
  final int? age;
  final String? gender;
  final String? medicalHistory;
  final String? roomNumber;

  PatientModel({
    required this.patientId,
    required this.fullName,
    this.age,
    this.gender,
    this.medicalHistory,
    this.roomNumber,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      patientId: json["patientId"],
      fullName: json["fullName"] ?? "",
      age: json["age"],
      gender: json["gender"],
      medicalHistory: json["medicalHistory"],
      roomNumber: json["roomNumber"],
    );
  }
}