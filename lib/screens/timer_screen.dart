import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../theme.dart';
import '../widgets.dart';
import '../services/app_blocker.dart';

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
  int _currentTrackIndex = 0;
  final List<Map<String, dynamic>> _tracks = [
    {'name': 'DEEP BROWN NOISE', 'url': 'brown_noise.mp3', 'isLocal': false},
    {'name': 'LO-FI BEATS', 'url': 'lofi.mp3', 'isLocal': false},
    {'name': 'HEAVY RAIN', 'url': 'rain.mp3', 'isLocal': false},
  ];

  // Tags
  final List<String> _tags = ['CODING', 'READING', 'WORKOUT', 'DEEP WORK'];
  String _selectedTag = 'CODING';

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
      await _playCurrentTrack();
    }
    setState(() {
      _isPlayingSound = !_isPlayingSound;
    });
  }

  Future<void> _playCurrentTrack() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      final track = _tracks[_currentTrackIndex];
      if (track['isLocal'] == true) {
        await _audioPlayer.play(DeviceFileSource(track['url']));
      } else {
        await _audioPlayer.play(AssetSource(track['url']));
      }
    } catch (e) {
      debugPrint("No audio asset found.");
    }
  }

  void _nextTrack() async {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
    });
    if (_isPlayingSound) {
      await _playCurrentTrack();
    }
  }

  Future<void> _pickLocalAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      String localPath = result.files.single.path!;
      String fileName = result.files.single.name;
      setState(() {
        _tracks.add({
          'name': fileName.toUpperCase(),
          'url': localPath,
          'isLocal': true,
        });
        _currentTrackIndex = _tracks.length - 1;
      });
      if (_isPlayingSound) {
        await _playCurrentTrack();
      }
    }
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
      _crashSession(reason: "BLOCKED APP DETECTED");
    });
  }

  void _crashSession({String reason = "SESSION CRASHED"}) async {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFEF4444),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.black),
                    const SizedBox(height: 32),
                    Text(
                      reason,
                      textAlign: TextAlign.center,
                      style: getThemeTextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "-100 XP PENALTY",
                      style: getThemeTextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                    ),
                    const SizedBox(height: 64),
                    buildThemedButton(
                      'ACCEPT PUNISHMENT',
                      Colors.black,
                      () {
                        Navigator.pop(context);
                      },
                      textColor: Colors.white,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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
            "SESSION COMPLETE +${minutes * 8} XP IN $_selectedTag",
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

  Widget _buildSetupAndTimer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isActive) ...[
          Text("CHOOSE QUEST //", style: getThemeTextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _tags.map((tag) {
              bool isSelected = _selectedTag == tag;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTag = tag;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Colors.transparent,
                    border: Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 2),
                  ),
                  child: Text(
                    tag,
                    style: getThemeTextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
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
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemedCard(
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isPlayingSound ? Icons.pause : Icons.play_arrow),
                  onPressed: _toggleSoundscape,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  iconSize: 32,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FOCUS RADIO",
                        style: getThemeTextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        _tracks[_currentTrackIndex]['name']!,
                        style: getThemeTextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.folder_solid),
                  onPressed: _pickLocalAudioFile,
                  iconSize: 24,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  tooltip: "Load Local File",
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _nextTrack,
                  iconSize: 28,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        _isActive
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildThemedButton(
                      'FINISH',
                      Colors.greenAccent,
                      _finishSession,
                      width: double.infinity,
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildThemedButton(
                      'CRASH!',
                      const Color(0xFFEF4444),
                      () => _crashSession(reason: "MANUAL CRASH DEPLOYED"),
                      textColor: Colors.white,
                      width: double.infinity,
                    ),
                  ),
                ],
              )
            : buildThemedButton(
                'START GRIND',
                Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                _startSession,
                width: double.infinity,
                textColor: Theme.of(context).scaffoldBackgroundColor,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FOCUS', style: getThemeTextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSetupAndTimer(),
                  const SizedBox(height: 48),
                  _buildControls(),
                ],
              ),
            );
          } else {
            // Landscape mode avoids overflow by using Row instead of Column
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _buildSetupAndTimer()),
                  const SizedBox(width: 48),
                  Expanded(child: _buildControls()),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
