import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  bool _isDarkMode = false; // New property for dark mode

  Duration get elapsedTime => _elapsedTime;
  bool get isRunning => _isRunning;
  bool get isDarkMode => _isDarkMode; // Getter for dark mode

  void startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _elapsedTime += Duration(seconds: 1);
      notifyListeners();
    });
  }

  void stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  void resetTimer() {
    _elapsedTime = Duration.zero;
    notifyListeners();
  }

  // Method to toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
