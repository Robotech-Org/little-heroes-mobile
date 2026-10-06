import 'package:flutter/material.dart';

class QuietHoursSection extends StatelessWidget {
  final bool enabled;
  final String start; // "HH:MM:SS"
  final String end;
  final void Function(bool enabled, String start, String end) onChange;

  const QuietHoursSection({
    super.key,
    required this.enabled,
    required this.start,
    required this.end,
    required this.onChange,
  });

  TimeOfDay _parse(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 18, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 18,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pick(BuildContext ctx, {required bool isStart}) async {
    final initial = _parse(isStart ? start : end);
    final picked = await showTimePicker(context: ctx, initialTime: initial);
    if (picked == null) return;
    onChange(
      enabled,
      isStart ? _fmt(picked) : start,
      isStart ? end : _fmt(picked),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: enabled,
            onChanged: (v) => onChange(v, start, end),
            secondary: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
              child: Icon(
                Icons.do_not_disturb_on_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            title: const Text(
              'Do Not Disturb',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Silence non-critical alerts'),
          ),
          if (enabled) ...[
            const Divider(height: 1, indent: 72),
            ListTile(
              enabled: enabled,
              onTap: () => _pick(context, isStart: true),
              leading: const SizedBox(width: 40),
              title: const Text('Starts at'),
              trailing: Text(
                start.substring(0, 5),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              enabled: enabled,
              onTap: () => _pick(context, isStart: false),
              leading: const SizedBox(width: 40),
              title: const Text('Ends at'),
              trailing: Text(
                end.substring(0, 5),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
