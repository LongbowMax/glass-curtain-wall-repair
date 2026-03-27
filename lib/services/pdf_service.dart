import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/repair_request.dart';
import '../models/repair_type.dart';

class PDFService {
  static Future<String> generateRepairReport(RepairRequest request) async {
    final pdf = pw.Document();
    
    // 加载中文字体
    final fontData = await rootBundle.load('assets/fonts/NotoSansSC-Regular.otf');
    final boldFontData = await rootBundle.load('assets/fonts/NotoSansSC-Bold.otf');
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    final budget = request.calculateBudget();
    final solutions = request.items.map((item) {
      final type = item.repairType ?? RepairTypeDatabase.getById(item.repairTypeId);
      return type != null ? RepairSolution.fromRepairType(type) : null;
    }).whereType<RepairSolution>().toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context, ttf, boldTtf),
        footer: (context) => _buildFooter(context, ttf),
        build: (context) => [
          _buildTitle(ttf, boldTtf),
          pw.SizedBox(height: 20),
          _buildBasicInfo(request, ttf, boldTtf),
          pw.SizedBox(height: 20),
          _buildRepairItems(request, ttf, boldTtf),
          pw.SizedBox(height: 20),
          _buildBudgetTable(budget, ttf, boldTtf),
          pw.SizedBox(height: 20),
          _buildSolutions(solutions, ttf, boldTtf),
          pw.SizedBox(height: 20),
          _buildNotes(ttf, boldTtf),
          pw.SizedBox(height: 30),
          _buildSignatureSection(ttf, boldTtf),
        ],
      ),
    );

    // 保存文件
    final output = await getTemporaryDirectory();
    final fileName = '维修方案_${request.projectName ?? "未命名"}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  static pw.Widget _buildHeader(pw.Context context, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        '第 ${context.pageNumber} 页 / 共 ${context.pagesCount} 页',
        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        '玻璃幕墙维修专家 - 专业幕墙维修方案提供商',
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }

  static pw.Widget _buildTitle(pw.Font font, pw.Font boldFont) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            '玻璃幕墙维修方案',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'REPAIR PROPOSAL FOR CURTAIN WALL',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBasicInfo(RepairRequest request, pw.Font font, pw.Font boldFont) {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '一、基本信息',
            style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('项目名称：', request.projectName ?? '-', font, boldFont),
          _buildInfoRow('楼栋名称：', request.buildingName ?? '-', font, boldFont),
          _buildInfoRow('业主姓名：', request.ownerName ?? '-', font, boldFont),
          _buildInfoRow('联系电话：', request.ownerPhone ?? '-', font, boldFont),
          _buildInfoRow('业主单位：', request.ownerUnit ?? '-', font, boldFont),
          _buildInfoRow('详细地址：', request.address ?? '-', font, boldFont),
          _buildInfoRow('勘查日期：', request.inspectionDate != null 
              ? dateFormat.format(request.inspectionDate!) 
              : '-', font, boldFont),
          _buildInfoRow('编制日期：', dateFormat.format(request.createdAt), font, boldFont),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(font: boldFont, fontSize: 11)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRepairItems(RepairRequest request, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '二、维修项目清单',
          style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(0.8),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            // 表头
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('序号', boldFont, isHeader: true),
                _buildTableCell('维修项目', boldFont, isHeader: true),
                _buildTableCell('单位', boldFont, isHeader: true),
                _buildTableCell('数量', boldFont, isHeader: true),
                _buildTableCell('备注', boldFont, isHeader: true),
              ],
            ),
            // 数据行
            ...request.items.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              final type = item.repairType ?? RepairTypeDatabase.getById(item.repairTypeId);
              
              return pw.TableRow(
                children: [
                  _buildTableCell('$index', font, align: pw.TextAlign.center),
                  _buildTableCell(type?.name ?? '未知项目', font),
                  _buildTableCell(type?.unit ?? '-', font, align: pw.TextAlign.center),
                  _buildTableCell('${item.quantity}', font, align: pw.TextAlign.center),
                  _buildTableCell(item.notes ?? '-', font),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildBudgetTable(BudgetSummary budget, pw.Font font, pw.Font boldFont) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '三、维修预算',
          style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            _buildBudgetRow('材料费', budget.materialCost, font, boldFont),
            _buildBudgetRow('人工费', budget.laborCost, font, boldFont),
            _buildBudgetRow('设备费', budget.equipmentCost, font, boldFont),
            _buildBudgetRow('措施费', budget.measureCost, font, boldFont),
            _buildBudgetRow('管理费（5%）', budget.managementCost, font, boldFont),
            _buildBudgetRow('利润（8%）', budget.profit, font, boldFont),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('税前小计', boldFont),
                _buildTableCell(currencyFormat.format(budget.subtotalExclTax), font, align: pw.TextAlign.right),
              ],
            ),
            _buildBudgetRow('税金（9%）', budget.tax, font, boldFont),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: [
                _buildTableCell('合计', boldFont, isHeader: true),
                _buildTableCell(
                  currencyFormat.format(budget.total),
                  boldFont,
                  align: pw.TextAlign.right,
                  isHeader: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildBudgetRow(String label, double value, pw.Font font, pw.Font boldFont) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);
    return pw.TableRow(
      children: [
        _buildTableCell(label, font),
        _buildTableCell(currencyFormat.format(value), font, align: pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _buildSolutions(List<RepairSolution> solutions, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '四、维修方案',
          style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        ...solutions.asMap().entries.expand((entry) {
          final index = entry.key + 1;
          final solution = entry.value;
          return [
            pw.Text(
              '$index. ${solution.title}',
              style: pw.TextStyle(font: boldFont, fontSize: 12),
            ),
            pw.SizedBox(height: 5),
            pw.Text('施工步骤：', style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ...solution.steps.map((step) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, top: 2),
              child: pw.Text('• $step', style: pw.TextStyle(font: font, fontSize: 10)),
            )),
            pw.SizedBox(height: 5),
            pw.Text('所需材料：', style: pw.TextStyle(font: boldFont, fontSize: 10)),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                solution.materials.join('、'),
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 10),
          ];
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildNotes(pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '五、注意事项',
          style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '1. 本报价有效期为30天，逾期需重新核算。',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '2. 施工期间如遇恶劣天气等不可抗力因素，工期相应顺延。',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '3. 本预算为预估价格，实际费用以最终结算为准。',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '4. 质保期：自验收合格之日起2年。',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '5. 付款方式：合同签订后预付50%，竣工验收合格后支付50%。',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatureSection(pw.Font font, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('编制单位：_________________', style: pw.TextStyle(font: font, fontSize: 11)),
            pw.SizedBox(height: 15),
            pw.Text('编 制 人：_________________', style: pw.TextStyle(font: font, fontSize: 11)),
            pw.SizedBox(height: 15),
            pw.Text('日    期：_________________', style: pw.TextStyle(font: font, fontSize: 11)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('业主确认：_________________', style: pw.TextStyle(font: font, fontSize: 11)),
            pw.SizedBox(height: 15),
            pw.Text('签    字：_________________', style: pw.TextStyle(font: font, fontSize: 11)),
            pw.SizedBox(height: 15),
            pw.Text('日    期：_________________', style: pw.TextStyle(font: font, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  // 打印PDF
  static Future<void> printPDF(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  // 分享PDF
  static Future<void> sharePDF(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    await Printing.sharePdf(
      bytes: bytes,
      filename: file.path.split('/').last,
    );
  }
}
