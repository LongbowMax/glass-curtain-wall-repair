import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 保存用户数据
  Future<bool> saveUserData(String userData) async {
    await init();
    return _prefs!.setString('user_data', userData);
  }

  // 获取用户数据
  Future<String?> getUserData() async {
    await init();
    return _prefs!.getString('user_data');
  }

  // 保存Token
  Future<bool> saveToken(String token) async {
    await init();
    return _prefs!.setString('auth_token', token);
  }

  // 获取Token
  Future<String?> getToken() async {
    await init();
    return _prefs!.getString('auth_token');
  }

  // 保存API服务器地址
  Future<bool> saveServerUrl(String url) async {
    await init();
    return _prefs!.setString('server_url', url);
  }

  // 获取API服务器地址
  Future<String?> getServerUrl() async {
    await init();
    return _prefs!.getString('server_url');
  }

  // 保存上次同步时间
  Future<bool> saveLastSyncTime(DateTime time) async {
    await init();
    return _prefs!.setString('last_sync_time', time.toIso8601String());
  }

  // 获取上次同步时间
  Future<DateTime?> getLastSyncTime() async {
    await init();
    final timeStr = _prefs!.getString('last_sync_time');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // 保存设置
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    await init();
    return _prefs!.setString('app_settings', settings.toString());
  }

  // 获取设置
  Future<Map<String, dynamic>?> getSettings() async {
    await init();
    final settingsStr = _prefs!.getString('app_settings');
    if (settingsStr != null) {
      // 简单解析，实际应该使用json
      return {};
    }
    return null;
  }

  // 清除所有数据
  Future<bool> clearAll() async {
    await init();
    return _prefs!.clear();
  }

  // 清除用户相关数据
  Future<void> clearUserData() async {
    await init();
    await _prefs!.remove('user_data');
    await _prefs!.remove('auth_token');
  }
}
