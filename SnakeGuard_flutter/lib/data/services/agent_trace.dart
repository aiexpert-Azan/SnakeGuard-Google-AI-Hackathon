import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';

class AgentTrace {
  static final AgentTrace _instance = AgentTrace._internal();
  factory AgentTrace() => _instance;
  AgentTrace._internal();

  final List<TraceLog> _logs = [];

  List<TraceLog> get logs => List.unmodifiable(_logs);

  void log(String step, String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _logs.add(TraceLog(step: step, message: '[$timestamp] $message'));
    debugPrint('[$step] $message');
  }

  void addLog(TraceLog log) {
    _logs.add(log);
  }

  void addLogs(List<TraceLog> incomingLogs) {
    _logs.addAll(incomingLogs);
  }

  void clear() {
    _logs.clear();
  }
}
