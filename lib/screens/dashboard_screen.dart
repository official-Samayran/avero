import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';
import '../widgets.dart';
import '../models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _currentLevel = 5;
  final double _levelProgress = 0.65;
  final int _streakDays = 12;

  final BossBattle _currentBoss = BossBattle(
    id: '1',
    name: 'PROCRASTINATION DEMON',
    maxHealth: 10000,
    currentHealth: 6400,
    rewardXP: 500,
  );

  final Map<String, double> _skillsProgress = {
    'CODING': 0.8,
    'READING': 0.4,
    'WORKOUT': 0.6,
    'DEEP WORK': 0.9,
  };
  
  final List<String> _mockFriends = [
    'NINJA', 'ZACH', 'SAM', 'ALICE', 'GHOST'
  ];

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedCard(
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // DP and Basic Info
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        border: Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 3),
                        shape: BoxShape.rectangle, // Brutalist square avatar
                      ),
                      child: Icon(Icons.person, size: 50, color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ALEX //", style: getThemeTextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          Text("FOCUS NINJA", style: getThemeTextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text("Determined to conquer the focus league and defeat the procrastination demons.", style: getThemeTextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Socials
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialIcon(CupertinoIcons.device_laptop), // e.g. Github
                    _buildSocialIcon(CupertinoIcons.camera_fill),     // e.g. Insta
                    _buildSocialIcon(CupertinoIcons.app_badge_fill),  // e.g. Twitter
                    _buildSocialIcon(CupertinoIcons.link),            // e.g. Website
                  ],
                ),
                const SizedBox(height: 24),
                // Stories / Friends
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("SESSIONS //", style: getThemeTextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mockFriends.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: index == 0 ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                          border: Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _mockFriends[index].substring(0, 1), 
                            style: getThemeTextStyle(fontWeight: FontWeight.w900, color: index == 0 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 2),
      ),
      child: Icon(icon, size: 24, color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }

  Widget _buildStatsAndRPG() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: 24),
        // Boss Battle Section
        ThemedCard(
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT BOSS //',
                      style: getThemeTextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentBoss.name,
                  style: getThemeTextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("HP", style: getThemeTextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    Text("${_currentBoss.currentHealth} / ${_currentBoss.maxHealth}", style: getThemeTextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentBoss.currentHealth / _currentBoss.maxHealth,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  minHeight: 16,
                ),
                const SizedBox(height: 12),
                Text("REWARD: +${_currentBoss.rewardXP} XP", style: getThemeTextStyle(color: Colors.green, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // RPG SKILL TREE
        ThemedCard(
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'RPG SKILL TREE //',
                  style: getThemeTextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 16),
                ..._skillsProgress.entries.map((skill) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(skill.key, style: getThemeTextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            Text("LVL ${(skill.value * 10).toInt() + 1}", style: getThemeTextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: skill.value,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            skill.key == 'CODING' ? Colors.blueAccent :
                            skill.key == 'READING' ? Colors.purpleAccent :
                            skill.key == 'WORKOUT' ? Colors.orangeAccent : Colors.tealAccent
                          ),
                          minHeight: 10,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE', style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatsAndRPG(),
                ],
              ),
            );
          } else {
            // Landscape mode
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProfileHeader()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildStatsAndRPG()),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
