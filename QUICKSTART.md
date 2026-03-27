# 玻璃幕墙维修方案生成器 - 快速启动指南

## 📋 项目简介

本应用是一款基于Flutter开发的跨平台移动应用，专为玻璃幕墙维修行业设计，能够根据业主的维修需求自动生成专业的维修方案和预算报告。

## 🚀 快速开始

### 1. 环境准备

确保已安装以下软件：

- **Flutter SDK** (>= 3.0.0) - [安装指南](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (>= 3.0.0) - 随Flutter一起安装
- **Android Studio** 或 **Visual Studio Code** - IDE
- **Android SDK** - 用于Android开发
- **Xcode** (Mac用户) - 用于iOS开发

验证Flutter环境：
```bash
flutter doctor
```

### 2. 获取项目

```bash
cd c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 配置字体（重要）

应用需要中文字体来生成PDF报告。请下载 [Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC) 字体文件：

1. 下载 `NotoSansSC-Regular.otf` 和 `NotoSansSC-Bold.otf`
2. 将字体文件放入 `assets/fonts/` 目录

目录结构应为：
```
assets/
└── fonts/
    ├── NotoSansSC-Regular.otf
    └── NotoSansSC-Bold.otf
```

### 5. 运行应用

#### Android
```bash
# 连接设备或启动模拟器后
flutter run
```

#### iOS (Mac only)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

### 6. 构建发布版本

#### Android APK
```bash
flutter build apk --release
```
APK文件位置：`build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (推荐)
```bash
flutter build appbundle --release
```
用于Google Play商店发布

#### iOS (Mac only)
```bash
flutter build ios --release
```

## 📱 使用指南

### 主要功能流程

1. **新建维修需求**
   - 点击首页右下角"新建需求"按钮
   - 填写项目信息和业主信息
   - 添加维修项目

2. **选择维修类型**
   - 按分类浏览维修类型（密封、玻璃、五金等）
   - 或使用搜索功能快速定位
   - 点击维修类型查看详情

3. **填写维修参数**
   - 输入具体参数（面积、长度等）
   - 选择作业高度（影响难度系数）
   - 确认数量和单价

4. **生成方案**
   - 系统自动计算预算
   - 查看费用明细
   - 生成PDF报告

5. **分享/打印**
   - 分享PDF给业主
   - 直接打印报告

### 费用构成说明

| 费用项 | 占比 | 说明 |
|-------|------|------|
| 材料费 | 45% | 玻璃、密封胶、五金等 |
| 人工费 | 40% | 按工时计算 |
| 设备费 | 10% | 吊篮、脚手架等 |
| 措施费 | 5% | 安全网、警示带等 |
| 管理费 | 5% | 项目管理 |
| 利润 | 8% | 合理利润 |
| 税金 | 9% | 增值税 |

### 难度系数

| 作业高度 | 系数 | 场景 |
|---------|------|------|
| 地面(<3m) | 1.0 | 基础价格 |
| 低层(3-10m) | 1.3 | 需安全防护 |
| 中层(10-30m) | 1.6 | 吊篮作业 |
| 高层(30-50m) | 2.0 | 大型设备 |
| 超高层(>50m) | 2.5 | 特殊方案 |

## ⚙️ 配置说明

### 云端同步配置

在应用设置中配置服务器地址：
```
https://your-api-server.com/api
```

### 价格调整

如需调整价格标准，编辑文件：
```
lib/models/price_config.dart
```

## 🔧 常见问题

### 1. PDF生成中文乱码
确保已将中文字体文件放入 `assets/fonts/` 目录。

### 2. 无法连接设备
- Android：开启USB调试模式
- iOS：信任开发者证书

### 3. 依赖安装失败
```bash
flutter clean
flutter pub get
```

### 4. 编译错误
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## 📁 项目结构

```
glass_curtain_wall_repair/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   ├── providers/                # 状态管理
│   ├── screens/                  # 页面
│   ├── services/                 # 服务层
│   ├── widgets/                  # 组件
│   └── utils/                    # 工具类
├── assets/                       # 资源文件
│   ├── fonts/                    # 字体文件
│   └── images/                   # 图片资源
├── android/                      # Android配置
├── ios/                          # iOS配置
├── pubspec.yaml                  # 依赖配置
└── README.md                     # 项目说明
```

## 📝 后续开发建议

1. **云端API对接** - 实现后端服务
2. **地图定位** - 集成高德/百度地图
3. **照片上传** - 添加现场拍照功能
4. **数据导出** - 支持Excel导出
5. **多语言支持** - 添加英文版本

## 📞 技术支持

如有问题，请检查：
1. Flutter版本是否符合要求
2. 字体文件是否正确放置
3. 依赖是否完整安装

---

**版本**: 1.0.0  
**更新日期**: 2024年
