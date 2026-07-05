class NursePatient {
  final String id;
  final String name;
  final int age;
  final String room;
  final String condition; // e.g. "Chickenpox"
  final String risk; // Low / Medium / High
  final double tempC; // latest temperature

  const NursePatient({
    required this.id,
    required this.name,
    required this.age,
    required this.room,
    required this.condition,
    required this.risk,
    required this.tempC,
  });
}
