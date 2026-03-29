/// 上海地区价格配置
/// 包含材料、人工、设备、措施等各项费用标准

class ShanghaiPriceConfig {
  // ========== 高空作业难度系数 ==========
  static const Map<String, double> heightFactors = {
    'ground': 1.0, // 地面作业（3米以下）
    'low': 1.3, // 低层（3-10米）
    'mid': 1.6, // 中层（10-30米）
    'high': 2.0, // 高层（30-50米）
    'super_high': 2.5, // 超高层（50米以上）
  };

  static String getHeightLevelName(String level) {
    switch (level) {
      case 'ground':
        return '地面（<3m）';
      case 'low':
        return '低层（3-10m）';
      case 'mid':
        return '中层（10-30m）';
      case 'high':
        return '高层（30-50m）';
      case 'super_high':
        return '超高层（>50m）';
      default:
        return level;
    }
  }

  // ========== 玻璃材料价格（元/平方米） ==========
  static const Map<String, double> glassPrices = {
    'tempered_6mm': 120.0, // 6mm钢化玻璃
    'tempered_8mm': 160.0, // 8mm钢化玻璃
    'tempered_10mm': 200.0, // 10mm钢化玻璃
    'tempered_12mm': 240.0, // 12mm钢化玻璃
    'hollow_5_6a_5': 220.0, // 5+6A+5中空
    'hollow_5_9a_5': 260.0, // 5+9A+5中空
    'hollow_5_12a_5': 300.0, // 5+12A+5中空
    'hollow_6_9a_6': 320.0, // 6+9A+6中空
    'hollow_6_12a_6': 360.0, // 6+12A+6中空
    'low_e_hollow_5_12a_5': 420.0, // Low-E 5+12A+5
    'low_e_hollow_6_12a_6': 480.0, // Low-E 6+12A+6
    'laminated_6_0.76pvb_6': 380.0, // 6+0.76PVB+6夹胶
    'laminated_8_1.14pvb_8': 480.0, // 8+1.14PVB+8夹胶
  };

  // ========== 密封材料价格 ==========
  static const Map<String, double> sealantPrices = {
    'silicone_weather_500ml': 45.0, // 硅酮耐候胶（支）
    'silicone_structural_500ml': 65.0, // 硅酮结构胶（支）
    'epdm_strip_10mm': 18.0, // 三元乙丙胶条（延米）
    'butyl_tape': 25.0, // 丁基胶带（卷）
    'foam_backer_rod': 8.0, // 泡沫棒（延米）
    'masking_tape': 5.0, // 美纹纸（卷）
    'primer': 35.0, // 专用底漆（罐）
  };

  // ========== 五金配件价格（元/套） ==========
  static const Map<String, double> hardwarePrices = {
    'handle_standard': 65.0, // 标准执手
    'handle_premium': 120.0, // 高端执手
    'hinge_pair': 45.0, // 铰链（对）
    'friction_stay_12': 55.0, // 12寸滑撑
    'friction_stay_16': 75.0, // 16寸滑撑
    'multipoint_lock_2p': 180.0, // 2点锁
    'multipoint_lock_4p': 280.0, // 4点锁
    'floor_spring_80kg': 220.0, // 80kg地弹簧
    'floor_spring_150kg': 350.0, // 150kg地弹簧
    'patch_fitting_set': 150.0, // 门夹套装
  };

  // ========== 铝合金型材（元/延米） ==========
  static const Map<String, double> profilePrices = {
    'frame_6063_t5': 85.0, // 6063-T5型材
    'frame_6063_t6': 120.0, // 6063-T6型材
    'pressure_plate': 45.0, // 压板
    'cover_cap': 25.0, // 扣盖
  };

  // ========== 人工费标准（元/工日） ==========
  static const Map<String, double> laborPrices = {
    'general_worker': 350.0, // 普通工人
    'skilled_worker': 450.0, // 技术工人
    'glass_installer': 550.0, // 玻璃安装工
    'sealant_worker': 500.0, // 注胶工
    'high_altitude_worker': 650.0, // 高空作业工
    'supervisor': 800.0, // 现场管理员
  };

  // ========== 设备租赁费（元/天） ==========
  static const Map<String, double> equipmentPrices = {
    'gondola': 180.0, // 吊篮
    'scaffold': 120.0, // 脚手架
    'crane_small': 800.0, // 小型吊车
    'crane_medium': 1500.0, // 中型吊车
    'glass_suction_cup': 50.0, // 吸盘器
    'sealant_gun_electric': 30.0, // 电动注胶枪
    'welding_machine': 80.0, // 焊机
    'air_compressor': 60.0, // 空压机
  };

  // ========== 措施费标准 ==========
  static const Map<String, double> measurePrices = {
    'safety_net_m2': 15.0, // 安全网（元/平方米）
    'warning_tape_m': 3.0, // 警示带（元/延米）
    'construction_fence_m': 25.0, // 施工围挡（元/延米）
    'waste_transport_m3': 120.0, // 垃圾清运（元/立方米）
    'temporary_electricity': 200.0, // 临时用电（元/项）
    'protection_sheet_m2': 8.0, // 保护布（元/平方米）
  };

  // ========== 管理费、利润、税率 ==========
  static const double managementFeeRate = 0.05; // 管理费 5%
  static const double profitRate = 0.08; // 利润 8%
  static const double taxRate = 0.09; // 增值税 9%

  // ========== 辅助方法 ==========
  
  /// 获取玻璃价格
  static double getGlassPrice(String type) {
    return glassPrices[type] ?? 200.0;
  }

  /// 获取密封材料价格
  static double getSealantPrice(String type) {
    return sealantPrices[type] ?? 0.0;
  }

  /// 获取五金价格
  static double getHardwarePrice(String type) {
    return hardwarePrices[type] ?? 0.0;
  }

  /// 获取难度系数
  static double getHeightFactor(String level) {
    return heightFactors[level] ?? 1.0;
  }

  /// 玻璃厚度选项
  static const List<Map<String, dynamic>> glassThicknessOptions = [
    {'value': '6mm', 'label': '6mm', 'price_key': 'tempered_6mm'},
    {'value': '8mm', 'label': '8mm', 'price_key': 'tempered_8mm'},
    {'value': '10mm', 'label': '10mm', 'price_key': 'tempered_10mm'},
    {'value': '12mm', 'label': '12mm', 'price_key': 'tempered_12mm'},
  ];

  /// 高度等级选项
  static const List<Map<String, String>> heightLevelOptions = [
    {'value': 'ground', 'label': '地面（<3m）'},
    {'value': 'low', 'label': '低层（3-10m）'},
    {'value': 'mid', 'label': '中层（10-30m）'},
    {'value': 'high', 'label': '高层（30-50m）'},
    {'value': 'super_high', 'label': '超高层（>50m）'},
  ];
}
