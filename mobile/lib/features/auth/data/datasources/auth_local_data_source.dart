import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheToken(String token) async {
    try {
      await secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to cache token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to get token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear token');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setInt(_userIdKey, user.id);
      await sharedPreferences.setString(_userNameKey, user.name);
      await sharedPreferences.setString(_userEmailKey, user.email);
      await sharedPreferences.setString(_userPhoneKey, user.phoneNumber);
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final id = sharedPreferences.getInt(_userIdKey);
      if (id == null) return null;

      final name = sharedPreferences.getString(_userNameKey);
      final email = sharedPreferences.getString(_userEmailKey);
      final phone = sharedPreferences.getString(_userPhoneKey);

      if (name == null || email == null || phone == null) return null;

      return UserModel(
        id: id,
        name: name,
        email: email,
        phoneNumber: phone,
      );
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await sharedPreferences.remove(_userIdKey);
      await sharedPreferences.remove(_userNameKey);
      await sharedPreferences.remove(_userEmailKey);
      await sharedPreferences.remove(_userPhoneKey);
    } catch (e) {
      throw CacheException('Failed to clear user');
    }
  }
}
