import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/repair_type.dart';
import 'repair_item_detail_screen.dart';

class SelectRepairTypeScreen extends StatefulWidget {
  const SelectRepairTypeScreen({super.key});

  @override
  State<SelectRepairTypeScreen> createState() => _SelectRepairTypeScreenState();
}

class _SelectRepairTypeScreenState extends State<SelectRepairTypeScreen> {
  RepairCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredTypes = _getFilteredTypes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择维修类型'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索维修类型...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // 分类筛选
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip(null, '全部'),
                    ...RepairCategory.values.map((cat) => _buildCategoryChip(cat, cat.displayName)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTypes.length,
        itemBuilder: (context, index) {
          final type = filteredTypes[index];
          return _buildTypeCard(type);
        },
      ),
    );
  }

  List<RepairType> _getFilteredTypes() {
    var types = RepairTypeDatabase.allTypes;
    
    if (_selectedCategory != null) {
      types = types.where((t) => t.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      types = types.where((t) =>
        t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.code.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return types;
  }

  Widget _buildCategoryChip(RepairCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildTypeCard(RepairType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectType(type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    type.category.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '编号: ${type.code}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      '¥${type.basePrice.toStringAsFixed(0)}/${type.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                type.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: type.materials.take(3).map((material) {
                  return Chip(
                    label: Text(
                      material,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.grey.shade100,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectType(RepairType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairItemDetailScreen(repairType: type),
      ),
    );
  }
}
