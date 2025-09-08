///@Author Ligg
///@Time 2025/9/8
library;
import 'package:flutter/material.dart';

/// 下拉菜单
class DropdownMenuItemData {
  final String value;
  final Widget child;
  final IconData? icon;
  final String? text;

  DropdownMenuItemData({
    required this.value,
    required this.child,
    this.icon,
    this.text,
  });
}

/// 显示下拉菜单
class ReusableDropdownMenu {
  static Future<T?> show<T>({
    required BuildContext context,
    required GlobalKey buttonKey,
    required List<DropdownMenuItemData> items,
    Color? iconColor,
  }) async {
    final RenderBox? button =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    if (button == null) return null;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    return showMenu<T>(
      context: context,
      position: position,
      items: items.map((item) {
        return PopupMenuItem<T>(value: item.value as T, child: item.child);
      }).toList(),
    );
  }

  /// 带图标的菜单项
  static DropdownMenuItemData createIconItem({
    required String value,
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return DropdownMenuItemData(
      value: value,
      icon: icon,
      text: text,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
