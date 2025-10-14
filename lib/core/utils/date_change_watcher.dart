import 'dart:async';
import 'package:flutter/material.dart';

class DateChangeWatcher with WidgetsBindingObserver {
  DateChangeWatcher(this._onNewDay);
  final void Function(DateTime newDay) _onNewDay;
  Timer? _timer;
  DateTime _lastDay = today;

  static DateTime get today => DateUtils.dateOnly(DateTime.now());

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextCheck();
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = today;
      if (!DateUtils.isSameDay(now, _lastDay)) {
        _lastDay = now;
        _onNewDay(now);
        _scheduleNextCheck();
      }
    }
  }

  void _scheduleNextCheck() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateUtils.dateOnly(now.add(const Duration(days: 1)));
    final duration = nextMidnight.difference(now);
    _timer = Timer(duration, _onMidnight);
  }

  void _onMidnight() {
    _lastDay = today;
    _onNewDay(_lastDay);
    _scheduleNextCheck();
  }
}
