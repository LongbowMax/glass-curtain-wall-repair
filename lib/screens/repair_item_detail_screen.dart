import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/repair_type.dart';
import '../models/price_config.dart';
import '../providers/repair_provider.dart';

class RepairItemDetailScreen extends StatefulWidget {
  final RepairType repairType;

  const RepairItemDetailScreen({super.key, required this.repairType});

  @override
  State<RepairItemDetailScreen> createState() => _RepairItemDetailScreenState();
}

class _RepairItemDetailScreenState extends State<RepairItemDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  
  // 参数值
  Map<String, dynamic> _parameters = {};
  String _heightLevel = 'ground';
  double _customPrice = 0;
  bool _useCustomPrice = false;

  @override
  void initState() {
    super.initState();
    _customPrice = widget.repairType.basePrice;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.repairType;

    return Scaffold(
      appBar: AppBar(
        title: Text(type.name),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本信息卡片
            _buildInfoCard(type),
            const SizedBox(height: 16),
            
            // 参数录入
            _buildSectionTitle('维修参数'),
            ..._buildParameterFields(type),
            const SizedBox(height: 16),
            
            // 高度等级选择
            _buildHeightLevelSelector(),
            const SizedBox(height: 16),
            
            // 数量
            _buildQuantityField(),
            const SizedBox(height: 16),
            
            // 自定义单价
            _buildCustomPriceField(),
            const SizedBox(height: 16),
            
            // 备注
            _buildNotesField(),
            const SizedBox(height: 24),
            
            // 费用预估
            _buildCostPreview(),
            const SizedBox(height: 32),
            
            // 确认按钮
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('确认添加', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RepairType type) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  type.category.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '编号: ${type.code}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              type.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              '参考单价: ¥${type.basePrice.toStringAsFixed(0)}/${type.unit}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
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

  List<Widget> _buildParameterFields(RepairType type) {
    final fields = <Widget>[];
    
    for (final field in type.requiredInfo) {
      final controller = TextEditingController();
      
      String label;
      String hint;
      TextInputType keyboardType = TextInputType.number;
      String? suffix;
      
      switch (field) {
        case 'seam_length':
          label = '缝隙长度';
          hint = '请输入缝隙长度';
          suffix = '米';
          break;
        case 'seam_width':
          label = '缝隙宽度';
          hint = '请输入缝隙宽度';
          suffix = 'mm';
          break;
        case 'glass_area':
          label = '玻璃面积';
          hint = '请输入玻璃面积';
          suffix = '㎡';
          break;
        case 'glass_thickness':
          label = '玻璃厚度';
          hint = '请输入玻璃厚度';
          suffix = 'mm';
          break;
        case 'strip_length':
          label = '胶条长度';
          hint = '请输入胶条长度';
          suffix = '米';
          break;
        case 'frame_length':
          label = '框架长度';
          hint = '请输入框架长度';
          suffix = '米';
          break;
        case 'sash_size':
          label = '窗扇尺寸';
          hint = '如：1200×1500';
          keyboardType = TextInputType.text;
          break;
        case 'drain_count':
          label = '排水孔数量';
          hint = '请输入数量';
          suffix = '个';
          break;
        default:
          label = field;
          hint = '请输入$field';
      }
      
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _parameters[field] = value;
            },
          ),
        ),
      );
    }
    
    return fields;
  }

  Widget _buildHeightLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '作业高度 *',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ShanghaiPriceConfig.heightLevelOptions.map((option) {
            final isSelected = _heightLevel == option['value'];
            return ChoiceChip(
              label: Text(option['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _heightLevel = option['value']!;
                  });
                }
              },
              selectedColor: Colors.blue.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '数量 *',
              hintText: '请输入数量',
              suffixText: widget.repairType.unit,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入数量';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return '请输入有效数量';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        // 快速加减按钮
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                final current = int.tryParse(_quantityController.text) ?? 1;
                _quantityController.text = (current + 1).toString();
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.orange),
              onPressed: () {
                final current = int.tryParse(_quantityController.text) ?? 1;
                if (current > 1) {
                  _quantityController.text = (current - 1).toString();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _useCustomPrice,
              onChanged: (value) {
                setState(() {
                  _useCustomPrice = value ?? false;
                });
              },
            ),
            const Text('使用自定义单价'),
          ],
        ),
        if (_useCustomPrice)
          TextFormField(
            initialValue: _customPrice.toStringAsFixed(2),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '自定义单价',
              prefixText: '¥',
              suffixText: '/${widget.repairType.unit}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _customPrice = double.tryParse(value) ?? _customPrice;
              });
            },
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: '备注说明',
        hintText: '请输入其他备注信息...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCostPreview() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final unitPrice = _useCustomPrice ? _customPrice : widget.repairType.basePrice;
    final heightFactor = ShanghaiPriceConfig.getHeightFactor(_heightLevel);
    final subtotal = unitPrice * quantity * heightFactor;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '费用预估',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCostRow('单价', '¥${unitPrice.toStringAsFixed(2)}'),
            _buildCostRow('数量', '$quantity ${widget.repairType.unit}'),
            _buildCostRow('难度系数', '× $heightFactor'),
            const Divider(),
            _buildCostRow(
              '小计',
              '¥${subtotal.toStringAsFixed(2)}',
              isBold: true,
              valueColor: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text);
    final heightFactor = ShanghaiPriceConfig.getHeightFactor(_heightLevel);

    final provider = Provider.of<RepairProvider>(context, listen: false);
    provider.addRepairItem(
      widget.repairType.id,
      {
        ..._parameters,
        'height_level': _heightLevel,
      },
      quantity: quantity,
      difficultyFactor: heightFactor,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    // 返回到选择类型页面的上一级（新建需求页面）
    // pop两次：RepairItemDetailScreen → SelectRepairTypeScreen → NewRequestScreen
    Navigator.pop(context); // 回到 SelectRepairTypeScreen
    Navigator.pop(context); // 回到 NewRequestScreen
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已添加：${widget.repairType.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
