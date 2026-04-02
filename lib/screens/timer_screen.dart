import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme.dart';
import '../widgets.dart';
import '../services/app_blocker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _seconds = 0;
  bool _isActive = false;
  Timer? _timer;
  
  // Soundscape
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSound = false;

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleSoundscape() async {
    if (_isPlayingSound) {
      await _audioPlayer.pause();
    } else {
      // Because we don't have local assets guaranteed, we can use a known internet ambient sound or wait for the user to add one.
      // Alternatively, we use a placeholder asset and catch error if missing.
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('brown_noise.mp3')); // Assume user has this or we mock it
      } catch (e) {
        debugPrint("No audio asset found.");
      }
    }
    setState(() {
      _isPlayingSound = !_isPlayingSound;
    });
  }

  void _startSession() {
    _timer?.cancel();
    setState(() {
      _isActive = true;
      _seconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds += 1;
      });
    });

    // Start App Blocker
    AppBlockerService().startMonitoring(() {
      _crashSession(reason: "BLOCKED APP OPENED!");
    });
  }

  void _crashSession({String reason = "SESSION CRASHED. NO XP."}) async {
    _timer?.cancel();
    AppBlockerService().stopMonitoring();
    if (_isPlayingSound) {
      await _audioPlayer.pause();
      _isPlayingSound = false;
    }

    setState(() {
      _isActive = false;
      _seconds = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            reason,
            style: getThemeTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _finishSession() async {
    _timer?.cancel();
    AppBlockerService().stopMonitoring();
    if (_isPlayingSound) {
      await _audioPlayer.pause();
      _isPlayingSound = false;
    }

    int minutes = (_seconds / 60).floor();
    
    // Add logic to save session in global state / prefs ...
    // For now we persist minutes to SharedPreferences to read in Dashboard
    final prefs = await SharedPreferences.getInstance();
    int currentMinutes = prefs.getInt('total_minutes') ?? 0;
    await prefs.setInt('total_minutes', currentMinutes + minutes);

    setState(() {
      _isActive = false;
      _seconds = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text(
            "SESSION COMPLETE +${minutes * 8} XP",
            style: getThemeTextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  String get _formattedTime {
    int mins = _seconds ~/ 60;
    int secs = _seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FOCUS', style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: Icon(_isPlayingSound ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleSoundscape,
            tooltip: "Toggle Soundscape",
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: ThemedTimerPainter(seconds: _seconds, style: appThemeNotifier.value),
                child: Center(
                  child: Text(
                    _formattedTime,
                    style: getThemeTextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 64),
            _isActive
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildThemedButton(
                        'FINISH',
                        Colors.greenAccent,
                        _finishSession,
                      ),
                      const SizedBox(width: 16),
                      buildThemedButton(
                        'CRASH!',
                        const Color(0xFFEF4444),
                        () => _crashSession(),
                        textColor: Colors.white,
                      ),
                    ],
                  )
                : buildThemedButton(
                    'START GRIND',
                    Colors.white,
                    _startSession,
                    width: 200,
                  ),
          ],
        ),
      ),
    );
  }
}
