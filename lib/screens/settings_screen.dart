import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../theme.dart';
import '../widgets.dart';
import '../services/app_blocker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<AppInfo> _installedApps = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  void _loadApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(excludeSystemApps: true, withIcon: true);
      setState(() {
        _installedApps = apps;
        _isLoadingApps = false;
      });
    } catch (e) {
      debugPrint("Could not fetch apps: $e");
      setState(() {
        _isLoadingApps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SHIELD & TUNING', style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('AESTHETICS', style: getThemeTextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AveroThemeStyle.values.map((style) {
                return GestureDetector(
                  onTap: () async {
                    appThemeNotifier.value = style;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('saved_theme_style', style.index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: appThemeNotifier.value == style ? Colors.blue : Colors.transparent, width: 3),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: ThemedCard(
                      backgroundColor: appThemeNotifier.value == style ? Colors.blue.withOpacity(0.1) : Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          style.name.toUpperCase(),
                          style: getThemeTextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text('APP DISTRACTION BLOCKER', style: getThemeTextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 8),
            Text('When the timer is running, opening these apps will crash your session.', style: getThemeTextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            _isLoadingApps
                ? const Center(child: CircularProgressIndicator())
                : _installedApps.isEmpty 
                  ? Text("No apps found or unsupported platform.", style: getThemeTextStyle())
                  : ThemedCard(
                      backgroundColor: Theme.of(context).cardColor,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _installedApps.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.grey.withOpacity(0.2)),
                        itemBuilder: (context, index) {
                          final app = _installedApps[index];
                          final isBlocked = AppBlockerService().blockedPackages.contains(app.packageName);
                          
                          return CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: Text(app.name ?? "Unknown", style: getThemeTextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(app.packageName ?? "", style: getThemeTextStyle(fontSize: 10)),
                            secondary: app.icon != null ? Image.memory(app.icon!, width: 40, height: 40) : const Icon(Icons.android),
                            value: isBlocked,
                            activeColor: Colors.redAccent,
                            onChanged: (val) {
                              setState(() {
                                AppBlockerService().toggleBlock(app.packageName!);
                              });
                            },
                          );
                        },
                      ),
                    ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
