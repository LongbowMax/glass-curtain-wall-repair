import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/repair_request.dart';
import '../models/repair_type.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class RepairProvider extends ChangeNotifier {
  User? _currentUser;
  List<RepairRequest> _requests = [];
  RepairRequest? _currentRequest;
  bool _isLoading = false;
  String? _error;

  final DatabaseService _dbService = DatabaseService();
  final SyncService _syncService = SyncService();
  final _uuid = const Uuid();

  // Getters
  List<RepairRequest> get requests => List.unmodifiable(_requests);
  RepairRequest? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  void setUser(User? user) {
    _currentUser = user;
    if (user != null) {
      loadRequests();
    }
    notifyListeners();
  }

  // 加载所有需求单
  Future<void> loadRequests() async {
    _setLoading(true);
    try {
      await _dbService.init();
      _requests = await _dbService.getAllRequests();
      _requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _error = null;
    } catch (e) {
      _error = '加载数据失败: $e';
    }
    _setLoading(false);
  }

  // 创建新的需求单
  RepairRequest createNewRequest() {
    final now = DateTime.now();
    _currentRequest = RepairRequest(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      items: [],
      photos: [],
    );
    notifyListeners();
    return _currentRequest!;
  }

  // 设置当前需求单
  void setCurrentRequest(RepairRequest request) {
    _currentRequest = request;
    notifyListeners();
  }

  // 更新需求单基本信息
  void updateRequestInfo({
    String? projectName,
    String? buildingName,
    String? ownerName,
    String? ownerPhone,
    String? ownerUnit,
    String? address,
    DateTime? inspectionDate,
    String? notes,
  }) {
    if (_currentRequest == null) return;

    _currentRequest!.projectName = projectName ?? _currentRequest!.projectName;
    _currentRequest!.buildingName = buildingName ?? _currentRequest!.buildingName;
    _currentRequest!.ownerName = ownerName ?? _currentRequest!.ownerName;
    _currentRequest!.ownerPhone = ownerPhone ?? _currentRequest!.ownerPhone;
    _currentRequest!.ownerUnit = ownerUnit ?? _currentRequest!.ownerUnit;
    _currentRequest!.address = address ?? _currentRequest!.address;
    _currentRequest!.inspectionDate = inspectionDate ?? _currentRequest!.inspectionDate;
    _currentRequest!.notes = notes ?? _currentRequest!.notes;
    _currentRequest!.updatedAt = DateTime.now();

    notifyListeners();
  }

  // 添加维修项目
  void addRepairItem(String repairTypeId, Map<String, dynamic> parameters, {
    int quantity = 1,
    double difficultyFactor = 1.0,
    String? notes,
  }) {
    if (_currentRequest == null) return;

    final item = RepairItem(
      id: _uuid.v4(),
      repairTypeId: repairTypeId,
      repairType: RepairTypeDatabase.getById(repairTypeId),
      parameters: parameters,
      quantity: quantity,
      difficultyFactor: difficultyFactor,
      notes: notes,
    );

    _currentRequest!.items.add(item);
    _currentRequest!.updatedAt = DateTime.now();
    notifyListeners();
  }

  // 更新维修项目
  void updateRepairItem(String itemId, {
    Map<String, dynamic>? parameters,
    int? quantity,
    double? difficultyFactor,
    String? notes,
  }) {
    if (_currentRequest == null) return;

    final index = _currentRequest!.items.indexWhere((i) => i.id == itemId);
    if (index < 0) return;

    final item = _currentRequest!.items[index];
    if (parameters != null) item.parameters = parameters;
    if (quantity != null) item.quantity = quantity;
    if (difficultyFactor != null) item.difficultyFactor = difficultyFactor;
    if (notes != null) item.notes = notes;

    _currentRequest!.updatedAt = DateTime.now();
    notifyListeners();
  }

  // 删除维修项目
  void removeRepairItem(String itemId) {
    if (_currentRequest == null) return;

    _currentRequest!.items.removeWhere((i) => i.id == itemId);
    _currentRequest!.updatedAt = DateTime.now();
    notifyListeners();
  }

  // 添加照片
  void addPhoto(String photoPath) {
    if (_currentRequest == null) return;

    _currentRequest!.photos ??= [];
    _currentRequest!.photos!.add(photoPath);
    _currentRequest!.updatedAt = DateTime.now();
    notifyListeners();
  }

  // 删除照片
  void removePhoto(String photoPath) {
    if (_currentRequest == null || _currentRequest!.photos == null) return;

    _currentRequest!.photos!.remove(photoPath);
    _currentRequest!.updatedAt = DateTime.now();
    notifyListeners();
  }

  // 保存需求单
  Future<bool> saveRequest() async {
    if (_currentRequest == null) return false;

    _setLoading(true);
    try {
      await _dbService.init();
      await _dbService.saveRequest(_currentRequest!);
      
      // 更新列表
      final existingIndex = _requests.indexWhere((r) => r.id == _currentRequest!.id);
      if (existingIndex >= 0) {
        _requests[existingIndex] = _currentRequest!;
      } else {
        _requests.insert(0, _currentRequest!);
      }

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = '保存失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 删除需求单
  Future<bool> deleteRequest(String requestId) async {
    _setLoading(true);
    try {
      await _dbService.init();
      await _dbService.deleteRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
      
      if (_currentRequest?.id == requestId) {
        _currentRequest = null;
      }

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = '删除失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 同步到云端
  Future<bool> syncToCloud(String requestId) async {
    _setLoading(true);
    try {
      final request = _requests.firstWhere((r) => r.id == requestId);
      final success = await _syncService.uploadRequest(request);
      
      if (success) {
        request.isSynced = true;
        await _dbService.updateSyncStatus(requestId, true);
        notifyListeners();
      }

      _error = null;
      _setLoading(false);
      return success;
    } catch (e) {
      _error = '同步失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 从云端同步
  Future<bool> syncFromCloud() async {
    _setLoading(true);
    try {
      final remoteRequests = await _syncService.downloadRequests(_currentUser?.id);
      
      for (var request in remoteRequests) {
        await _dbService.saveRequest(request);
        request.isSynced = true;
        
        final existingIndex = _requests.indexWhere((r) => r.id == request.id);
        if (existingIndex >= 0) {
          _requests[existingIndex] = request;
        } else {
          _requests.add(request);
        }
      }

      _requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _error = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '下载失败: $e';
      _setLoading(false);
      return false;
    }
  }

  // 计算当前需求单预算
  BudgetSummary? calculateCurrentBudget() {
    if (_currentRequest == null) return null;
    return _currentRequest!.calculateBudget();
  }

  // 获取维修方案
  List<RepairSolution> getCurrentSolutions() {
    if (_currentRequest == null) return [];
    
    return _currentRequest!.items.map((item) {
      final type = item.repairType ?? RepairTypeDatabase.getById(item.repairTypeId);
      if (type == null) return null;
      return RepairSolution.fromRepairType(type);
    }).whereType<RepairSolution>().toList();
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
