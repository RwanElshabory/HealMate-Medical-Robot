import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../models/patient_model.dart';

class DoctorApiService {
  Future<List<PatientModel>> getMyPatients() async {
    final response = await ApiClient.dio.get(Endpoints.doctorPatients);

    final List data = response.data;
    return data.map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    final response = await ApiClient.dio.get(
      Endpoints.doctorSearchPatients,
      queryParameters: {"q": query},
    );

    final List data = response.data;
    return data.map((e) => PatientModel.fromJson(e)).toList();
  }
}