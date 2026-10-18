import 'package:dio/dio.dart';
import 'package:fingenie/domain/entities/auth/create_login_request.dart';
import 'package:fingenie/domain/entities/auth/create_signup_request.dart';
import 'package:fingenie/domain/models/user_model.dart';
import 'package:fingenie/utils/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _tokenKey = 'auth_token';

  Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      AppLogger.success('Token stored in SharedPreferences');
    } catch (e) {
      AppLogger.error('Failed to store token: $e');
    }
  }

  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      AppLogger.error('Failed to get token: $e');
      return null;
    }
  }

  static Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      // Always close the box if it's open before reopening
      if (Hive.isBoxOpen(userBoxName)) {
        await Hive.box<UserModel>(userBoxName).close();
      }

      // Open the box
      final box = await Hive.openBox<UserModel>(userBoxName);
      AppLogger.debug('AuthRepository initialized with ${box.length} items');

      // Debug box contents
      for (var key in box.keys) {
        final user = box.get(key);
        AppLogger.debug('Box contains key: $key with user: ${user?.name}');
      }
    } catch (e) {
      AppLogger.error('Failed to initialize AuthRepository: $e');
      rethrow;
    }
  }

  final Dio _dio;
  final Box<UserModel> _userBox;

  static const String userBoxName = 'userBox';
  final String apiUrl = dotenv.env['API_URL'] ?? '';

  AuthRepository({
    Dio? dio,
    Box<UserModel>? userBox,
  })  : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 3),
            )),
        _userBox = userBox ?? Hive.box<UserModel>(userBoxName);

  // Replace the existing signUp method with:
  Future<UserModel> signUp(SignUpRequest request) async {
    try {
      AppLogger.debug(
          'Making request to: $apiUrl/api/v1/auth/signup'); // or login
      // Prepare request body
      final data = {
        'email': request.email,
        'password': request.password,
        'displayName': request.name,
        'phoneNumber': request.phoneNumber,
      };
      AppLogger.debug('Request data: $data');

      // Make API call
      final response = await _dio.post(
        '$apiUrl/api/v1/auth/signup',
        data: data,
      );
      AppLogger.success('signUp: signup request successfull');
      // Extract token and user data
      final responseData = response.data['data'];
      final token = responseData['token'];
      final userData = responseData['user'];
      AppLogger.success('signUp: response data extracted');

      // Create user model
      final user = UserModel(
        id: userData['id'],
        name: userData['displayName'],
        email: userData['email'],
        phoneNumber: request.phoneNumber,
        createdAt: DateTime.now(),
        isLoggedIn: true,
        token: token,
        currency: '',
        age: 0,
        occupation: '',
        monthlyIncome: 0,
      );
      await _storeToken(token);

      // Save to Hive
      if (Hive.isBoxOpen(userBoxName)) {
        await _userBox.close();
      }
      final box = await Hive.openBox<UserModel>(userBoxName);
      await box.put('current_user', user);

      AppLogger.success('signUp: User saved to local storage');
      return user;
    } on DioException catch (e) {
      AppLogger.error('Full error details: ${e.toString()}');
      AppLogger.error('signUp: DioException: $e');
      throw _handleDioError(e);
    } catch (e) {
      AppLogger.error('Full error details: ${e.toString()}');
      AppLogger.error('signUp: Error: $e');
      throw Exception('Failed to sign up. Please try again.');
    }
  }

  Future<UserModel> login(LoginRequest request) async {
    try {
      AppLogger.info('login: Making login request');

      final data = {
        'email': request.email,
        'password': request.password,
      };

      final response = await _dio.post(
        '$apiUrl/api/v1/auth/login',
        data: data,
      );

      final responseData = response.data['data'];
      final token = responseData['token'];
      final userData = responseData['user'];

      final user = UserModel(
        id: userData['id'],
        name: userData['displayName'],
        email: userData['email'],
        phoneNumber: '', // Not returned by login API
        createdAt: DateTime.now(),
        isLoggedIn: true,
        token: token, currency: '', age: 0, occupation: '',
        monthlyIncome: 0,
      );

      if (Hive.isBoxOpen(userBoxName)) {
        await _userBox.close();
      }
      final box = await Hive.openBox<UserModel>(userBoxName);
      await box.put('current_user', user);

      // setAuthToken(token);
      AppLogger.success('login: User saved to local storage');
      return user;
    } on DioException catch (e) {
      AppLogger.error('login: DioException: $e');
      throw _handleLoginDioError(e);
    }
  }

  Exception _handleLoginDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Invalid email or password');
    }
    if (e.response?.statusCode == 400) {
      return Exception('Invalid input data');
    }
    return Exception('Failed to log in. Please try again.');
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 409) {
      return Exception('Email already exists');
    }
    if (e.response?.statusCode == 400) {
      return Exception('Invalid input data');
    }
    return Exception('Failed to sign up. Please try again.');
  }

  Future<void> logout() async {
    await _userBox.delete('current_user');
  }

  UserModel? getCurrentUser() {
    try {
      if (!Hive.isBoxOpen(userBoxName)) {
        Hive.openBox<UserModel>(userBoxName);
      }
      return _userBox.get('current_user');
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      return null;
    }
  }

  // Add a method to verify user persistence
  Future<void> verifyUserPersistence() async {
    try {
      if (!Hive.isBoxOpen(userBoxName)) {
        await Hive.openBox<UserModel>(userBoxName);
      }

      final user = _userBox.get('current_user');
      if (user != null) {
        AppLogger.debug('''
Verified persisted user:
ID: ${user.id}
Name: ${user.name}
Email: ${user.email}
IsLoggedIn: ${user.isLoggedIn}
''');
      } else {
        AppLogger.warning('No user found in persistence');
      }
    } catch (e) {
      AppLogger.error('Error verifying user persistence: $e');
    }
  }

  // Add this method to help with debugging
  static Future<void> debugBoxContents() async {
    try {
      if (!Hive.isBoxOpen(userBoxName)) {
        await Hive.openBox<UserModel>(userBoxName);
      }

      final box = Hive.box<UserModel>(userBoxName);
      AppLogger.debug('''
Box Debug Information:
Box is open: ${Hive.isBoxOpen(userBoxName)}
Box length: ${box.length}
Box keys: ${box.keys.toList()}
Current user exists: ${box.get('current_user') != null}
''');
    } catch (e) {
      AppLogger.error('Error debugging box contents: $e');
    }
  }

  Future<UserModel?> updateProfileLocally({
    required String currency,
    required int age,
    required String occupation,
    required double monthlyIncome,
  }) async {
    try {
      AppLogger.debug(
          'Updating profile locally with: currency: $currency, age: $age, occupation: $occupation, monthlyIncome: $monthlyIncome');

      // Get current user
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        AppLogger.error('No current user found to update');
        return null;
      }

      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        phoneNumber: currentUser.phoneNumber,
        createdAt: currentUser.createdAt,
        token: currentUser.token,
        isLoggedIn: true,
        currency: currency,
        age: age,
        occupation: occupation,
        monthlyIncome: monthlyIncome,
      );

      // Save to Hive
      if (Hive.isBoxOpen(userBoxName)) {
        await _userBox.close();
      }
      final box = await Hive.openBox<UserModel>(userBoxName);
      await box.put('current_user', updatedUser);

      AppLogger.success('Profile updated locally');
      return updatedUser;
    } catch (e) {
      AppLogger.error('Failed to update profile locally: $e');
      return null;
    }
  }
}
