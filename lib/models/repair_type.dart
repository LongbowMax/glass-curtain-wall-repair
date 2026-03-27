/// 玻璃幕墙维修类型
/// 按照出现概率从高到低排序

enum RepairCategory {
  /// 密封系统问题（最高概率，约占35%）
  sealingSystem,
  /// 玻璃损坏（约占25%）
  glassDamage,
  /// 五金配件故障（约占15%）
  hardwareFailure,
  /// 结构及框架问题（约占12%）
  structuralIssue,
  /// 排水系统问题（约占8%）
  drainageIssue,
  /// 开启扇问题（约占5%）
  openingSashIssue,
}

extension RepairCategoryExtension on RepairCategory {
  String get displayName {
    switch (this) {
      case RepairCategory.sealingSystem:
        return '密封系统';
      case RepairCategory.glassDamage:
        return '玻璃损坏';
      case RepairCategory.hardwareFailure:
        return '五金配件';
      case RepairCategory.structuralIssue:
        return '结构框架';
      case RepairCategory.drainageIssue:
        return '排水系统';
      case RepairCategory.openingSashIssue:
        return '开启扇';
    }
  }

  String get description {
    switch (this) {
      case RepairCategory.sealingSystem:
        return '密封胶老化、开裂、脱落等问题';
      case RepairCategory.glassDamage:
        return '玻璃破裂、自爆、划伤、雾化等';
      case RepairCategory.hardwareFailure:
        return '执手、铰链、滑撑、锁具等损坏';
      case RepairCategory.structuralIssue:
        return '框架变形、连接件松动、腐蚀等';
      case RepairCategory.drainageIssue:
        return '排水孔堵塞、排水不畅、积水等';
      case RepairCategory.openingSashIssue:
        return '开启不灵活、关闭不严、下垂等';
    }
  }

  double get probability {
    switch (this) {
      case RepairCategory.sealingSystem:
        return 0.35;
      case RepairCategory.glassDamage:
        return 0.25;
      case RepairCategory.hardwareFailure:
        return 0.15;
      case RepairCategory.structuralIssue:
        return 0.12;
      case RepairCategory.drainageIssue:
        return 0.08;
      case RepairCategory.openingSashIssue:
        return 0.05;
    }
  }

  String get icon {
    switch (this) {
      case RepairCategory.sealingSystem:
        return '🔧';
      case RepairCategory.glassDamage:
        return '💎';
      case RepairCategory.hardwareFailure:
        return '🔩';
      case RepairCategory.structuralIssue:
        return '🏗️';
      case RepairCategory.drainageIssue:
        return '💧';
      case RepairCategory.openingSashIssue:
        return '🪟';
    }
  }
}

/// 具体维修类型定义
class RepairType {
  final String id;
  final String code;
  final RepairCategory category;
  final String name;
  final String description;
  final double basePrice; // 基础单价（元）
  final String unit; // 计量单位
  final double probability; // 发生概率
  final List<String> requiredInfo; // 需要收集的信息字段
  final List<String> solutions; // 解决方案列表
  final List<String> materials; // 所需材料列表

  const RepairType({
    required this.id,
    required this.code,
    required this.category,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.unit,
    required this.probability,
    required this.requiredInfo,
    required this.solutions,
    required this.materials,
  });
}

/// 维修类型数据库
class RepairTypeDatabase {
  static final List<RepairType> allTypes = [
    // ========== 密封系统问题（35%）==========
    RepairType(
      id: 'seal_001',
      code: 'SJ-001',
      category: RepairCategory.sealingSystem,
      name: '硅酮密封胶老化更换',
      description: '幕墙硅酮耐候密封胶出现老化、开裂、粉化现象，需铲除重打',
      basePrice: 35.0,
      unit: '延米',
      probability: 0.35,
      requiredInfo: ['seam_length', 'seam_width', 'glue_brand', 'height_level'],
      solutions: [
        '铲除原有老化密封胶',
        '清洁缝隙，确保无灰尘油污',
        '粘贴美纹纸保护周边',
        '注入专用硅酮耐候密封胶',
        '刮平处理，确保密封效果'
      ],
      materials: ['硅酮耐候密封胶', '美纹纸', '清洁剂', '泡沫棒'],
    ),
    RepairType(
      id: 'seal_002',
      code: 'SJ-002',
      category: RepairCategory.sealingSystem,
      name: '结构密封胶更换',
      description: '玻璃与铝框间结构密封胶老化，需重新注胶',
      basePrice: 45.0,
      unit: '延米',
      probability: 0.30,
      requiredInfo: ['seam_length', 'glass_thickness', 'structure_type'],
      solutions: [
        '拆除旧胶，清理接触面',
        '涂刷专用底漆',
        '注入硅酮结构密封胶',
        '压实刮平，确保粘接牢固'
      ],
      materials: ['硅酮结构密封胶', '专用底漆', '清洁剂'],
    ),
    RepairType(
      id: 'seal_003',
      code: 'SJ-003',
      category: RepairCategory.sealingSystem,
      name: '胶条密封条更换',
      description: '三元乙丙胶条老化、断裂、脱落，需更换新胶条',
      basePrice: 25.0,
      unit: '延米',
      probability: 0.20,
      requiredInfo: ['strip_length', 'strip_type', 'profile_model'],
      solutions: [
        '拆除老化胶条',
        '清洁胶条槽口',
        '安装新胶条，确保嵌入到位',
        '检查密封效果'
      ],
      materials: ['三元乙丙密封胶条', '润滑剂'],
    ),
    
    // ========== 玻璃损坏问题（25%）==========
    RepairType(
      id: 'glass_001',
      code: 'BL-001',
      category: RepairCategory.glassDamage,
      name: '钢化玻璃自爆更换',
      description: '钢化玻璃因硫化镍杂质发生自爆，需整体更换',
      basePrice: 280.0,
      unit: '平方米',
      probability: 0.25,
      requiredInfo: ['glass_area', 'glass_thickness', 'glass_type', 'height_level', 'has_coating'],
      solutions: [
        '搭设安全防护',
        '拆除破损玻璃，注意碎片清理',
        '检查铝框和胶缝',
        '安装新玻璃，四周留缝均匀',
        '注胶密封，确保牢固'
      ],
      materials: ['钢化玻璃', '硅酮结构胶', '双面胶条', '泡沫棒'],
    ),
    RepairType(
      id: 'glass_002',
      code: 'BL-002',
      category: RepairCategory.glassDamage,
      name: '中空玻璃漏气起雾',
      description: '中空玻璃密封失效，内部出现水汽、雾气',
      basePrice: 320.0,
      unit: '平方米',
      probability: 0.22,
      requiredInfo: ['glass_area', 'glass_thickness', 'air_space', 'height_level'],
      solutions: [
        '拆除旧中空玻璃',
        '清理铝框内腔',
        '安装新中空玻璃',
        '四周注胶密封',
        '检测密封效果'
      ],
      materials: ['中空玻璃', '结构胶', '分子筛', '丁基胶'],
    ),
    RepairType(
      id: 'glass_003',
      code: 'BL-003',
      category: RepairCategory.glassDamage,
      name: 'Low-E镀膜玻璃更换',
      description: 'Low-E镀膜层损坏或脱落，影响节能效果',
      basePrice: 450.0,
      unit: '平方米',
      probability: 0.15,
      requiredInfo: ['glass_area', 'glass_thickness', 'coating_position', 'height_level'],
      solutions: [
        '防护准备',
        '拆除损坏玻璃',
        '检查镀膜方向',
        '安装新Low-E玻璃',
        '注胶密封处理'
      ],
      materials: ['Low-E中空玻璃', '结构胶', '密封胶条'],
    ),
    RepairType(
      id: 'glass_004',
      code: 'BL-004',
      category: RepairCategory.glassDamage,
      name: '夹胶玻璃破损更换',
      description: '夹胶玻璃外层或内层破损，需整体更换',
      basePrice: 380.0,
      unit: '平方米',
      probability: 0.12,
      requiredInfo: ['glass_area', 'glass_thickness', 'interlayer_type', 'height_level'],
      solutions: [
        '安全防护搭设',
        '拆除破损夹胶玻璃',
        '清理安装框',
        '安装新夹胶玻璃',
        '密封固定'
      ],
      materials: ['夹胶玻璃', 'PVB胶片', '结构胶'],
    ),
    
    // ========== 五金配件故障（15%）==========
    RepairType(
      id: 'hdw_001',
      code: 'HW-001',
      category: RepairCategory.hardwareFailure,
      name: '开启扇执手更换',
      description: '开启窗执手损坏、松动或操作不畅',
      basePrice: 85.0,
      unit: '套',
      probability: 0.15,
      requiredInfo: ['handle_type', 'spindle_length', 'handle_color'],
      solutions: [
        '拆除旧执手',
        '检查传动杆配合',
        '安装新执手',
        '调试开启力度'
      ],
      materials: ['不锈钢执手', '传动杆', '固定螺丝'],
    ),
    RepairType(
      id: 'hdw_002',
      code: 'HW-002',
      category: RepairCategory.hardwareFailure,
      name: '铰链滑撑更换',
      description: '窗扇铰链或滑撑锈蚀、断裂，导致窗扇下垂',
      basePrice: 120.0,
      unit: '套',
      probability: 0.12,
      requiredInfo: ['sash_weight', 'sash_size', 'hardware_brand'],
      solutions: [
        '拆除损坏铰链',
        '校正窗扇位置',
        '安装新铰链/滑撑',
        '调整开启角度和力度',
        '润滑保养'
      ],
      materials: ['不锈钢铰链', '不锈钢滑撑', '不锈钢螺丝'],
    ),
    RepairType(
      id: 'hdw_003',
      code: 'HW-003',
      category: RepairCategory.hardwareFailure,
      name: '多点锁系统维修',
      description: '窗扇多点锁点损坏或锁闭不严',
      basePrice: 150.0,
      unit: '套',
      probability: 0.10,
      requiredInfo: ['lock_points', 'sash_size', 'brand_preference'],
      solutions: [
        '检查锁点磨损情况',
        '更换损坏锁点',
        '调整锁座位置',
        '调试锁闭力度',
        '全面润滑'
      ],
      materials: ['多点锁体', '锁点', '锁座', '传动条'],
    ),
    RepairType(
      id: 'hdw_004',
      code: 'HW-004',
      category: RepairCategory.hardwareFailure,
      name: '地弹簧门维修',
      description: '玻璃门地弹簧漏油、力度不足或定位失效',
      basePrice: 280.0,
      unit: '套',
      probability: 0.08,
      requiredInfo: ['door_weight', 'door_width', 'floor_spring_brand'],
      solutions: [
        '拆除旧地弹簧',
        '清理门坑',
        '安装新地弹簧',
        '调整关门速度和力度',
        '测试定位功能'
      ],
      materials: ['地弹簧', '顶轴', '门夹', '密封胶'],
    ),
    
    // ========== 结构框架问题（12%）==========
    RepairType(
      id: 'str_001',
      code: 'ST-001',
      category: RepairCategory.structuralIssue,
      name: '铝框变形矫正',
      description: '幕墙铝型材框架因外力变形，需矫正或更换',
      basePrice: 200.0,
      unit: '延米',
      probability: 0.12,
      requiredInfo: ['frame_length', 'deform_degree', 'profile_model'],
      solutions: [
        '拆除变形部位玻璃',
        '评估变形程度',
        '矫正或更换铝框',
        '重新安装固定',
        '恢复密封'
      ],
      materials: ['铝合金型材', '连接件', '密封胶', '紧固件'],
    ),
    RepairType(
      id: 'str_002',
      code: 'ST-002',
      category: RepairCategory.structuralIssue,
      name: '预埋件及连接件加固',
      description: '幕墙与主体结构连接件锈蚀或松动',
      basePrice: 180.0,
      unit: '处',
      probability: 0.10,
      requiredInfo: ['connection_count', 'corrosion_degree', 'connection_type'],
      solutions: [
        '检查连接部位',
        '拆除锈蚀连接件',
        '更换不锈钢连接件',
        '紧固加固',
        '防腐处理'
      ],
      materials: ['不锈钢螺栓', '不锈钢连接件', '防腐涂料'],
    ),
    
    // ========== 排水系统问题（8%）==========
    RepairType(
      id: 'drn_001',
      code: 'DR-001',
      category: RepairCategory.drainageIssue,
      name: '排水孔疏通清理',
      description: '幕墙排水孔被灰尘、密封胶堵塞',
      basePrice: 35.0,
      unit: '处',
      probability: 0.08,
      requiredInfo: ['drain_count', 'block_degree', 'height_level'],
      solutions: [
        '定位排水孔位置',
        '清除堵塞物',
        '疏通排水通道',
        '安装防虫网',
        '排水测试'
      ],
      materials: ['防虫网', '密封胶', '清洁剂'],
    ),
    RepairType(
      id: 'drn_002',
      code: 'DR-002',
      category: RepairCategory.drainageIssue,
      name: '集水槽清理维修',
      description: '幕墙横框集水槽积灰、积水',
      basePrice: 55.0,
      unit: '延米',
      probability: 0.06,
      requiredInfo: ['trough_length', 'sediment_amount', 'access_difficulty'],
      solutions: [
        '打开检修口',
        '清理积灰杂物',
        '疏通排水管',
        '防腐处理',
        '封闭检修口'
      ],
      materials: ['密封胶', '防腐涂料', '排水管'],
    ),
    
    // ========== 开启扇问题（5%）==========
    RepairType(
      id: 'sash_001',
      code: 'SH-001',
      category: RepairCategory.openingSashIssue,
      name: '开启扇下垂调整',
      description: '窗扇因自重或五金松动导致下垂，关闭不严',
      basePrice: 120.0,
      unit: '扇',
      probability: 0.05,
      requiredInfo: ['sash_size', 'sash_weight', 'sag_degree'],
      solutions: [
        '检查铰链固定',
        '调整或更换铰链',
        '校正窗扇位置',
        '调整锁点配合',
        '测试密封性'
      ],
      materials: ['不锈钢铰链', '固定螺丝', '密封胶条'],
    ),
    RepairType(
      id: 'sash_002',
      code: 'SH-002',
      category: RepairCategory.openingSashIssue,
      name: '窗扇密封性修复',
      description: '窗扇关闭后与框间隙过大，密封不严漏风漏雨',
      basePrice: 95.0,
      unit: '扇',
      probability: 0.04,
      requiredInfo: ['gap_size', 'seal_condition', 'sash_type'],
      solutions: [
        '测量间隙尺寸',
        '更换密封胶条',
        '调整锁点位置',
        '增加辅助锁点',
        '密封性测试'
      ],
      materials: ['三元乙丙胶条', '多点锁', '密封胶'],
    ),
  ];

  /// 按分类获取维修类型
  static List<RepairType> getByCategory(RepairCategory category) {
    return allTypes.where((t) => t.category == category).toList();
  }

  /// 按ID获取维修类型
  static RepairType? getById(String id) {
    try {
      return allTypes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 按概率排序获取所有类型
  static List<RepairType> getAllSortedByProbability() {
    final sorted = List<RepairType>.from(allTypes);
    sorted.sort((a, b) => b.probability.compareTo(a.probability));
    return sorted;
  }
}
