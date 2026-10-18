import 'package:dio/dio.dart';
import 'package:fingenie/core/extensions/currency.dart';
import 'package:fingenie/data/auth/auth_repository.dart';
import 'package:fingenie/domain/models/group_model.dart';
import 'package:fingenie/utils/app_logger.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroupRepository {
  final Dio _dio;
  final String apiUrl;

  GroupRepository({
    required Dio dio,
    required this.apiUrl,
  }) : _dio = dio;

  Future<List<GroupModel>> fetchUserGroups() async {
    try {
      final response = await _dio.get('$apiUrl/groups');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['groups'];
        return data.map((json) => GroupModel.fromJson(json)).toList();
      }

      throw Exception('Failed to fetch groups');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> addGroupMembers({
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      final token = await AuthRepository().getStoredToken();
      if (token == null) throw Exception('Authentication token not found');

      AppLogger.debug('Adding members to group: $groupId');
      AppLogger.debug('Member IDs: $memberIds');

      // Make individual requests for each member
      for (final userId in memberIds) {
        try {
          final response = await _dio.post(
            '$apiUrl/api/v1/groups/$groupId/members',
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
            data: {
              "userId": userId,
              "role": "member",
              "sharePercent": 0.0, // Default share percent
            },
          );

          if (response.statusCode != 200 && response.statusCode != 201) {
            AppLogger.error(
                'Failed to add member $userId: ${response.statusCode}');
            continue; // Continue with next member if one fails
          }

          AppLogger.success('Member $userId added successfully');
        } catch (e) {
          AppLogger.error('Failed to add member $userId: $e');
          // Continue with next member if one fails
        }
      }

      AppLogger.success('Finished adding members');
    } on DioException catch (e) {
      AppLogger.error('Failed to add members: ${e.message}');
      AppLogger.error('Response: ${e.response?.data}');
      throw Exception('Failed to add members: ${e.message}');
    }
  }

  Future<String> findUserByPhone(String phoneNumber) async {
    try {
      AppLogger.debug('Fetching user details for phone: $phoneNumber');
      final token = await AuthRepository().getStoredToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await _dio.get(
        '$apiUrl/api/v1/profile/user/$phoneNumber',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      AppLogger.debug('User search response: ${response.data}');

      if (response.data == null || response.data['data'] == null) {
        throw Exception('No user data found');
      }

      final userId = response.data['data'][0]['id'] as String;
      AppLogger.debug('Found user ID: $userId');
      return userId;
    } on DioException catch (e) {
      AppLogger.error('Failed to find user: ${e.message}');
      AppLogger.error('Response: ${e.response?.data}');
      throw Exception('Failed to find user: ${e.message}');
    }
  }

  // In group_repository.dart
  Future<GroupModel> createGroup({
    required String name,
    required String tag,
    required bool securityDepositRequired,
    required double? securityDeposit,
    required bool autoSettlement,
    required List<String> initialMembers,
  }) async {
    try {
      AppLogger.info('createGroup: creating group with tag: $tag');
      final token = await AuthRepository().getStoredToken();
      AppLogger.debug('Token loaded: $token');
      if (token == null) throw Exception('Authentication token not found');
      final authRepository = AuthRepository();
      final currentUser = authRepository.getCurrentUser();
      final defaultCurrency =
          currentUser?.currency ?? 'INR'; // Fallback to INR if no user currency

      final data = {
        'name': name,
        'description': _getDescriptionForTag(tag),
        'defaultCurrency': defaultCurrency.toCurrencyCode().toString(),
        'groupType': tag,
        'isRecurring': true,
        'securityDepositRequired': securityDepositRequired
            ? securityDeposit
            : 0, // Number instead of boolean        'securityDeposit': securityDepositRequired ? securityDeposit : 0,
        'requiresAdminApproval': false,
        'budgetStrategy': 'equal',
        'billingCycleStart': DateTime.now().toUtc().toIso8601String(),
        'splitStrategy': 'percentage',
        'autoSettlement': autoSettlement
      };

      AppLogger.debug('Request data: $data');

      final response = await _dio.post(
        '$apiUrl/api/v1/groups/',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      AppLogger.debug('Response: ${response.data}');
      AppLogger.success('New group created: ${response.data['data']['id']}');

      if (response.data == null) {
        throw Exception('Server returned null response');
      }

      final groupData = response.data['data'];
      if (groupData == null) {
        throw Exception('No group data in response');
      }
      return GroupModel(
        id: groupData['id'],
        name: groupData['name'],
        description: groupData['description'],
        defaultCurrency: groupData['defaultCurrency'] ?? 'INR',
        groupType: groupData['groupType'] ?? 'others',
        isRecurring: groupData['isRecurring'] ?? false,
        securityDepositRequired:
            (groupData['securityDepositRequired'] as num?)?.toDouble() ?? 0.0,
        requiresAdminApproval: groupData['requiresAdminApproval'] ?? false,
        budgetStrategy: groupData['budgetStrategy'] ?? 'equal',
        billingCycleStart: DateTime.parse(
            groupData['billingCycleStart'] ?? DateTime.now().toIso8601String()),
        splitStrategy: groupData['splitStrategy'] ?? 'equal',
        autoSettlement: groupData['autoSettlement'] ?? false,
        // createdAt: DateTime.parse(groupData['createdAt']),
        createdBy: groupData['createdBy'],
        members: (groupData['members'] as List<dynamic>?)
            ?.map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      AppLogger.error('Status: ${e.response?.statusCode}');
      AppLogger.error('Response: ${e.response?.data}');
      AppLogger.error('Headers: ${e.response?.headers}');
      AppLogger.error('Request path: ${e.requestOptions.path}');
      AppLogger.error('Request data: ${e.requestOptions.data}');
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<GroupModel> getGroupDetails(String groupId) async {
    try {
      final token = await AuthRepository().getStoredToken();
      if (token == null) throw Exception('Authentication token not found');

      AppLogger.debug('Fetching details for group: $groupId');

      final response = await _dio.get(
        '$apiUrl/api/v1/groups/$groupId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      AppLogger.debug('Group details response: ${response.data}');

      if (response.data == null || response.data['data'] == null) {
        throw Exception('No group data found');
      }

      final groupData = response.data['data'];
      return GroupModel.fromJson(groupData);
    } on DioException catch (e) {
      AppLogger.error('Failed to get group details: ${e.message}');
      AppLogger.error('Response: ${e.response?.data}');
      throw Exception('Failed to get group details: ${e.message}');
    }
  }

  String _getDescriptionForTag(String tag) {
    switch (tag) {
      case 'trip':
        return 'Group for tracking travel expenses';
      case 'home':
        return 'Group for managing household expenses';
      case 'couple':
        return 'Group for shared couple expenses';
      case 'flatmates':
        return 'Group for shared apartment expenses';
      default:
        return 'Group for tracking shared expenses';
    }
  }
}
