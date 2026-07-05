import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class AiApiService {
  Future<Map<String, dynamic>> predictDisease({
    required int patientId,
    required int age,
    required String gender,
    required List<String> symptoms,
  }) async {
    final response = await ApiClient.dio.post(
      Endpoints.aiPredict,
      data: {
        "patientId": patientId,
        "age": age,
        "gender": gender,
        "symptoms": symptoms,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
}