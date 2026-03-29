import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/repair_provider.dart';
import '../services/local_storage_service.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = LocalStorageService();
    final url = await storage.getServerUrl();
    if (url != null) {
      setState(() {
        _serverUrlController.text = url;
      });
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 用户账户
          _buildSectionHeader('账户信息'),
          if (auth.isLoggedIn) ...[
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(auth.currentUser?.name ?? '用户'),
              subtitle: Text(auth.currentUser?.phone ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _confirmLogout(context),
            ),
          ] else ...[
            const ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('未登录'),
              subtitle: Text('使用离线模式'),
            ),
          ],
          
          const Divider(),
          
          // 服务器设置
          _buildSectionHeader('服务器设置'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _serverUrlController,
              decoration: InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://your-server.com/api',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _saveServerUrl,
              child: const Text('保存服务器地址'),
            ),
          ),
          
          const Divider(),
          
          // 数据管理
          _buildSectionHeader('数据管理'),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('立即同步'),
            subtitle: const Text('将本地数据同步到云端'),
            onTap: () => _syncData(context),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('数据备份'),
            subtitle: const Text('导出数据到本地文件'),
            onTap: () => _backupData(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('数据恢复'),
            subtitle: const Text('从本地文件恢复数据'),
            onTap: () => _restoreData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('清除所有数据', style: TextStyle(color: Colors.red)),
            subtitle: const Text('删除所有本地数据，不可恢复'),
            onTap: () => _confirmClearData(context),
          ),
          
          const Divider(),
          
          // 关于
          _buildSectionHeader('关于'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('应用版本'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('使用说明'),
            onTap: () => _showHelp(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私政策'),
            onTap: () => _showPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('退出后需要重新登录，是否确认？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveServerUrl() async {
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) return;

    final storage = LocalStorageService();
    await storage.saveServerUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('服务器地址已保存')),
      );
    }
  }

  void _syncData(BuildContext context) {
    // 触发同步
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('同步功能开发中...')),
    );
  }

  void _backupData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('备份功能开发中...')),
    );
  }

  void _restoreData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('恢复功能开发中...')),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有本地数据，不可恢复。是否确认？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 清除 SharedPreferences 和 SQLite 数据库
              final storage = LocalStorageService();
              final dbService = DatabaseService();
              await storage.clearAll();
              
              // 获取所有需求单并逐一删除
              final requests = await dbService.getAllRequests();
              for (final req in requests) {
                await dbService.deleteRequest(req.id);
              }
              await dbService.close();

              if (context.mounted) {
                // 刷新内存中的列表
                Provider.of<RepairProvider>(context, listen: false).loadRequests();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有数据已清除')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 新建需求', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('点击首页右下角按钮，填写项目信息和维修需求。'),
              SizedBox(height: 12),
              Text('2. 选择维修类型', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('根据玻璃幕墙的损坏情况，选择对应的维修类型。'),
              SizedBox(height: 12),
              Text('3. 填写参数', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('填写维修面积、数量、作业高度等参数。'),
              SizedBox(height: 12),
              Text('4. 生成方案', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('系统自动计算预算，生成PDF维修方案。'),
              SizedBox(height: 12),
              Text('5. 分享导出', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('可以将PDF报告分享给客户或打印存档。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '本应用尊重并保护所有使用服务用户的个人隐私权。'
            '您在注册帐号或使用本服务时，可能需要填写一些必要的信息。'
            '我们会尽力保护您的信息安全，不会将您的信息提供给第三方。'
            '除非法律要求或经您明确同意。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
