import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      soundEnabled = prefs.getBool('sound_enabled') ?? true;
      final hour = prefs.getInt('reminder_hour') ?? 19;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      await NotificationService().scheduleDailyReminder(
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    } else {
      await NotificationService().cancelDailyReminder();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: reminderTime);
    if (picked != null) {
      setState(() => reminderTime = picked);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);

      if (notificationsEnabled) {
        await NotificationService().scheduleDailyReminder(hour: picked.hour, minute: picked.minute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            secondary: Icon(themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            title: const Text('Dark Mode'),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get reminded to practice'),
            value: notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          if (notificationsEnabled)
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('Reminder Time'),
              subtitle: Text(reminderTime.format(context)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: _pickTime,
            ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Sound Effects'),
            value: soundEnabled,
            onChanged: (val) async {
              setState(() => soundEnabled = val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('sound_enabled', val);
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text('This action cannot be undone. All your progress will be lost.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}