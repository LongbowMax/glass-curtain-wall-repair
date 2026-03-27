import 'dart:convert';
import 'repair_type.dart';

/// 维修需求单
class RepairRequest {
  String id;
  String? projectName; // 项目名称
  String? buildingName; // 楼栋名称
  String? ownerName; // 业主姓名
  String? ownerPhone; // 业主电话
  String? ownerUnit; // 业主单位
  String? address; // 详细地址
  DateTime? inspectionDate; // 勘查日期
  DateTime createdAt;
  DateTime updatedAt;
  List<RepairItem> items; // 维修项目列表
  List<String>? photos; // 现场照片路径列表
  String? notes; // 备注
  bool isSynced; // 是否已同步云端

  RepairRequest({
    required this.id,
    this.projectName,
    this.buildingName,
    this.ownerName,
    this.ownerPhone,
    this.ownerUnit,
    this.address,
    this.inspectionDate,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.photos,
    this.notes,
    this.isSynced = false,
  });

  /// 计算总费用
  BudgetSummary calculateBudget() {
    double materialCost = 0;
    double laborCost = 0;
    double equipmentCost = 0;
    double measureCost = 0;
    
    for (var item in items) {
      final itemBudget = item.calculateBudget();
      materialCost += itemBudget.materialCost;
      laborCost += itemBudget.laborCost;
      equipmentCost += itemBudget.equipmentCost;
      measureCost += itemBudget.measureCost;
    }

    // 管理费（5%）
    double managementCost = (materialCost + laborCost) * 0.05;
    // 利润（8%）
    double profit = (materialCost + laborCost + managementCost) * 0.08;
    // 税金（9%增值税）
    double subtotal = materialCost + laborCost + equipmentCost + measureCost + managementCost + profit;
    double tax = subtotal * 0.09;
    // 合计
    double total = subtotal + tax;

    return BudgetSummary(
      materialCost: materialCost,
      laborCost: laborCost,
      equipmentCost: equipmentCost,
      measureCost: measureCost,
      managementCost: managementCost,
      profit: profit,
      tax: tax,
      total: total,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectName': projectName,
    'buildingName': buildingName,
    'ownerName': ownerName,
    'ownerPhone': ownerPhone,
    'ownerUnit': ownerUnit,
    'address': address,
    'inspectionDate': inspectionDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'photos': photos,
    'notes': notes,
    'isSynced': isSynced,
  };

  factory RepairRequest.fromJson(Map<String, dynamic> json) => RepairRequest(
    id: json['id'],
    projectName: json['projectName'],
    buildingName: json['buildingName'],
    ownerName: json['ownerName'],
    ownerPhone: json['ownerPhone'],
    ownerUnit: json['ownerUnit'],
    address: json['address'],
    inspectionDate: json['inspectionDate'] != null 
        ? DateTime.parse(json['inspectionDate']) 
        : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    items: (json['items'] as List).map((e) => RepairItem.fromJson(e)).toList(),
    photos: json['photos'] != null 
        ? List<String>.from(json['photos']) 
        : null,
    notes: json['notes'],
    isSynced: json['isSynced'] ?? false,
  );
}

/// 单个维修项目
class RepairItem {
  String id;
  String repairTypeId;
  RepairType? repairType; // 关联的维修类型
  Map<String, dynamic> parameters; // 参数值（如：面积、长度等）
  int quantity; // 数量
  double? customPrice; // 自定义单价（覆盖基础单价）
  double difficultyFactor; // 难度系数（高空作业等）
  String? notes;

  RepairItem({
    required this.id,
    required this.repairTypeId,
    this.repairType,
    this.parameters = const {},
    this.quantity = 1,
    this.customPrice,
    this.difficultyFactor = 1.0,
    this.notes,
  });

  /// 获取单价
  double get unitPrice => customPrice ?? repairType?.basePrice ?? 0;

  /// 计算项目预算明细
  ItemBudget calculateBudget() {
    final baseAmount = unitPrice * quantity;
    
    // 根据难度调整
    final adjustedAmount = baseAmount * difficultyFactor;
    
    // 材料费占比约45%
    double materialCost = adjustedAmount * 0.45;
    // 人工费占比约40%
    double laborCost = adjustedAmount * 0.40;
    // 设备费占比约10%
    double equipmentCost = adjustedAmount * 0.10;
    // 措施费占比约5%
    double measureCost = adjustedAmount * 0.05;

    // 高空作业附加费
    if (difficultyFactor > 1.0) {
      final extra = (difficultyFactor - 1.0) * baseAmount;
      laborCost += extra * 0.6;
      equipmentCost += extra * 0.4;
    }

    return ItemBudget(
      materialCost: materialCost,
      laborCost: laborCost,
      equipmentCost: equipmentCost,
      measureCost: measureCost,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'repairTypeId': repairTypeId,
    'parameters': parameters,
    'quantity': quantity,
    'customPrice': customPrice,
    'difficultyFactor': difficultyFactor,
    'notes': notes,
  };

  factory RepairItem.fromJson(Map<String, dynamic> json) => RepairItem(
    id: json['id'],
    repairTypeId: json['repairTypeId'],
    parameters: json['parameters'] ?? {},
    quantity: json['quantity'] ?? 1,
    customPrice: json['customPrice'],
    difficultyFactor: json['difficultyFactor']?.toDouble() ?? 1.0,
    notes: json['notes'],
  );
}

/// 项目预算明细
class ItemBudget {
  final double materialCost; // 材料费
  final double laborCost; // 人工费
  final double equipmentCost; // 设备费
  final double measureCost; // 措施费

  const ItemBudget({
    required this.materialCost,
    required this.laborCost,
    required this.equipmentCost,
    required this.measureCost,
  });

  double get subtotal => materialCost + laborCost + equipmentCost + measureCost;
}

/// 预算汇总
class BudgetSummary {
  final double materialCost; // 材料费合计
  final double laborCost; // 人工费合计
  final double equipmentCost; // 设备费合计
  final double measureCost; // 措施费合计
  final double managementCost; // 管理费
  final double profit; // 利润
  final double tax; // 税金
  final double total; // 总计

  const BudgetSummary({
    required this.materialCost,
    required this.laborCost,
    required this.equipmentCost,
    required this.measureCost,
    required this.managementCost,
    required this.profit,
    required this.tax,
    required this.total,
  });

  /// 不含税合计
  double get subtotalExclTax => materialCost + laborCost + equipmentCost + measureCost + managementCost + profit;

  Map<String, dynamic> toJson() => {
    'materialCost': materialCost,
    'laborCost': laborCost,
    'equipmentCost': equipmentCost,
    'measureCost': measureCost,
    'managementCost': managementCost,
    'profit': profit,
    'tax': tax,
    'total': total,
  };
}

/// 维修方案
class RepairSolution {
  final String title;
  final List<String> steps;
  final List<String> materials;
  final String? precautions;
  final String? qualityStandard;
  final String? warranty;

  const RepairSolution({
    required this.title,
    required this.steps,
    required this.materials,
    this.precautions,
    this.qualityStandard,
    this.warranty,
  });

  factory RepairSolution.fromRepairType(RepairType type) {
    return RepairSolution(
      title: '${type.name}施工方案',
      steps: type.solutions,
      materials: type.materials,
      precautions: '1. 施工前做好安全防护措施\n2. 高空作业人员必须持证上岗\n3. 材料需符合国家标准\n4. 施工时注意保护周边设施',
      qualityStandard: '1. 符合国家《建筑装饰装修工程质量验收标准》GB 50210\n2. 幕墙气密性能达到设计要求\n3. 外观平整、胶缝均匀',
      warranty: '本维修工程质保期2年，质保期内因施工质量问题免费维修',
    );
  }
}
