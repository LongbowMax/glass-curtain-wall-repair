import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      print('SharedPreferences 初始化失败: $e');
      _initialized = false;
    }
  }

  // 确保已初始化
  Future<SharedPreferences?> _getPrefs() async {
    if (!_initialized) {
      await init();
    }
    return _prefs;
  }

  // 保存用户数据
  Future<bool> saveUserData(String userData) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.setString('user_data', userData);
  }

  // 获取用户数据
  Future<String?> getUserData() async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    return prefs.getString('user_data');
  }

  // 保存Token
  Future<bool> saveToken(String token) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.setString('auth_token', token);
  }

  // 获取Token
  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    return prefs.getString('auth_token');
  }

  // 保存API服务器地址
  Future<bool> saveServerUrl(String url) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.setString('server_url', url);
  }

  // 获取API服务器地址
  Future<String?> getServerUrl() async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    return prefs.getString('server_url');
  }

  // 保存上次同步时间
  Future<bool> saveLastSyncTime(DateTime time) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.setString('last_sync_time', time.toIso8601String());
  }

  // 获取上次同步时间
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    final timeStr = prefs.getString('last_sync_time');
    if (timeStr != null) {
      try {
        return DateTime.parse(timeStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // 保存设置
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.setString('app_settings', settings.toString());
  }

  // 获取设置
  Future<Map<String, dynamic>?> getSettings() async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    final settingsStr = prefs.getString('app_settings');
    if (settingsStr != null) {
      return {};
    }
    return null;
  }

  // 清除所有数据
  Future<bool> clearAll() async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.clear();
  }

  // 清除用户相关数据
  Future<void> clearUserData() async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
  }
}
