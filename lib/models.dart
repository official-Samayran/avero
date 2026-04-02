import 'package:flutter/material.dart';

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
