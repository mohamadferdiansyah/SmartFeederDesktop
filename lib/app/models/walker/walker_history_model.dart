import 'dart:ui';

import 'package:flutter/material.dart';

class WalkerHistoryModel {
  final int? id;
  final String deviceId;
  final String status; // 'START', 'SELESAI', atau 'DIHENTIKAN'
  final List<String> horseIds; // Array ID kuda
  final String mode; // 'duration' atau 'rotation'
  final int? duration; // durasi dalam menit (jika mode duration)
  final int? rotation; // jumlah putaran (jika mode rotation)
  final int speed; // kecepatan RPM
  final DateTime timeStart; // waktu mulai
  final DateTime? timeStop; // waktu berhenti (nullable)

  WalkerHistoryModel({
    this.id,
    required this.deviceId,
    required this.status,
    required this.horseIds,
    required this.mode,
    this.duration,
    this.rotation,
    required this.speed,
    required this.timeStart,
    this.timeStop,
  });

  factory WalkerHistoryModel.fromMap(Map<String, dynamic> map) {
    return WalkerHistoryModel(
      id: map['id'],
      deviceId: map['device_id'],
      status: map['status'],
      horseIds: map['horse_ids'] != null 
          ? List<String>.from(map['horse_ids'].split(',').where((h) => h.isNotEmpty))
          : [],
      mode: map['mode'],
      duration: map['duration'],
      rotation: map['rotation'],
      speed: map['speed'],
      timeStart: DateTime.parse(map['time_start']),
      timeStop: map['time_stop'] != null ? DateTime.parse(map['time_stop']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'device_id': deviceId,
      'status': status,
      'horse_ids': horseIds.join(','),
      'mode': mode,
      'duration': duration,
      'rotation': rotation,
      'speed': speed,
      'time_start': timeStart.toIso8601String(),
      'time_stop': timeStop?.toIso8601String(),
    };
  }

  String get formattedTimeStart => 
      '${timeStart.day.toString().padLeft(2, '0')}-'
      '${timeStart.month.toString().padLeft(2, '0')}-'
      '${timeStart.year} '
      '${timeStart.hour.toString().padLeft(2, '0')}:'
      '${timeStart.minute.toString().padLeft(2, '0')}:'
      '${timeStart.second.toString().padLeft(2, '0')}';

  String get formattedTimeStop {
    if (timeStop == null) return '-';
    return '${timeStop!.day.toString().padLeft(2, '0')}-'
           '${timeStop!.month.toString().padLeft(2, '0')}-'
           '${timeStop!.year} '
           '${timeStop!.hour.toString().padLeft(2, '0')}:'
           '${timeStop!.minute.toString().padLeft(2, '0')}:'
           '${timeStop!.second.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (status.toUpperCase()) {
      case 'START':
        return 'Dimulai';
      case 'SELESAI':
        return 'Selesai';
      case 'DIHENTIKAN':
        return 'Dihentikan';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'START':
        return Colors.blue;
      case 'SELESAI':
        return Colors.green;
      case 'DIHENTIKAN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toUpperCase()) {
      case 'START':
        return Icons.play_arrow;
      case 'SELESAI':
        return Icons.check_circle;
      case 'DIHENTIKAN':
        return Icons.stop_circle;
      default:
        return Icons.history;
    }
  }

  String get modeText {
    switch (mode) {
      case 'duration':
        return 'Durasi';
      case 'rotation':
        return 'Putaran';
      default:
        return mode;
    }
  }

  String get durationText {
    if (mode == 'duration' && duration != null) {
      return '$duration menit';
    } else if (mode == 'rotation' && rotation != null) {
      return '$rotation putaran';
    }
    return '-';
  }

  Duration? get actualDuration {
    if (timeStop != null) {
      return timeStop!.difference(timeStart);
    }
    return null;
  }

  String get actualDurationText {
    final actual = actualDuration;
    if (actual == null) return 'Masih berjalan';
    
    final hours = actual.inHours;
    final minutes = actual.inMinutes % 60;
    final seconds = actual.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}j ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Method untuk menentukan apakah walker selesai atau dihentikan
  bool get isCompletedNaturally {
    if (timeStop == null || actualDuration == null) return false;
    
    if (mode == 'duration' && duration != null) {
      // Toleransi 30 detik untuk durasi
      final expectedDuration = Duration(minutes: duration!);
      final difference = (actualDuration!.inSeconds - expectedDuration.inSeconds).abs();
      return difference <= 30; // Jika selisih kurang dari 30 detik, dianggap selesai natural
    } else if (mode == 'rotation' && rotation != null) {
      // Untuk mode rotation, kita perlu logic tambahan dari device
      // Sementara kita anggap selesai jika durasi lebih dari 1 menit
      return actualDuration!.inMinutes >= 1;
    }
    
    return false;
  }

  // Method untuk update status berdasarkan cara berhenti
  WalkerHistoryModel updateStatusOnStop({required bool isManualStop}) {
    return WalkerHistoryModel(
      id: id,
      deviceId: deviceId,
      status: isManualStop ? 'DIHENTIKAN' : 'SELESAI',
      horseIds: horseIds,
      mode: mode,
      duration: duration,
      rotation: rotation,
      speed: speed,
      timeStart: timeStart,
      timeStop: DateTime.now(),
    );
  }
}