import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 通用工具类
class Helpers {
  /// 格式化金额
  static String formatCurrency(double amount, {String symbol = '¥'}) {
    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// 格式化金额（简化版，无小数）
  static String formatCurrencySimple(double amount, {String symbol = '¥'}) {
    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// 格式化日期
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    final formatter = DateFormat(pattern, 'zh_CN');
    return formatter.format(date);
  }

  /// 格式化日期时间
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm', 'zh_CN');
    return formatter.format(date);
  }

  /// 格式化数字（添加千分位）
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###.##', 'zh_CN');
    return formatter.format(number);
  }

  /// 验证手机号
  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^1[3-9]\d{9}$');
    return regex.hasMatch(phone);
  }

  /// 验证邮箱
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// 显示提示消息
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示确认对话框
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示加载对话框
  static void showLoadingDialog(BuildContext context, {String message = '加载中...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 获取文件大小字符串
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 截断文本
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + suffix;
  }

  /// 生成唯一ID（简化版）
  static String generateId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${now.microsecond}';
  }
}

/// 扩展方法
extension DateTimeExtension on DateTime {
  /// 格式化为本地日期字符串
  String toLocalString() {
    return Helpers.formatDate(this);
  }

  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension StringExtension on String {
  /// 是否为空或空白
  bool get isBlank => trim().isEmpty;

  /// 是否不为空且不为空白
  bool get isNotBlank => !isBlank;
}

extension DoubleExtension on double {
  /// 格式化为货币
  String toCurrency({String symbol = '¥'}) {
    return Helpers.formatCurrency(this, symbol: symbol);
  }
}
