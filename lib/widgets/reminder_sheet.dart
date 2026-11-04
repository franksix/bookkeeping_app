import 'package:flutter/material.dart';

import '../services/reminder_service.dart';

class ReminderSheet extends StatefulWidget {
  const ReminderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const ReminderSheet(),
    );
  }

  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  late bool _enabled;
  late TimeOfDay _time;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final s = ReminderService.instance;
    _enabled = s.enabled;
    _time = TimeOfDay(hour: s.hour, minute: s.minute);
  }

  Future<void> _onToggle(bool v) async {
    if (_busy) return;
    setState(() => _busy = true);
    final s = ReminderService.instance;

    if (v) {
      final granted = await s.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('没有通知权限，请到系统设置中允许通知')),
          );
          setState(() => _busy = false);
        }
        return;
      }
      await s.enable(hour: _time.hour, minute: _time.minute);
      if (mounted) {
        setState(() {
          _enabled = true;
          _busy = false;
        });
      }
    } else {
      await s.disable();
      if (mounted) {
        setState(() {
          _enabled = false;
          _busy = false;
        });
      }
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
    // 已开启时改时间立即生效
    if (_enabled) {
      await ReminderService.instance
          .enable(hour: picked.hour, minute: picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('每日记账提醒', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '到点会推送一条通知，提醒你记下当天的账。',
              style: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('开启提醒'),
              value: _enabled,
              onChanged: _busy ? null : _onToggle,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: _enabled,
              leading: const Icon(Icons.schedule),
              title: const Text('提醒时间'),
              trailing: Text(
                _time.format(context),
                style: const TextStyle(fontSize: 16),
              ),
              onTap: _enabled ? _pickTime : null,
            ),
          ],
        ),
      ),
    );
  }
}