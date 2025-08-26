import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

/// 简洁的电池电量显示组件
class BatteryIndicator extends StatefulWidget {
  const BatteryIndicator({super.key});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  final Battery _battery = Battery();
  Timer? _batteryUpdateTimer;

  // 电池状态缓存
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;

  @override
  void initState() {
    super.initState();
    _initBatteryStatus();
    _batteryUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateBatteryStatus(),
    );
  }

  @override
  void dispose() {
    _batteryUpdateTimer?.cancel();
    super.dispose();
  }

  // 初始化电池状态
  void _initBatteryStatus() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _batteryState = state;
        });
      }
    } catch (e) {
      // 获取失败时使用默认值
      if (mounted) {
        setState(() {
          _batteryLevel = 100;
          _batteryState = BatteryState.unknown;
        });
      }
    }
  }

  // 更新电池状态
  void _updateBatteryStatus() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    if (mounted && (level != _batteryLevel || state != _batteryState)) {
      setState(() {
        _batteryLevel = level;
        _batteryState = state;
      });
    }
  }

  // 获取电池图标
  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) {
      return Icons.battery_charging_full;
    }
    if (_batteryLevel >= 90) return Icons.battery_full;
    if (_batteryLevel >= 75) return Icons.battery_6_bar;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 45) return Icons.battery_4_bar;
    if (_batteryLevel >= 30) return Icons.battery_3_bar;
    if (_batteryLevel >= 15) return Icons.battery_2_bar;
    if (_batteryLevel >= 5) return Icons.battery_1_bar;
    return Icons.battery_0_bar;
  }

  // 获取电池颜色
  Color _getBatteryColor() {
    if (_batteryState == BatteryState.charging) {
      return Colors.green;
    }
    if (_batteryLevel <= 15) return Colors.red;
    if (_batteryLevel <= 30) return Colors.orange;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getBatteryIcon(), color: _getBatteryColor(), size: 20),
        Text(
          '$_batteryLevel%',
          style: TextStyle(
            color: _getBatteryColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
