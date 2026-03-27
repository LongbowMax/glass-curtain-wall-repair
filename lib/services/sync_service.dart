import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/repair_request.dart';
import 'api_service.dart';
import 'database_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  bool _isSyncing = false;
  final _syncController = StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStream => _syncController.stream;

  // 上传单个需求单到云端
  Future<bool> uploadRequest(RepairRequest request) async {
    try {
      final data = request.toJson();
      final response = await _apiService.uploadRepairRequest(data);

      if (response['success'] == true) {
        await _dbService.updateSyncStatus(request.id, true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('上传失败: $e');
      return false;
    }
  }

  // 从云端下载需求单
  Future<List<RepairRequest>> downloadRequests(String? userId) async {
    try {
      final response = await _apiService.getRepairRequests(userId: userId);

      if (response['success'] == true) {
        final List<dynamic> data = response['data']?['list'] ?? [];
        return data.map((item) => RepairRequest.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('下载失败: $e');
      return [];
    }
  }

  // 同步所有数据
  Future<SyncResult> syncAll(String? userId) async {
    if (_isSyncing) {
      return SyncResult.alreadySyncing();
    }

    _isSyncing = true;
    _syncController.add(SyncStatus.syncing);

    int uploaded = 0;
    int downloaded = 0;
    int failed = 0;
    List<String> errors = [];

    try {
      // 1. 上传本地未同步的数据
      final unsynced = await _dbService.getUnsyncedRequests();
      for (var request in unsynced) {
        try {
          final success = await uploadRequest(request);
          if (success) {
            uploaded++;
          } else {
            failed++;
            errors.add('上传 ${request.id} 失败');
          }
        } catch (e) {
          failed++;
          errors.add('上传 ${request.id} 错误: $e');
        }
      }

      // 2. 下载云端数据
      final remoteRequests = await downloadRequests(userId);
      for (var request in remoteRequests) {
        try {
          request.isSynced = true;
          await _dbService.saveRequest(request);
          downloaded++;
        } catch (e) {
          failed++;
          errors.add('保存 ${request.id} 失败: $e');
        }
      }

      _syncController.add(SyncStatus.completed);
      return SyncResult.success(
        uploaded: uploaded,
        downloaded: downloaded,
        failed: failed,
        errors: errors,
      );
    } catch (e) {
      _syncController.add(SyncStatus.error);
      return SyncResult.error('同步过程发生错误: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // 检查是否需要同步
  Future<bool> needSync() async {
    final unsynced = await _dbService.getUnsyncedRequests();
    return unsynced.isNotEmpty;
  }

  void dispose() {
    _syncController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
}

class SyncResult {
  final bool success;
  final int uploaded;
  final int downloaded;
  final int failed;
  final List<String> errors;
  final String? message;

  SyncResult({
    required this.success,
    this.uploaded = 0,
    this.downloaded = 0,
    this.failed = 0,
    this.errors = const [],
    this.message,
  });

  factory SyncResult.success({
    required int uploaded,
    required int downloaded,
    required int failed,
    required List<String> errors,
  }) {
    return SyncResult(
      success: true,
      uploaded: uploaded,
      downloaded: downloaded,
      failed: failed,
      errors: errors,
    );
  }

  factory SyncResult.error(String message) {
    return SyncResult(
      success: false,
      message: message,
    );
  }

  factory SyncResult.alreadySyncing() {
    return SyncResult(
      success: false,
      message: '同步正在进行中',
    );
  }
}
