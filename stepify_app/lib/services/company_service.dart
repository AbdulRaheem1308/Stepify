import 'package:dio/dio.dart';
import '../features/companies/domain/models/company_model.dart';
import 'api_service.dart';

class CompanyService {
  final ApiService _api;

  CompanyService(this._api);

  Future<CompanyMember> joinCompany(String inviteCode) async {
    // In a real app, getUser ID from auth provider, but API usually infers from token
    // We'll assume the backend extracts user from token
    final response = await _api.post('/companies/$inviteCode/join', data: {});
    return CompanyMember.fromJson(response.data);
  }

  Future<CompanyMember?> getMyCompany() async {
    try {
      // Mocking user ID retrieval or using 'me' endpoint
      final response = await _api.get('/companies/my-company/me');
      if (response.data == null) return null;
      return CompanyMember.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<CompanyMember>> getLeaderboard(String companyId) async {
    final response = await _api.get('/companies/$companyId/leaderboard');
    final List data = response.data;
    return data.map((json) => CompanyMember.fromJson(json)).toList();
  }
}
