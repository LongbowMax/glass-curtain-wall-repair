import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/repair_provider.dart';
import '../models/repair_request.dart';
import '../models/repair_type.dart';
import '../services/pdf_service.dart';

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RepairProvider>(context);
    final request = provider.currentRequest;

    if (request == null) {
      return const Scaffold(
        body: Center(child: Text('未找到需求单')),
      );
    }

    final budget = request.calculateBudget();

    return Scaffold(
      appBar: AppBar(
        title: const Text('需求单详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '分享',
            onPressed: () => _shareReport(context, request),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: '打印',
            onPressed: () => _printReport(context, request),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, request),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('编辑'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('删除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicInfoCard(request),
          const SizedBox(height: 16),
          _buildBudgetCard(budget),
          const SizedBox(height: 16),
          _buildItemsCard(request),
          const SizedBox(height: 16),
          _buildSolutionsCard(request),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, request),
    );
  }

  Widget _buildBasicInfoCard(RepairRequest request) {
    final dateFormat = DateFormat('yyyy年MM月dd日');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.projectName ?? '未命名项目',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person, '业主', request.ownerName ?? '-'),
            _buildInfoRow(Icons.phone, '电话', request.ownerPhone ?? '-'),
            if (request.ownerUnit != null)
              _buildInfoRow(Icons.apartment, '单位', request.ownerUnit!),
            if (request.buildingName != null)
              _buildInfoRow(Icons.location_city, '楼栋', request.buildingName!),
            if (request.address != null)
              _buildInfoRow(Icons.location_on, '地址', request.address!),
            _buildInfoRow(
              Icons.calendar_today,
              '勘查日期',
              request.inspectionDate != null
                  ? dateFormat.format(request.inspectionDate!)
                  : '-',
            ),
            _buildInfoRow(
              Icons.access_time,
              '创建时间',
              dateFormat.format(request.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label：',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetSummary budget) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  '预算汇总',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildBudgetRow('材料费', budget.materialCost),
            _buildBudgetRow('人工费', budget.laborCost),
            _buildBudgetRow('设备费', budget.equipmentCost),
            _buildBudgetRow('措施费', budget.measureCost),
            _buildBudgetRow('管理费', budget.managementCost),
            _buildBudgetRow('利润', budget.profit),
            const Divider(),
            _buildBudgetRow('税前合计', budget.subtotalExclTax),
            _buildBudgetRow('税金（9%）', budget.tax),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '总计',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    currencyFormat.format(budget.total),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(String label, double value) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            currencyFormat.format(value),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(RepairRequest request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '维修项目 (${request.items.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...request.items.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              final type = item.repairType ?? RepairTypeDatabase.getById(item.repairTypeId);
              final itemBudget = item.calculateBudget();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text('$index'),
                ),
                title: Text(type?.name ?? '未知项目'),
                subtitle: Text('${item.quantity} ${type?.unit ?? "项"}'),
                trailing: Text(
                  '¥${itemBudget.subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionsCard(RepairRequest request) {
    final solutions = request.items.map((item) {
      final type = item.repairType ?? RepairTypeDatabase.getById(item.repairTypeId);
      if (type == null) return null;
      return RepairSolution.fromRepairType(type);
    }).whereType<RepairSolution>().toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  '维修方案',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...solutions.asMap().entries.expand((entry) {
              final index = entry.key + 1;
              final solution = entry.value;
              return [
                Text(
                  '$index. ${solution.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('施工步骤：', style: TextStyle(fontWeight: FontWeight.w500)),
                ...solution.steps.map((step) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(step)),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                Text('材料：${solution.materials.join('、')}'),
                const Divider(height: 24),
              ];
            }).toList(),
            if (solutions.isNotEmpty) ...[
              const Text(
                '质保说明',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(solutions.first.warranty ?? '质保期2年'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RepairRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateAndPreviewPDF(context, request),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('生成PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (!request.isSynced) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _syncToCloud(context, request),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('同步'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value, RepairRequest request) {
    switch (value) {
      case 'edit':
        // TODO: 编辑功能
        break;
      case 'delete':
        _confirmDelete(context, request);
        break;
    }
  }

  void _confirmDelete(BuildContext context, RepairRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，是否确认？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<RepairProvider>(context, listen: false);
              final success = await provider.deleteRequest(request.id);
              if (success && context.mounted) {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回列表
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndPreviewPDF(BuildContext context, RepairRequest request) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在生成PDF...'),
          ],
        ),
      ),
    );

    try {
      final filePath = await PDFService.generateRepairReport(request);
      if (context.mounted) {
        Navigator.pop(context);
        
        // 分享PDF
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '${request.projectName ?? "维修方案"} - 玻璃幕墙维修报告',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成PDF失败: $e')),
        );
      }
    }
  }

  void _shareReport(BuildContext context, RepairRequest request) {
    _generateAndPreviewPDF(context, request);
  }

  void _printReport(BuildContext context, RepairRequest request) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在准备打印...'),
          ],
        ),
      ),
    );

    try {
      final filePath = await PDFService.generateRepairReport(request);
      if (context.mounted) {
        Navigator.pop(context);
        await PDFService.printPDF(filePath);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打印失败: $e')),
        );
      }
    }
  }

  void _syncToCloud(BuildContext context, RepairRequest request) async {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在同步...'),
          ],
        ),
      ),
    );

    final success = await provider.syncToCloud(request.id);

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
