import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/companies/domain/models/company_model.dart';
import 'api_service.dart';

/// Service for company/corporate challenge endpoints.
class CompanyService {
  final ApiService _api;

  const CompanyService(this._api);

  /// Joins the company identified by [inviteCode].
  ///
  /// Returns the resulting [CompanyMember] on success.
  /// Throws [ApiError] on failure.
  Future<CompanyMember> joinCompany(String inviteCode) async {
    assert(inviteCode.isNotEmpty, 'inviteCode must not be empty');
    try {
      final response =
          await _api.post('/companies/$inviteCode/join', data: {});
      return CompanyMember.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (e) {
      throw ApiError.from(e);
    }
  }

  /// Returns the current user's [CompanyMember] record, or `null` if the
  /// user is not a member of any company.
  Future<CompanyMember?> getMyCompany() async {
    try {
      final response = await _api.get('/companies/my-company/me');
      if (response.data == null || response.data == '') return null;
      return CompanyMember.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return null;
      throw ApiError.from(e);
    }
  }

  /// Returns the leaderboard for [companyId].
  ///
  /// Throws [ApiError] on failure.
  Future<List<CompanyMember>> getLeaderboard(String companyId) async {
    assert(companyId.isNotEmpty, 'companyId must not be empty');
    try {
      final response = await _api.get('/companies/$companyId/leaderboard');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              CompanyMember.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw ApiError.from(e);
    }
  }
}

/// Riverpod provider for [CompanyService].
final companyServiceProvider = Provider<CompanyService>((ref) {
  return CompanyService(ref.read(apiServiceProvider));
});
