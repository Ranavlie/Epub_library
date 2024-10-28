import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_provider.dart'; // Import the timer provider

class TimerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Reading Time'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Elapsed Time:',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 10),
                Text(
                  _formatDuration(timerProvider.elapsedTime),
                  style: TextStyle(fontSize: 48),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: timerProvider.isRunning ? null : timerProvider.startTimer,
                      child: Text('Start'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: timerProvider.isRunning ? timerProvider.stopTimer : null,
                      child: Text('Stop'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: timerProvider.resetTimer,
                      child: Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
