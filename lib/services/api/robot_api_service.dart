import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class RobotApiService {
  Future<Map<String, dynamic>> sendCommand({
    required int doctorId,
    int? patientId,
    required String command,
    String? parameters,
  }) async {
    final response = await ApiClient.dio.post(
      Endpoints.robotCommand,
      data: {
        "doctorId": doctorId,
        "patientId": patientId,
        "command": command,
        "parameters": parameters,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
}