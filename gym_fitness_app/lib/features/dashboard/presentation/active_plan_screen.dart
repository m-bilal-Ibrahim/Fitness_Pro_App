import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gyms/presentation/gym_controller.dart';

class ActivePlanScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> booking;
  final String bookingId;
  final Color themeColor;

  const ActivePlanScreen({
    super.key,
    required this.booking,
    required this.bookingId,
    this.themeColor = Colors.black, // Default changed to Black
  });

  @override
  ConsumerState<ActivePlanScreen> createState() => _ActivePlanScreenState();
}

class _ActivePlanScreenState extends ConsumerState<ActivePlanScreen> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  double _userRating = 5.0;
  bool _isRatingLoading = false;

  // Theme Constant
  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTimeLeft());

    if (widget.booking['myRating'] != null) {
      _userRating = (widget.booking['myRating'] as num).toDouble();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    final expiry = DateTime.parse(widget.booking['expiryDate']);
    final now = DateTime.now();
    setState(() {
      _timeLeft = expiry.isAfter(now) ? expiry.difference(now) : Duration.zero;
    });
  }

  Future<void> _submitRating() async {
    setState(() => _isRatingLoading = true);
    try {
      final gyms = await ref.read(allGymsProvider.future);
      final currentGym = gyms.firstWhere((g) => g.id == widget.booking['gymId']);

      await ref.read(gymControllerProvider).rateGym(
        gymId: widget.booking['gymId'],
        bookingId: widget.bookingId,
        currentUserRating: _userRating,
        currentGymRating: currentGym.rating,
      );

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rating Updated!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isRatingLoading = false);
    }
  }

  Future<void> _unsubscribe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900, // Dark background
        title: const Text("Unsubscribe?", style: TextStyle(color: Colors.white)),
        content: const Text("You will lose access immediately. This cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Unsubscribe", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(gymControllerProvider).cancelMembership(widget.bookingId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Scaffold(
      backgroundColor: Colors.black, // Force Black background
      appBar: AppBar(
        title: const Text("Membership Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: neonGreen), // Neon Green Icon
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // MAIN INFO CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade900, // Dark Grey Card
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(widget.booking['gymName'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: neonGreen, borderRadius: BorderRadius.circular(20)),
                    // Changed FontWeight.black to w900 to avoid errors
                    child: Text(widget.booking['plan'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 12, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 30),
                  const Text("EXPIRES IN", style: TextStyle(color: neonGreen, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      _timeUnit(days, "DAYS"), _colon(),
                      _timeUnit(hours, "HRS"), _colon(),
                      _timeUnit(minutes, "MIN"), _colon(),
                      _timeUnit(seconds, "SEC"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // RATING SECTION
            const Text("Rate Your Experience", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900, // Dark Grey Card
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(_userRating.toStringAsFixed(1), style: const TextStyle(color: neonGreen, fontSize: 24, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _userRating,
                    min: 1.0, max: 5.0, divisions: 40,
                    activeColor: neonGreen, // Neon Green Accent
                    thumbColor: neonGreen,
                    inactiveColor: Colors.white10,
                    onChanged: (val) => setState(() => _userRating = val),
                  ),
                  ElevatedButton(
                    onPressed: _isRatingLoading ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: neonGreen, // Neon Green Button
                        foregroundColor: Colors.black, // Black Text
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                    ),
                    child: _isRatingLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black)) : const Text("Submit Rating", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // UNSUBSCRIBE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _unsubscribe,
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade700),
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.transparent
                ),
                child: const Text("Unsubscribe & Cancel Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeUnit(int value, String label) {
    return Column(children: [
      Text(value.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')), // White Text
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)), // Grey Text
    ]);
  }

  Widget _colon() => const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text(":", style: TextStyle(color: neonGreen, fontSize: 32))); // Neon Green Colon
}