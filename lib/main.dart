import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class DailyMission {
  final String id;
  final String title;
  final int target;
  final int reward;
  final bool isHard;
  bool completed;

  DailyMission({
    required this.id,
    required this.title,
    required this.target,
    required this.reward,
    this.isHard = false,
    this.completed = false,
  });
}

class SessionHistoryEntry {
  final DateTime timestamp;
  final int durationMinutes;
  final int xp;
  final bool success;

  SessionHistoryEntry({
    required this.timestamp,
    required this.durationMinutes,
    required this.xp,
    required this.success,
  });

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SessionHistoryEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMinutes: json['durationMinutes'] as int,
      xp: json['xp'] as int,
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'durationMinutes': durationMinutes,
      'xp': xp,
      'success': success,
    };
  }
}

const List<String> _motivationalLines = [
  "Others scroll. I level up.",
  "Discipline > Dopamine",
  "Focus beats distraction.",
  "Grind now, glow later.",
  "Consistency creates champions.",
  "One session at a time.",
  "Mindset over mood.",
  "Progress over perfection.",
  "Stay locked in.",
  "Build the habit.",
];

class StoryWidget extends StatelessWidget {
  final int minutes;
  final int xp;
  final int level;
  final int streak;

  const StoryWidget({
    super.key,
    required this.minutes,
    required this.xp,
    required this.level,
    required this.streak,
  });

  String get _formattedTime {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m locked in';
    } else {
      return '${mins}m locked in';
    }
  }

  String get _randomMotivationalLine {
    return _motivationalLines[Random().nextInt(_motivationalLines.length)];
  }

  bool get _highlightTime => minutes > xp; // Simple comparison

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: _highlightTime ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '+$xp XP',
                    style: TextStyle(
                      fontSize: !_highlightTime ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Day $streak streak',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _randomMotivationalLine,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: const Text(
                'Avero',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const AveroApp());
}

class AveroApp extends StatelessWidget {
  const AveroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.red,
        ),
      ),
      home: const AveroHome(),
    );
  }
}

class StoryScreen extends StatefulWidget {
  final int minutes;
  final int xp;
  final int level;
  final int streak;

  const StoryScreen({
    super.key,
    required this.minutes,
    required this.xp,
    required this.level,
    required this.streak,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareStory() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/avero_story.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'Check out my focus session on Avero!');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Story'),
        actions: [
          IconButton(
            onPressed: _shareStory,
            icon: const Icon(Icons.share),
            tooltip: 'Share Story',
          ),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: _screenshotController,
          child: StoryWidget(
            minutes: widget.minutes,
            xp: widget.xp,
            level: widget.level,
            streak: widget.streak,
          ),
        ),
      ),
    );
  }
}

class AveroHome extends StatefulWidget {
  const AveroHome({super.key});

  @override
  State<AveroHome> createState() => _AveroHomeState();
}

class _AveroHomeState extends State<AveroHome> with TickerProviderStateMixin {
  int _seconds = 0;
  int _totalXP = 0;
  int _liveXP = 0;
  double _currentMultiplier = 1.0;
  Timer? _timer;
  bool _isActive = false;

  int _streakDays = 0;
  DateTime? _lastActiveDate;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _finishButtonPressed = false;
  bool _crashButtonPressed = false;
  bool _startButtonPressed = false;

  DateTime? _missionDate;
  int _dailyFocusMinutes = 0;
  int _dailySessionsCompleted = 0;
  int _dailyXpEarned = 0;

  final List<SessionHistoryEntry> _sessionHistory = [];
  static const String _sessionHistoryPrefsKey = 'sessionHistory';
  static const String _totalXpKey = 'totalXP';
  static const String _streakDaysKey = 'streakDays';
  static const String _lastActiveDateKey = 'lastActiveDate';
  static const String _dailyMissionPrefsKey = 'dailyMissionData';

  final List<DailyMission> _dailyMissions = [
    DailyMission(
      id: 'focus30',
      title: 'Focus for 30 minutes',
      target: 30,
      reward: 200,
      isHard: false,
    ),
    DailyMission(
      id: 'sessions2',
      title: 'Complete 2 sessions',
      target: 2,
      reward: 200,
      isHard: false,
    ),
    DailyMission(
      id: 'xp100',
      title: 'Reach 100 XP in a day',
      target: 100,
      reward: 500,
      isHard: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadData() async {
    try {
      await _loadStreakData();
      await _loadMissionData();
      await _loadSessionHistory();

      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _totalXP = prefs.getInt(_totalXpKey) ?? 0;
      });
    } catch (e) {
      // Handle load errors gracefully, use defaults
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_totalXpKey, _totalXP);

      await _saveStreakData();
      await _saveMissionData();
      await _saveSessionHistory();
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> _loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_streakDaysKey) ?? 0;
    final lastDateString = prefs.getString(_lastActiveDateKey);

    setState(() {
      _streakDays = streak;
      _lastActiveDate = lastDateString != null
          ? DateTime.tryParse(lastDateString)
          : null;
    });
  }

  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakDaysKey, _streakDays);
    if (_lastActiveDate != null) {
      await prefs.setString(
        _lastActiveDateKey,
        _lastActiveDate!.toIso8601String(),
      );
    } else {
      await prefs.remove(_lastActiveDateKey);
    }
  }

  Future<void> _loadSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionHistoryPrefsKey);
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      setState(() {
        _sessionHistory
          ..clear()
          ..addAll(
            decoded
                .map(
                  (e) =>
                      SessionHistoryEntry.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );
      });
    } catch (_) {
      _sessionHistory.clear();
      await prefs.remove(_sessionHistoryPrefsKey);
    }
  }

  Future<void> _saveSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _sessionHistory.map((entry) => entry.toJson()).toList(),
    );
    await prefs.setString(_sessionHistoryPrefsKey, encoded);
  }

  Future<void> _loadMissionData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString(_dailyMissionPrefsKey);
    final now = DateTime.now();

    if (savedJson != null) {
      try {
        final decoded = jsonDecode(savedJson) as Map<String, dynamic>;
        final dateString = decoded['missionDate'] as String?;
        final savedDate = dateString != null
            ? DateTime.tryParse(dateString)
            : null;

        if (savedDate != null && _isSameDay(savedDate, now)) {
          _missionDate = savedDate;
          _dailyFocusMinutes = decoded['dailyFocusMinutes'] as int? ?? 0;
          _dailySessionsCompleted =
              decoded['dailySessionsCompleted'] as int? ?? 0;
          _dailyXpEarned = decoded['dailyXpEarned'] as int? ?? 0;

          final missionsDecoded = decoded['missions'];
          if (missionsDecoded is List<dynamic>) {
            final mapById = <String, bool>{};
            for (final item in missionsDecoded) {
              if (item is Map<String, dynamic>) {
                final id = item['id'] as String?;
                final completed = item['completed'] as bool?;
                if (id != null && completed != null) {
                  mapById[id] = completed;
                }
              }
            }
            for (final mission in _dailyMissions) {
              mission.completed = mapById[mission.id] ?? false;
            }
          }
        } else {
          await _resetDailyMissionsForNewDay(now);
        }
      } catch (_) {
        await _resetDailyMissionsForNewDay(now);
      }
    } else {
      await _resetDailyMissionsForNewDay(now);
    }

    setState(() {});
    _checkDailyMissions();
  }

  Future<void> _saveMissionData() async {
    final prefs = await SharedPreferences.getInstance();
    final missionData = {
      'missionDate': _missionDate?.toIso8601String(),
      'dailyFocusMinutes': _dailyFocusMinutes,
      'dailySessionsCompleted': _dailySessionsCompleted,
      'dailyXpEarned': _dailyXpEarned,
      'missions': _dailyMissions
          .map((m) => {'id': m.id, 'completed': m.completed})
          .toList(),
    };

    await prefs.setString(_dailyMissionPrefsKey, jsonEncode(missionData));
  }

  Future<void> _resetDailyMissionsForNewDay(DateTime today) async {
    _missionDate = DateTime(today.year, today.month, today.day);
    _dailyFocusMinutes = 0;
    _dailySessionsCompleted = 0;
    _dailyXpEarned = 0;
    for (final mission in _dailyMissions) {
      mission.completed = false;
    }
    await _saveMissionData();
  }

  Future<void> _checkAndResetDailyMissions() async {
    final now = DateTime.now();
    if (_missionDate == null || !_isSameDay(_missionDate!, now)) {
      await _resetDailyMissionsForNewDay(now);
    }
  }

  Future<void> _addSessionHistory({
    required bool success,
    required int durationMinutes,
    required int xp,
  }) async {
    final entry = SessionHistoryEntry(
      timestamp: DateTime.now(),
      durationMinutes: durationMinutes,
      xp: xp,
      success: success,
    );

    setState(() {
      _sessionHistory.insert(0, entry);
    });
    await _saveData();
  }

  int get _focusProgressToday =>
      _dailyFocusMinutes + (_isActive ? (_seconds / 60).floor() : 0);
  int get _sessionsProgressToday => _dailySessionsCompleted;
  int get _xpProgressToday => _dailyXpEarned + (_isActive ? _liveXP : 0);

  Future<void> _checkDailyMissions() async {
    await _checkAndResetDailyMissions();

    for (final mission in _dailyMissions) {
      final currentProgress = mission.id == 'focus30'
          ? _focusProgressToday
          : mission.id == 'sessions2'
          ? _sessionsProgressToday
          : _xpProgressToday;

      if (!mission.completed && currentProgress >= mission.target) {
        mission.completed = true;
        _totalXP += mission.reward;

        final rewardText = mission.isHard
            ? '+${mission.reward} XP (hard)'
            : '+${mission.reward} XP';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily mission "${mission.title}" complete: $rewardText',
            ),
          ),
        );
      }
    }

    await _saveData();
    setState(() {});
  }

  Future<void> _updateMissionProgressOnSessionComplete(
    int minutes,
    int earnedXP,
  ) async {
    _dailyFocusMinutes += minutes;
    _dailySessionsCompleted += 1;
    _dailyXpEarned += earnedXP;
    await _checkDailyMissions();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isYesterday(DateTime a, DateTime b) {
    final yesterday = DateTime(
      b.year,
      b.month,
      b.day,
    ).subtract(const Duration(days: 1));
    final dateA = DateTime(a.year, a.month, a.day);
    return dateA == yesterday;
  }

  void _startSession() {
    _timer?.cancel();

    setState(() {
      _isActive = true;
      _seconds = 0;
      _liveXP = 0;
      _currentMultiplier = 1.0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds += 1;
        _updateXPValues();
      });
      _checkDailyMissions();
    });
  }

  Future<void> _crashSession() async {
    final minutes = (_seconds / 60).floor();

    _timer?.cancel();

    await _addSessionHistory(success: false, durationMinutes: minutes, xp: 0);

    setState(() {
      _isActive = false;
      _seconds = 0;
      _liveXP = 0;
      _currentMultiplier = 1.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("SESSION CRASHED. NO XP EARNED.")),
    );
  }

  Future<void> _finishSession() async {
    _timer?.cancel();

    int minutes = (_seconds / 60).floor();

    double multiplier = 1;

    if (minutes >= 60) {
      multiplier = 3;
    } else if (minutes >= 25) {
      multiplier = 2;
    } else if (minutes >= 10) {
      multiplier = 1.5;
    }

    int baseXP = minutes * 8;
    int earnedXP = (baseXP * multiplier).toInt();

    await _checkAndResetDailyMissions();
    await _updateMissionProgressOnSessionComplete(minutes, earnedXP);

    final now = DateTime.now();
    bool incrementStreak = false;

    if (_lastActiveDate == null) {
      incrementStreak = true;
    } else if (_isSameDay(_lastActiveDate!, now)) {
      incrementStreak = false;
    } else if (_isYesterday(_lastActiveDate!, now)) {
      incrementStreak = true;
    } else {
      incrementStreak = false;
    }

    if (incrementStreak) {
      _streakDays += 1;
    }
    _lastActiveDate = now;
    await _saveStreakData();

    if (!mounted) return;

    setState(() {
      _totalXP += earnedXP;
      _isActive = false;
      _seconds = 0;
      _liveXP = 0;
      _currentMultiplier = 1.0;
    });

    await _addSessionHistory(
      success: true,
      durationMinutes: minutes,
      xp: earnedXP,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("SESSION COMPLETE +$earnedXP XP (x$multiplier)")),
    );

    // Navigate to story screen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StoryScreen(
            minutes: minutes,
            xp: earnedXP,
            level: _currentLevel,
            streak: _streakDays,
          ),
        ),
      );
    }
  }

  void _onFinishButtonPressed() {
    setState(() => _finishButtonPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _finishButtonPressed = false);
    });
    _finishSession();
  }

  void _onCrashButtonPressed() {
    setState(() => _crashButtonPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _crashButtonPressed = false);
    });
    _crashSession();
  }

  void _onStartButtonPressed() {
    setState(() => _startButtonPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _startButtonPressed = false);
    });
    _startSession();
  }

  String get _formattedTime {
    int mins = _seconds ~/ 60;
    int secs = _seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  double _calculateMultiplier(int minutes) {
    if (minutes >= 60) return 3.0;
    if (minutes >= 25) return 2.0;
    if (minutes >= 10) return 1.5;
    return 1.0;
  }

  int _calculateLiveXP(int seconds) {
    int minutes = (seconds / 60).floor();
    double multiplier = _calculateMultiplier(minutes);
    return (minutes * 8 * multiplier).toInt();
  }

  bool get _isMaxMultiplier => _seconds >= 60 * 60;

  double get _multiplierProgress {
    if (_isMaxMultiplier) return 1.0;

    double minutes = _seconds / 60.0;
    double start = 0;
    double end = 10;

    if (minutes >= 25) {
      start = 25;
      end = 60;
    } else if (minutes >= 10) {
      start = 10;
      end = 25;
    } else {
      start = 0;
      end = 10;
    }

    return ((minutes - start) / (end - start)).clamp(0.0, 1.0);
  }

  String get _multiplierProgressText {
    if (_isMaxMultiplier) return "MAX MULTIPLIER REACHED";

    double minutes = _seconds / 60.0;
    if (minutes >= 25) {
      return "Next Multiplier at 60 min";
    }
    if (minutes >= 10) {
      return "Next Multiplier at 25 min";
    }
    return "Next Multiplier at 10 min";
  }

  int get _currentLevel => 1 + (_totalXP ~/ 1000);

  int get _xpInCurrentLevel => _totalXP % 1000;

  double get _levelProgress => (_xpInCurrentLevel / 1000).clamp(0.0, 1.0);

  String get _levelProgressText =>
      "$_xpInCurrentLevel / 1000 XP to Level ${_currentLevel + 1}";

  void _updateXPValues() {
    setState(() {
      int minutes = (_seconds / 60).floor();
      _currentMultiplier = _calculateMultiplier(minutes);
      _liveXP = _calculateLiveXP(_seconds);
    });
  }

  Widget _buildActionButton(
    String title,
    Color color,
    VoidCallback onTap,
    bool isPressed, {
    double width = 140,
    double height = 50,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      transform: Matrix4.identity()..scale(isPressed ? 0.94 : 1.0),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget actionControls = _isActive
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                'FINISH',
                Colors.green.shade600,
                _onFinishButtonPressed,
                _finishButtonPressed,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                'CRASH',
                Colors.grey.shade700,
                _onCrashButtonPressed,
                _crashButtonPressed,
              ),
            ],
          )
        : Center(
            child: _buildActionButton(
              'START GRIND',
              Colors.redAccent,
              _onStartButtonPressed,
              _startButtonPressed,
              width: 220,
              height: 54,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avero Tracker'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(history: _sessionHistory),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'View History',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1a0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "STREAK: $_streakDays DAYS",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                if (_lastActiveDate != null)
                  Text(
                    "Last active: ${_lastActiveDate!.year}-${_lastActiveDate!.month.toString().padLeft(2, '0')}-${_lastActiveDate!.day.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                const SizedBox(height: 16),
                Text(
                  "LEVEL $_currentLevel",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 280,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _levelProgress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.redAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _levelProgressText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DAILY MISSIONS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._dailyMissions.map((mission) {
                        final int progress = mission.id == 'focus30'
                            ? _focusProgressToday
                            : mission.id == 'sessions2'
                            ? _sessionsProgressToday
                            : _xpProgressToday;
                        final String progressLabel = mission.id == 'focus30'
                            ? '$progress/${mission.target} min'
                            : mission.id == 'sessions2'
                            ? '$progress/${mission.target} sessions'
                            : '$progress/${mission.target} XP';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mission.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      progressLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: mission.completed
                                            ? Colors.greenAccent
                                            : Colors.white70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                mission.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: mission.completed
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TweenAnimationBuilder<int>(
                  tween: Tween<int>(begin: 0, end: _totalXP),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      "TOTAL XP: $value",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        letterSpacing: 1.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(history: _sessionHistory),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 8,
                    shadowColor: Colors.blueGrey.withOpacity(0.5),
                  ),
                  child: const Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isActive ? _pulseAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isActive
                                ? Colors.redAccent
                                : Colors.grey.shade600,
                            width: 4,
                          ),
                          boxShadow: _isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                        child: TweenAnimationBuilder<String>(
                          tween: Tween<String>(
                            begin: _formattedTime,
                            end: _formattedTime,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Text(
                              _formattedTime,
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: _isActive
                                    ? Colors.white
                                    : Colors.white70,
                                shadows: _isActive
                                    ? [
                                        Shadow(
                                          color: Colors.redAccent.withOpacity(
                                            0.8,
                                          ),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : [],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                if (_isActive) ...[
                  TweenAnimationBuilder<int>(
                    tween: Tween<int>(begin: 0, end: _liveXP),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Text(
                        "SESSION XP: $value",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 1.2,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "MULTIPLIER: x$_currentMultiplier",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _multiplierProgressText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 280,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: _isMaxMultiplier ? 1.0 : _multiplierProgress,
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.lerp(Colors.redAccent, Colors.pink, value)!,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                actionControls,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<SessionHistoryEntry> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Screen')),
      backgroundColor: Colors.black,
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No sessions yet. Start a session to see progress here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final statusColor = entry.success ? Colors.green : Colors.red;
                final statusIcon = entry.success ? '✓' : '✗';
                final statusText = entry.success ? 'Success' : 'Crashed';
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor,
                      child: Text(
                        statusIcon,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${entry.durationMinutes} min',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '+${entry.xp} XP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${entry.timestamp.toLocal()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
