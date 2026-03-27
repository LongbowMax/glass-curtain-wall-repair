import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _error;

  final ApiService _apiService = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;

  AuthProvider() {
    _checkLoggedIn();
  }

  // 检查是否已登录
  Future<void> _checkLoggedIn() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      final userData = await _storage.getUserData();
      final token = await _storage.getToken();

      if (userData != null && token != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
        _apiService.setToken(token);
      }
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  // 登录
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.login(username, password);

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final token = response['data']['token'];

        _currentUser = User.fromJson(userData);
        
        // 保存登录信息
        await _storage.saveUserData(jsonEncode(userData));
        await _storage.saveToken(token);
        _apiService.setToken(token);

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '登录失败';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = '登录失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 注册
  Future<bool> register({
    required String username,
    required String password,
    required String name,
    String? phone,
    String? email,
    String? company,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.register(
        username: username,
        password: password,
        name: name,
        phone: phone,
        email: email,
        company: company,
      );

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? '注册失败';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = '注册失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 退出登录
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('登出API调用失败: $e');
    }

    // 清除本地数据
    await _storage.clearAll();
    _apiService.clearToken();
    _currentUser = null;

    _setLoading(false);
    notifyListeners();
  }

  // 更新用户信息
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.updateProfile(data);

      if (response['success'] == true) {
        final updatedUser = User.fromJson(response['data']);
        _currentUser = updatedUser;
        await _storage.saveUserData(jsonEncode(updatedUser.toJson()));

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '更新失败';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = '更新失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 修改密码
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.changePassword(oldPassword, newPassword);

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? '修改密码失败';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = '修改密码失败: $e';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
