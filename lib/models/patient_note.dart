class PatientNote {
  final String id;
  final String patientId;

  final String nurseName;
  final String title;
  final String body;

  /// if true -> patient can see it
  final bool visibleToPatient;

  final DateTime createdAt;

  const PatientNote({
    required this.id,
    required this.patientId,
    required this.nurseName,
    required this.title,
    required this.body,
    required this.visibleToPatient,
    required this.createdAt,
  });
}
