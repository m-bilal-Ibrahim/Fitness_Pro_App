// lib/features/workouts/presentation/workout_player_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/workout_model.dart';
import '../domain/workout_data.dart';
import '../domain/workout_logic.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final String category;
  final int difficultyIndex;

  const WorkoutPlayerScreen({super.key, required this.category, required this.difficultyIndex});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late List<Exercise> _playlist;
  int _currentIndex = 0;
  int _exerciseTimer = 0;
  int _totalTimer = 0;
  bool _isResting = false;
  bool _isPaused = false;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _playlist = generateWorkoutPlaylist(widget.category, widget.difficultyIndex);
    _exerciseTimer = _playlist[0].durationSeconds;
    _startWorkout();
  }

  void _startWorkout() {
    _clock = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isPaused) return;
      setState(() {
        _totalTimer++;
        if (_exerciseTimer > 0) {
          _exerciseTimer--;
        } else {
          _handleTransition();
        }
      });
    });
  }

  void _handleTransition() {
    if (!_isResting) {
      if (_currentIndex >= _playlist.length - 1) {
        _clock?.cancel();
        _showFinishedDialog();
      } else {
        _isResting = true;
        _exerciseTimer = calculateRest(widget.difficultyIndex);
      }
    } else {
      _isResting = false;
      _currentIndex++;
      _exerciseTimer = _playlist[_currentIndex].durationSeconds;
    }
  }

  // Confirmation Logic for Top Left Cancel Icon
  void _confirmExit() {
    final wasPaused = _isPaused;
    setState(() => _isPaused = true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Exit Workout?", style: TextStyle(color: Colors.white,fontSize: 14)),
        content: const Text("If you quit now, all progress for this session will be lost.",
            style: TextStyle(color: Colors.white70,fontSize: 10)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isPaused = wasPaused);
            },
            child: const Text("CONTINUE", style: TextStyle(color: Color(0xFFD0FD3E),fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("EXIT", style: TextStyle(color: Colors.redAccent,fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _skipNext() {
    if (_currentIndex < _playlist.length - 1) {
      setState(() {
        _isResting = false;
        _currentIndex++;
        _exerciseTimer = _playlist[_currentIndex].durationSeconds;
      });
    } else {
      _clock?.cancel();
      _showFinishedDialog();
    }
  }

  void _skipPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _isResting = false;
        _currentIndex--;
        _exerciseTimer = _playlist[_currentIndex].durationSeconds;
      });
    }
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEx = _playlist[_currentIndex];
    final progress = (_currentIndex + 1) / _playlist.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 16,),
          onPressed: _confirmExit, // Linked to confirmation
        ),
        title: Column(
          children: [
            Text("EXERCISE ${_currentIndex + 1} OF ${_playlist.length}",
                style: const TextStyle(color: Colors.white54, fontSize: 9)),
            Text("TOTAL: ${_formatTime(_totalTimer)}",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: const Color(0xFFD0FD3E),
              minHeight: 4,
            ),
            // Instructional Box - Flexible to handle overflow
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isResting ? Icons.timer_outlined : Icons.info_outline,
                          size: 24, color: const Color(0xFFD0FD3E)),
                      const SizedBox(height: 8),
                      Text(_isResting ? "GET READY FOR:" : "HOW TO DO IT:",
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _isResting ? _playlist[_currentIndex + 1].name.toUpperCase() : currentEx.instruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Timer and Controls - Flexible for screen scaling
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(_isResting ? "REST PERIOD" : currentEx.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),

                  Text(_formatTime(_exerciseTimer),
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 40, fontWeight: FontWeight.bold)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 25), onPressed: _skipPrevious),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => setState(() => _isPaused = !_isPaused),
                        child: CircleAvatar(
                            radius: 27,
                            backgroundColor: const Color(0xFFD0FD3E),
                            child: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 28, color: Colors.black)),
                      ),
                      const SizedBox(width: 20),
                      IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 25), onPressed: _skipNext),
                    ],
                  ),
                  const Text("KEEP PUSHING • NO EXCUSES",
                      style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Workout Complete!", style: TextStyle(color: Colors.white,fontSize: 16)),
        content: Text("Finished in ${_formatTime(_totalTimer)}.", style: const TextStyle(color: Colors.white70,fontSize: 12)),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("FINISH", style: TextStyle(color: Colors.black,fontSize: 12))
          )
        ],
      ),
    );
  }
}