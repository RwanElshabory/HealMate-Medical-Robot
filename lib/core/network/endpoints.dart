class Endpoints {
  /// Auth
  static const login = "/api/auth/login";
  static const register = "/api/auth/register";
  static const me = "/api/auth/me";

  /// Chat
  static const chatHistory = "/api/chat/history";
  static const chatSend = "/api/chat/send";
  static const chatMarkAsRead = "/api/chat/mark-as-read";
  /// Doctor
  static const doctorPatients = "/api/doctor/patients";
  static const doctorReports = "/api/doctor/reports";
  static const doctorSearchPatients = "/api/doctor/patients/search";

  /// AI
  static const aiPredict = "/api/doctor/ai/predict";

  /// Nurse
  static const nurseBase = "/api/nurse";
  static const nurseMedicine = "/api/nurse/medicine";

  /// Patient
  static const patientReports = "/api/patient/reports";
  static const patientMedicine = "/api/patient/medicine";
  static const patientChat = "/api/patient/chat";

  /// Robot
  static const robotCommand = "/api/doctor/robot/command";
  static const robotLogs = "/api/doctor/robot/logs";
  static const robotStatus = "/api/doctor/robot/status";
}