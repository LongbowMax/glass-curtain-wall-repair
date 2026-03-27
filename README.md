# 玻璃幕墙维修方案生成器

一款专业的Flutter跨平台应用，用于根据玻璃幕墙业主提供的维修需求，自动生成维修方案和维修预算。

## 功能特性

### 核心功能
- 📋 **维修需求录入** - 支持项目信息、业主信息、维修项目等详细录入
- 🔧 **智能类型匹配** - 按概率排序的6大类维修类型，共16种具体维修项目
  - 密封系统问题（35%）
  - 玻璃损坏（25%）
  - 五金配件故障（15%）
  - 结构框架问题（12%）
  - 排水系统问题（8%）
  - 开启扇问题（5%）
- 💰 **自动预算计算** - 包含材料费、人工费、设备费、措施费、管理费、利润、税金
- 📄 **PDF报告生成** - 生成专业的维修方案和预算报告
- ☁️ **云端同步** - 支持数据云端同步，多设备共享

### 技术特性
- 📱 跨平台支持（Android/iOS）
- 🎨 Material Design 3 设计风格
- 💾 本地SQLite数据库
- 🔒 用户认证与数据安全
- 📤 报告分享与打印

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── repair_type.dart      # 维修类型定义
│   ├── repair_request.dart   # 维修需求单
│   ├── user.dart             # 用户模型
│   └── price_config.dart     # 价格配置
├── providers/                # 状态管理
│   ├── auth_provider.dart    # 认证状态
│   └── repair_provider.dart  # 维修单状态
├── screens/                  # 页面
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── new_request_screen.dart
│   ├── select_repair_type_screen.dart
│   ├── repair_item_detail_screen.dart
│   ├── request_detail_screen.dart
│   └── settings_screen.dart
├── services/                 # 服务层
│   ├── api_service.dart      # API服务
│   ├── database_service.dart # 本地数据库
│   ├── sync_service.dart     # 同步服务
│   ├── pdf_service.dart      # PDF生成
│   └── local_storage_service.dart
├── widgets/                  # 组件
│   └── repair_type_card.dart
└── utils/                    # 工具类
    └── helpers.dart
```

## 维修类型清单

| 分类 | 维修项目 | 代码 | 参考单价 |
|------|---------|------|---------|
| 密封系统 | 硅酮密封胶老化更换 | SJ-001 | ¥35/延米 |
| 密封系统 | 结构密封胶更换 | SJ-002 | ¥45/延米 |
| 密封系统 | 胶条密封条更换 | SJ-003 | ¥25/延米 |
| 玻璃损坏 | 钢化玻璃自爆更换 | BL-001 | ¥280/㎡ |
| 玻璃损坏 | 中空玻璃漏气起雾 | BL-002 | ¥320/㎡ |
| 玻璃损坏 | Low-E镀膜玻璃更换 | BL-003 | ¥450/㎡ |
| 玻璃损坏 | 夹胶玻璃破损更换 | BL-004 | ¥380/㎡ |
| 五金配件 | 开启扇执手更换 | HW-001 | ¥85/套 |
| 五金配件 | 铰链滑撑更换 | HW-002 | ¥120/套 |
| 五金配件 | 多点锁系统维修 | HW-003 | ¥150/套 |
| 五金配件 | 地弹簧门维修 | HW-004 | ¥280/套 |
| 结构框架 | 铝框变形矫正 | ST-001 | ¥200/延米 |
| 结构框架 | 预埋件及连接件加固 | ST-002 | ¥180/处 |
| 排水系统 | 排水孔疏通清理 | DR-001 | ¥35/处 |
| 排水系统 | 集水槽清理维修 | DR-002 | ¥55/延米 |
| 开启扇 | 开启扇下垂调整 | SH-001 | ¥120/扇 |
| 开启扇 | 窗扇密封性修复 | SH-002 | ¥95/扇 |

## 费用构成

- **材料费** (45%) - 玻璃、密封胶、五金配件等
- **人工费** (40%) - 按工时计算
- **设备费** (10%) - 吊篮、脚手架等设备租赁
- **措施费** (5%) - 安全网、警示带等
- **管理费** (5%) - 项目管理成本
- **利润** (8%) - 合理利润空间
- **税金** (9%) - 增值税

## 难度系数

| 作业高度 | 系数 | 说明 |
|---------|------|------|
| 地面 (<3m) | 1.0 | 基础价格 |
| 低层 (3-10m) | 1.3 | 需安全防护措施 |
| 中层 (10-30m) | 1.6 | 需吊篮作业 |
| 高层 (30-50m) | 2.0 | 大型设备作业 |
| 超高层 (>50m) | 2.5 | 特殊方案作业 |

## 安装运行

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK / Xcode

### 安装步骤

1. 克隆项目
```bash
git clone <repository-url>
cd glass_curtain_wall_repair
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

4. 构建发布版本
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 配置说明

### 服务器配置
在设置页面配置API服务器地址：
```
https://your-server.com/api
```

### 价格调整
修改 `lib/models/price_config.dart` 中的价格配置。

## 技术栈

- **Flutter** - 跨平台UI框架
- **Provider** - 状态管理
- **SQLite** - 本地数据库
- **Dio** - HTTP客户端
- **PDF** - PDF生成
- **Share Plus** - 分享功能

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎联系开发团队。
