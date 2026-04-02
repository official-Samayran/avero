import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBlockerService {
  static final AppBlockerService _instance = AppBlockerService._internal();
  factory AppBlockerService() => _instance;
  AppBlockerService._internal();

  List<String> blockedPackages = [];
  Timer? _monitoringTimer;
  VoidCallback? onDistractionDetected;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('blockedPackages');
    if (data != null) {
      try {
        blockedPackages = List<String>.from(jsonDecode(data));
      } catch (e) {
        blockedPackages = [];
      }
    }
  }

  Future<void> saveBlockedPackages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('blockedPackages', jsonEncode(blockedPackages));
  }

  void toggleBlock(String packageName) {
    if (blockedPackages.contains(packageName)) {
      blockedPackages.remove(packageName);
    } else {
      blockedPackages.add(packageName);
    }
    saveBlockedPackages();
  }

  void startMonitoring(VoidCallback onCrash) async {
    onDistractionDetected = onCrash;
    
    // Check if permission is granted
    bool? isGranted = await UsageStats.checkUsagePermission();
    if (isGranted != true) {
      debugPrint("Usage permission not granted. Requesting...");
      UsageStats.grantUsagePermission();
      return; 
    }

    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(seconds: 10));

      List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);
      if (events.isNotEmpty) {
        events.sort((a, b) => (b.timeStamp ?? "0").compareTo(a.timeStamp ?? "0"));
        
        // Find the most recent event where an app was moved to foreground (eventType == '1')
        final foregroundEvent = events.firstWhere(
          (e) => e.eventType == '1', 
          orElse: () => EventUsageInfo()
        );

        if (foregroundEvent.packageName != null) {
          if (blockedPackages.contains(foregroundEvent.packageName)) {
            debugPrint("Blocked app detected: ${foregroundEvent.packageName}");
            stopMonitoring();
            onDistractionDetected?.call();
          }
        }
      }
    });
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
}
