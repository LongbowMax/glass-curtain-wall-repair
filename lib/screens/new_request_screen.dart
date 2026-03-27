import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/repair_provider.dart';
import '../models/repair_request.dart';
import 'select_repair_type_screen.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerUnitController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _inspectionDate;

  @override
  void initState() {
    super.initState();
    // 如果已有数据，填充表单
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RepairProvider>(context, listen: false);
      final request = provider.currentRequest;
      if (request != null) {
        _projectNameController.text = request.projectName ?? '';
        _buildingNameController.text = request.buildingName ?? '';
        _ownerNameController.text = request.ownerName ?? '';
        _ownerPhoneController.text = request.ownerPhone ?? '';
        _ownerUnitController.text = request.ownerUnit ?? '';
        _addressController.text = request.address ?? '';
        _inspectionDate = request.inspectionDate;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _buildingNameController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerUnitController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RepairProvider>(context);
    final request = provider.currentRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('新建维修需求'),
        actions: [
          TextButton(
            onPressed: _saveAndNext,
            child: const Text(
              '下一步',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('项目信息'),
            _buildTextField(
              controller: _projectNameController,
              label: '项目名称',
              hint: '请输入项目名称',
              icon: Icons.business,
              isRequired: true,
            ),
            _buildTextField(
              controller: _buildingNameController,
              label: '楼栋名称',
              hint: '如：A座、1号楼等',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            
            _buildSectionTitle('业主信息'),
            _buildTextField(
              controller: _ownerNameController,
              label: '业主姓名',
              hint: '请输入业主姓名',
              icon: Icons.person,
              isRequired: true,
            ),
            _buildTextField(
              controller: _ownerPhoneController,
              label: '联系电话',
              hint: '请输入联系电话',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
            _buildTextField(
              controller: _ownerUnitController,
              label: '业主单位',
              hint: '请输入业主单位名称',
              icon: Icons.apartment,
            ),
            _buildTextField(
              controller: _addressController,
              label: '详细地址',
              hint: '请输入项目详细地址',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            _buildSectionTitle('勘查信息'),
            _buildDatePicker(),
            const SizedBox(height: 32),
            
            // 预览当前维修项目
            if (request != null && request.items.isNotEmpty) ...[
              _buildSectionTitle('已添加维修项目 (${request.items.length})'),
              ...request.items.asMap().entries.map((entry) {
                return _buildItemPreview(entry.value);
              }),
              const SizedBox(height: 16),
            ],
            
            // 添加维修项目按钮
            OutlinedButton.icon(
              onPressed: _addRepairItem,
              icon: const Icon(Icons.add),
              label: const Text('添加维修项目'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '请输入$label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '勘查日期',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _inspectionDate != null
              ? DateFormat('yyyy年MM月dd日').format(_inspectionDate!)
              : '请选择勘查日期',
          style: TextStyle(
            color: _inspectionDate != null
                ? Colors.black87
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildItemPreview(item) {
    final type = item.repairType;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(type?.category.icon ?? '🔧'),
        ),
        title: Text(type?.name ?? '未知项目'),
        subtitle: Text('数量: ${item.quantity} ${type?.unit ?? "项"}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _removeItem(item.id),
        ),
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _inspectionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _inspectionDate = picked;
      });
    }
  }

  void _addRepairItem() {
    _saveCurrentData();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectRepairTypeScreen()),
    );
  }

  void _removeItem(String itemId) {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    provider.removeRepairItem(itemId);
  }

  void _saveCurrentData() {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    provider.updateRequestInfo(
      projectName: _projectNameController.text.trim(),
      buildingName: _buildingNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      ownerPhone: _ownerPhoneController.text.trim(),
      ownerUnit: _ownerUnitController.text.trim(),
      address: _addressController.text.trim(),
      inspectionDate: _inspectionDate,
    );
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;
    
    _saveCurrentData();
    
    final provider = Provider.of<RepairProvider>(context, listen: false);
    if (provider.currentRequest?.items.isEmpty ?? true) {
      // 如果没有添加维修项目，先跳到选择类型页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SelectRepairTypeScreen()),
      );
    } else {
      // 保存并返回首页
      _saveAndFinish();
    }
  }

  void _saveAndFinish() async {
    final provider = Provider.of<RepairProvider>(context, listen: false);
    final success = await provider.saveRequest();
    
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${provider.error}')),
        );
      }
    }
  }
}
