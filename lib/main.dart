import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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

class AveroHome extends StatefulWidget {
  const AveroHome({super.key});

  @override
  State<AveroHome> createState() => _AveroHomeState();
}

class _AveroHomeState extends State<AveroHome> {
  int _seconds = 0;
  int _totalXP = 0;
  int _liveXP = 0;
  double _currentMultiplier = 1.0;
  Timer? _timer;
  bool _isActive = false;

  // Developer mode flag (toggle for production)
  bool isDevMode = false;
  bool _isDevPanelExpanded = false;
  int _titleTapCount = 0;
  Timer? _titleTapTimer;
  double? _forcedMultiplier;

  int _streakDays = 0;
  DateTime? _lastActiveDate;

  DateTime? _missionDate;
  int _dailyFocusMinutes = 0;
  int _dailySessionsCompleted = 0;
  int _dailyXpEarned = 0;

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
    _loadStreakData();
    _loadMissionData();
  }

  Future<void> _loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt('streakDays') ?? 0;
    final lastDateString = prefs.getString('lastActiveDate');

    setState(() {
      _streakDays = streak;
      _lastActiveDate = lastDateString != null
          ? DateTime.tryParse(lastDateString)
          : null;
    });
  }

  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streakDays', _streakDays);
    if (_lastActiveDate != null) {
      await prefs.setString(
        'lastActiveDate',
        _lastActiveDate!.toIso8601String(),
      );
    }
  }

  Future<void> _loadMissionData() async {
    final prefs = await SharedPreferences.getInstance();
    final missionDateString = prefs.getString('missionDate');
    final now = DateTime.now();

    if (missionDateString != null) {
      final savedDate = DateTime.tryParse(missionDateString);
      if (savedDate != null && _isSameDay(savedDate, now)) {
        _dailyFocusMinutes = prefs.getInt('dailyFocusMinutes') ?? 0;
        _dailySessionsCompleted = prefs.getInt('dailySessionsCompleted') ?? 0;
        _dailyXpEarned = prefs.getInt('dailyXpEarned') ?? 0;

        for (final mission in _dailyMissions) {
          mission.completed =
              prefs.getBool('mission_${mission.id}_completed') ?? false;
        }

        _missionDate = savedDate;
      } else {
        _resetDailyMissionsForNewDay(now);
      }
    } else {
      _resetDailyMissionsForNewDay(now);
    }

    setState(() {});
    _checkDailyMissions();
  }

  Future<void> _saveMissionData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_missionDate != null) {
      await prefs.setString('missionDate', _missionDate!.toIso8601String());
    }
    await prefs.setInt('dailyFocusMinutes', _dailyFocusMinutes);
    await prefs.setInt('dailySessionsCompleted', _dailySessionsCompleted);
    await prefs.setInt('dailyXpEarned', _dailyXpEarned);

    for (final mission in _dailyMissions) {
      await prefs.setBool('mission_${mission.id}_completed', mission.completed);
    }
  }

  void _resetDailyMissionsForNewDay(DateTime today) {
    _missionDate = DateTime(today.year, today.month, today.day);
    _dailyFocusMinutes = 0;
    _dailySessionsCompleted = 0;
    _dailyXpEarned = 0;
    for (final mission in _dailyMissions) {
      mission.completed = false;
    }
    _saveMissionData();
  }

  void _checkAndResetDailyMissions() {
    final now = DateTime.now();
    if (_missionDate == null || !_isSameDay(_missionDate!, now)) {
      _resetDailyMissionsForNewDay(now);
    }
  }

  int get _focusProgressToday =>
      _dailyFocusMinutes + (_isActive ? (_seconds / 60).floor() : 0);
  int get _sessionsProgressToday => _dailySessionsCompleted;
  int get _xpProgressToday => _dailyXpEarned + (_isActive ? _liveXP : 0);

  void _checkDailyMissions() {
    _checkAndResetDailyMissions();

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

    _saveMissionData();
    setState(() {});
  }

  void _updateMissionProgressOnSessionComplete(int minutes, int earnedXP) {
    _dailyFocusMinutes += minutes;
    _dailySessionsCompleted += 1;
    _dailyXpEarned += earnedXP;
    _checkDailyMissions();
  }

  void _toggleDevMode() {
    setState(() {
      isDevMode = !isDevMode;
      _isDevPanelExpanded = isDevMode;
    });
    final text = isDevMode ? 'DEV MODE ENABLED' : 'DEV MODE DISABLED';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _handleTitleTap() {
    _titleTapCount += 1;
    _titleTapTimer?.cancel();
    _titleTapTimer = Timer(const Duration(seconds: 1), () {
      _titleTapCount = 0;
    });

    if (_titleTapCount >= 5) {
      _titleTapCount = 0;
      _titleTapTimer?.cancel();
      _toggleDevMode();
    }
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

  // ðŸ”¥ START SESSION
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
        _seconds += isDevMode ? 60 : 1;
        _updateXPValues();
      });
      _checkDailyMissions();
    });
  }

  // ðŸ’€ CRASH SESSION
  void _crashSession() {
    _timer?.cancel();

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

  // âœ… FINISH SESSION
  Future<void> _finishSession() async {
    _timer?.cancel();

    int minutes = (_seconds / 60).floor();

    double multiplier = 1;

    if (isDevMode && _forcedMultiplier != null) {
      multiplier = _forcedMultiplier!;
    } else {
      if (minutes >= 60) {
        multiplier = 3;
      } else if (minutes >= 25) {
        multiplier = 2;
      } else if (minutes >= 10) {
        multiplier = 1.5;
      }
    }

    int baseXP = minutes * 8;
    int earnedXP = (baseXP * multiplier).toInt();

    _checkAndResetDailyMissions();
    _updateMissionProgressOnSessionComplete(minutes, earnedXP);

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("SESSION COMPLETE +$earnedXP XP (x$multiplier)")),
    );
  }

  // â±ï¸ FORMAT TIME
  String get _formattedTime {
    int mins = _seconds ~/ 60;
    int secs = _seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  // ðŸ§® CALCULATE MULTIPLIER
  double _calculateMultiplier(int minutes) {
    if (isDevMode && _forcedMultiplier != null) {
      return _forcedMultiplier!;
    }

    if (minutes >= 60) return 3.0;
    if (minutes >= 25) return 2.0;
    if (minutes >= 10) return 1.5;
    return 1.0;
  }

  // ðŸ§® CALCULATE LIVE XP
  int _calculateLiveXP(int seconds) {
    int minutes = (seconds / 60).floor();
    double multiplier = _calculateMultiplier(minutes);
    return (minutes * 8 * multiplier).toInt();
  }

  // ï¿½ PROGRESS TOWARD NEXT MULTIPLIER
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

  // 🧱 LEVEL SYSTEM
  int get _currentLevel => 1 + (_totalXP ~/ 1000);

  int get _xpInCurrentLevel => _totalXP % 1000;

  double get _levelProgress => (_xpInCurrentLevel / 1000).clamp(0.0, 1.0);

  String get _levelProgressText =>
      "$_xpInCurrentLevel / 1000 XP to Level ${_currentLevel + 1}";

  // �🔄 UPDATE XP VALUES
  void _updateXPValues() {
    setState(() {
      int minutes = (_seconds / 60).floor();
      _currentMultiplier = _calculateMultiplier(minutes);
      _liveXP = _calculateLiveXP(_seconds);
    });
  }

  // DEV MODE ACTIONS
  void _addXP(int amount) {
    if (!isDevMode) return;
    setState(() {
      _totalXP += amount;
    });
  }

  void _setForcedMultiplier(double value) {
    if (!isDevMode) return;
    setState(() {
      _forcedMultiplier = value;
      _currentMultiplier = value;
      _liveXP = _calculateLiveXP(_seconds);
    });
  }

  void _resetForcedMultiplier() {
    if (!isDevMode) return;
    setState(() {
      _forcedMultiplier = null;
      _updateXPValues();
    });
  }

  void _addStreakDay() {
    if (!isDevMode) return;
    setState(() {
      _streakDays += 1;
      _lastActiveDate = DateTime.now();
    });
    _saveStreakData();
  }

  void _resetStreak() {
    if (!isDevMode) return;
    setState(() {
      _streakDays = 0;
      _lastActiveDate = null;
    });
    _saveStreakData();
  }

  Future<void> _completeSessionInstantly() async {
    if (!isDevMode) return;

    if (!_isActive) {
      _timer?.cancel();
      setState(() {
        _isActive = true;
        _seconds = 600;
        _liveXP = _calculateLiveXP(_seconds);
        _currentMultiplier = _calculateMultiplier((_seconds / 60).floor());
      });
    }

    await _finishSession();
  }

  void _crashSessionInstantly() {
    if (!isDevMode) return;

    if (!_isActive) {
      setState(() {
        _isActive = true;
        _seconds = 1;
      });
    }

    _crashSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _handleTitleTap,
                onLongPress: _toggleDevMode,
                child: Text(
                  "STREAK: $_streakDays DAYS",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (_lastActiveDate != null)
                Text(
                  "Last active: ${_lastActiveDate!.year}-${_lastActiveDate!.month.toString().padLeft(2, '0')}-${_lastActiveDate!.day.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              const SizedBox(height: 10),
              if (isDevMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "DEV MODE ON",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDevPanelExpanded = !_isDevPanelExpanded;
                        });
                      },
                      child: Chip(
                        label: Text(
                          _isDevPanelExpanded
                              ? 'Hide Dev Panel'
                              : 'Show Dev Panel',
                        ),
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (_isDevPanelExpanded)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _addXP(500),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('+500 XP'),
                        ),
                        ElevatedButton(
                          onPressed: () => _addXP(1000),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('+1000 XP'),
                        ),
                        ElevatedButton(
                          onPressed: () => _setForcedMultiplier(1.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('x1'),
                        ),
                        ElevatedButton(
                          onPressed: () => _setForcedMultiplier(1.5),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('x1.5'),
                        ),
                        ElevatedButton(
                          onPressed: () => _setForcedMultiplier(2.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('x2'),
                        ),
                        ElevatedButton(
                          onPressed: () => _setForcedMultiplier(3.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('x3'),
                        ),
                        ElevatedButton(
                          onPressed: _resetForcedMultiplier,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Text('Reset Multiplier'),
                        ),
                        ElevatedButton(
                          onPressed: _completeSessionInstantly,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Complete Session'),
                        ),
                        ElevatedButton(
                          onPressed: _crashSessionInstantly,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Crash Session'),
                        ),
                        ElevatedButton(
                          onPressed: _addStreakDay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Add Streak Day'),
                        ),
                        ElevatedButton(
                          onPressed: _resetStreak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                          ),
                          child: const Text('Reset Streak'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],
              Text(
                "LEVEL $_currentLevel",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 280,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _levelProgress,
                    backgroundColor: Colors.grey.shade900,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _levelProgressText,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                width: 320,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 82, 82, 0.4),
                  ),
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
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        padding: const EdgeInsets.only(bottom: 8),
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
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    progressLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: mission.completed
                                          ? Colors.greenAccent
                                          : Colors.white70,
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
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onLongPress: _toggleDevMode,
                child: Text(
                  "TOTAL XP: $_totalXP",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // â±ï¸ TIMER UI
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isActive ? Colors.redAccent : Colors.grey,
                    width: 4,
                  ),
                ),
                child: Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ðŸ”¥ XP DISPLAY (ONLY WHEN ACTIVE)
              if (_isActive) ...[
                Text(
                  "SESSION XP: $_liveXP",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "MULTIPLIER: x$_currentMultiplier",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                const SizedBox(height: 8),
                Container(
                  width: 280,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: _isMaxMultiplier ? 1.0 : _multiplierProgress,
                      backgroundColor: Colors.grey.shade900,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // ðŸ”˜ BUTTONS
              _isActive
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _finishSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("FINISH"),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _crashSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text("CRASH"),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _startSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        "START GRIND",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
