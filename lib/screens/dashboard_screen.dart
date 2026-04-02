import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // In a real app these come from global state
  final int _currentLevel = 5;
  final double _levelProgress = 0.65;
  final int _streakDays = 12;

  // Mock missions
  final List<Map<String, dynamic>> _missions = [
    {'title': 'FOCUS FOR 30 MINS', 'completed': true, 'progress': '30/30 m'},
    {'title': 'COMPLETE 2 SESSIONS', 'completed': false, 'progress': '1/2 s'},
    {'title': 'EARN 500 XP', 'completed': false, 'progress': '200/500 x'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASHBOARD', style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ThemedCard(
                    backgroundColor: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("LVL $_currentLevel", style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _levelProgress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                            minHeight: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ThemedCard(
                    backgroundColor: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("STREAK", style: getThemeTextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          Text("$_streakDays", style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: const Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ThemedCard(
              backgroundColor: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'DAILY BOARD //',
                      style: getThemeTextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 16),
                    ..._missions.map((mission) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mission['completed'] ? Colors.green.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: mission['completed'] ? Colors.green : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mission['title'],
                              style: getThemeTextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              mission['completed'] ? 'DONE' : mission['progress'],
                              style: getThemeTextStyle(
                                color: mission['completed'] ? Colors.green : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
