import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;
  String? _baseUrl;

  // 初始化Dio
  void init({String? baseUrl}) {
    _baseUrl = baseUrl ?? 'https://your-api-server.com/api';
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        debugPrint('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // 设置Token
  void setToken(String token) {
    _token = token;
  }

  // 清除Token
  void clearToken() {
    _token = null;
  }

  // 登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 注册
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String name,
    String? phone,
    String? email,
    String? company,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 登出
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 更新用户信息
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/user/profile', data: data);
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 修改密码
  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final response = await _dio.put('/user/password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 上传维修需求单
  Future<Map<String, dynamic>> uploadRepairRequest(
      Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/repair-requests', data: request);
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 获取维修需求单列表
  Future<Map<String, dynamic>> getRepairRequests({
    int page = 1,
    int pageSize = 20,
    String? userId,
  }) async {
    try {
      final response = await _dio.get('/repair-requests', queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (userId != null) 'userId': userId,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 获取单个维修需求单
  Future<Map<String, dynamic>> getRepairRequest(String id) async {
    try {
      final response = await _dio.get('/repair-requests/$id');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 删除维修需求单
  Future<Map<String, dynamic>> deleteRepairRequest(String id) async {
    try {
      final response = await _dio.delete('/repair-requests/$id');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 上传图片
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/upload/image', data: formData);
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // 错误处理
  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return {
          'success': false,
          'message': error.response?.data?['message'] ?? '请求失败',
          'code': error.response?.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '网络连接失败，请检查网络设置',
          'code': null,
        };
      }
    }
    return {
      'success': false,
      'message': '发生未知错误: $error',
      'code': null,
    };
  }
}
