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
  final String tag;

  SessionHistoryEntry({
    required this.timestamp,
    required this.durationMinutes,
    required this.xp,
    required this.success,
    this.tag = 'FOCUS',
  });

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SessionHistoryEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMinutes: json['durationMinutes'] as int,
      xp: json['xp'] as int,
      success: json['success'] as bool,
      tag: json['tag'] as String? ?? 'FOCUS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'durationMinutes': durationMinutes,
      'xp': xp,
      'success': success,
      'tag': tag,
    };
  }
}

class BossBattle {
  final String id;
  final String name;
  final int maxHealth;
  int currentHealth;
  final int rewardXP;

  BossBattle({
    required this.id,
    required this.name,
    required this.maxHealth,
    required this.currentHealth,
    required this.rewardXP,
  });
}

class LeagueUser {
  final String id;
  final String name;
  final int xp;
  final bool isCurrentUser;

  LeagueUser({
    required this.id,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
  });
}
