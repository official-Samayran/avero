import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  final List<LeagueUser> _mockLeaderboard = [
    LeagueUser(id: '1', name: 'NINJA_STUDENT', xp: 12500),
    LeagueUser(id: '2', name: 'CAFFEINE_GHOST', xp: 11200),
    LeagueUser(id: '3', name: 'YOU', xp: 9850, isCurrentUser: true),
    LeagueUser(id: '4', name: 'POMODORO_GOD', xp: 8400),
    LeagueUser(id: '5', name: 'PROCRASTINATOR_99', xp: 3200),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LEAGUE', style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThemedCard(
              backgroundColor: const Color(0xFF1E3A8A), // Deep blue for emphasis
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text('GOLD LEAGUE', style: getThemeTextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text('Ends in 2d 14h', style: getThemeTextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _mockLeaderboard.length,
                itemBuilder: (context, index) {
                  final user = _mockLeaderboard[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ThemedCard(
                      backgroundColor: user.isCurrentUser ? const Color(0xFF10B981) : Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              '#${index + 1}',
                              style: getThemeTextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.w900, 
                                color: user.isCurrentUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5)
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Text(
                                user.name,
                                style: getThemeTextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: user.isCurrentUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color
                                ),
                              ),
                            ),
                            Text(
                              '${user.xp} XP',
                              style: getThemeTextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.w900, 
                                color: user.isCurrentUser ? Colors.white : Theme.of(context).primaryColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
