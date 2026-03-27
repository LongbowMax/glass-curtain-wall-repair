import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/repair_provider.dart';
import '../providers/auth_provider.dart';
import '../models/repair_request.dart';
import 'request_detail_screen.dart';
import 'new_request_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RepairProvider>(context, listen: false).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repairProvider = Provider.of<RepairProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('幕墙维修专家'),
        actions: [
          // 同步按钮
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: '同步数据',
            onPressed: () => _syncData(context),
          ),
          // 设置
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(repairProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewRequest(context),
        icon: const Icon(Icons.add),
        label: const Text('新建需求'),
      ),
    );
  }

  Widget _buildBody(RepairProvider provider) {
    if (provider.isLoading && provider.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.requests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: provider.loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.requests.length,
        itemBuilder: (context, index) {
          final request = provider.requests[index];
          return _buildRequestCard(context, request);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无维修需求单',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建新的维修需求',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RepairRequest request) {
    final budget = request.calculateBudget();
    final currencyFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final totalStr = budget.total.toStringAsFixed(0).replaceAllMapped(
      currencyFormat,
      (match) => ',',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewRequestDetail(context, request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.projectName ?? '未命名项目',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!request.isSynced)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '未同步',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    request.ownerName ?? '-',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    request.ownerPhone ?? '-',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '¥$totalStr',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (request.items.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 4),
                Text(
                  '共 ${request.items.length} 个维修项目',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _createNewRequest(BuildContext context) {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    provider.createNewRequest();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewRequestScreen()),
    );
  }

  void _viewRequestDetail(BuildContext context, RepairRequest request) {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    provider.setCurrentRequest(request);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RequestDetailScreen()),
    );
  }

  void _syncData(BuildContext context) async {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在同步数据...'),
          ],
        ),
      ),
    );

    final success = await provider.syncFromCloud();

    if (context.mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '同步成功' : '同步失败: ${provider.error}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
