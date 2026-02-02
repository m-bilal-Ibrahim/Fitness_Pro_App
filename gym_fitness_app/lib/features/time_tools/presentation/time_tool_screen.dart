// lib/features/time_tools/presentation/time_tool_screen.dart

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeToolScreen extends StatefulWidget {
  const TimeToolScreen({super.key});

  @override
  State<TimeToolScreen> createState() => _TimeToolScreenState();
}

class _TimeToolScreenState extends State<TimeToolScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _uiTicker;
  final Stopwatch _stopwatch = Stopwatch();

  Duration _timerInitialDuration = const Duration(minutes: 0);
  Duration _timerRemaining = const Duration(minutes: 0);
  Timer? _countdownTimer;
  bool _isTimerRunning = false;
  bool _isTimerSet = false;

  static const Color neonGreen = Color(0xFFD0FD3E);
  static const Color darkBg = Colors.black;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _uiTicker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTicker.cancel();
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Duration get _currentDuration {
    if (_tabController.index == 0) return _stopwatch.elapsed;
    return _isTimerSet ? _timerRemaining : _timerInitialDuration;
  }

  void _toggleStopwatch() => setState(() => _stopwatch.isRunning ? _stopwatch.stop() : _stopwatch.start());
  void _resetStopwatch() => setState(() => _stopwatch.reset());

  void _startTimer() {
    setState(() {
      _isTimerSet = true;
      _isTimerRunning = true;
      if (_timerRemaining.inSeconds == 0) _timerRemaining = _timerInitialDuration;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timerRemaining.inSeconds > 0) {
            _timerRemaining -= const Duration(seconds: 1);
          } else {
            _stopTimer();
          }
        });
      }
    });
  }

  void _pauseTimer() {
    _countdownTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isTimerSet = false;
      _timerRemaining = _timerInitialDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = _currentDuration;
    final isTimerMode = _tabController.index == 1;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text("TIME TRACKER",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white,fontSize: 20)),
        centerTitle: true,
        backgroundColor: darkBg,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. ANALOG CLOCK - Uses Flexible to scale down on small screens
            Flexible(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: AnalogClockPainter(
                        duration: duration,
                        isTimer: isTimerMode,
                        accentColor: neonGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. TABS
            Container(
              height: 35,
              width: 200,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: neonGreen,
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white60,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: "Stopwatch"), Tab(text: "Timer")],
              ),
            ),

            // 3. DIGITAL TIME & CONTROLS - Fixed screen logic
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _tabController.index == 0
                    ? _buildStopwatchControls(duration)
                    : _buildTimerControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopwatchControls(Duration duration) {
    String time = "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          child: Text(time,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(icon: Icons.refresh, color: Colors.grey[800]!, iconColor: Colors.white, onTap: _resetStopwatch, size: 36),
            const SizedBox(width: 20),
            _buildCircleButton(icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow, color: _stopwatch.isRunning ? Colors.redAccent : neonGreen, iconColor: Colors.black, onTap: _toggleStopwatch, size: 55),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerControls() {
    if (!_isTimerSet) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // THEME FIX: Ensures digits and labels are visible
          Flexible(
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: _timerInitialDuration,
                onTimerDurationChanged: (d) => setState(() {
                  _timerInitialDuration = d;
                  _timerRemaining = d;
                }),
              ),
            ),
          ),
          const SizedBox(height: 7),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                iconSize: 10,
                backgroundColor: neonGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            onPressed: _startTimer,
            child: const Text("START TIMER", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    } else {
      Duration d = _timerRemaining;
      String time = "${d.inHours.toString().padLeft(2,'0')}:${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:${d.inSeconds.remainder(60).toString().padLeft(2,'0')}";
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(time, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleButton(icon: Icons.stop, color: Colors.grey[800]!, iconColor: Colors.white, onTap: _stopTimer, size: 40),
              const SizedBox(width: 20),
              _buildCircleButton(icon: _isTimerRunning ? Icons.pause : Icons.play_arrow, color: _isTimerRunning ? Colors.orangeAccent : neonGreen, iconColor: Colors.black, onTap: _isTimerRunning ? _pauseTimer : _startTimer, size: 60),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildCircleButton({required IconData icon, required Color color, required Color iconColor, required VoidCallback onTap, required double size}) {
    return GestureDetector(onTap: onTap, child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: size * 0.45)));
  }
}

class AnalogClockPainter extends CustomPainter {
  final Duration duration;
  final bool isTimer;
  final Color accentColor;

  AnalogClockPainter({required this.duration, required this.isTimer, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, Paint()..color = Colors.grey[900]!);
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * (pi / 180);
      final isHour = i % 5 == 0;
      final paint = Paint()..color = isHour ? Colors.white : Colors.white24..strokeWidth = isHour ? 3 : 1..strokeCap = StrokeCap.round;
      final p1 = Offset(center.dx + (radius - 8) * cos(angle), center.dy + (radius - 8) * sin(angle));
      final p2 = Offset(center.dx + (radius - 8 - (isHour ? 10.0 : 5.0)) * cos(angle), center.dy + (radius - 8 - (isHour ? 10.0 : 5.0)) * sin(angle));
      canvas.drawLine(p1, p2, paint);
    }
    final double secondAngle = (duration.inMilliseconds % 60000) / 60000 * 2 * pi - (pi / 2);
    final double minuteAngle = ((duration.inMinutes % 60) + (duration.inSeconds % 60) / 60) / 60 * 2 * pi - (pi / 2);
    final double hourAngle = ((duration.inHours % 12) + (duration.inMinutes % 60) / 60) / 12 * 2 * pi - (pi / 2);
    canvas.drawLine(center, Offset(center.dx + (radius * 0.4) * cos(hourAngle), center.dy + (radius * 0.4) * sin(hourAngle)), Paint()..color = Colors.white..strokeWidth = 6..strokeCap = StrokeCap.round);
    canvas.drawLine(center, Offset(center.dx + (radius * 0.6) * cos(minuteAngle), center.dy + (radius * 0.6) * sin(minuteAngle)), Paint()..color = Colors.white70..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.drawLine(center, Offset(center.dx + (radius * 0.8) * cos(secondAngle), center.dy + (radius * 0.8) * sin(secondAngle)), Paint()..color = accentColor..strokeWidth = 2..strokeCap = StrokeCap.round);
    canvas.drawCircle(center, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) => true;
}