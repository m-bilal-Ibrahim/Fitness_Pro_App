// lib/features/dashboard/presentation/home_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gyms/presentation/gym_controller.dart';
import '../../gyms/data/gym_repository.dart';
import '../../gyms/domain/gym_model.dart';
import '../../gyms/domain/gym_logic.dart';
import 'active_plan_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedMetric = "Steps";
  String _selectedPeriod = "Day";
  int? _focusedIndex;

  late List<int> _dayData;
  late List<int> _weekData;
  late List<int> _monthData;

  int _dailyGoal = 4000;
  StreamSubscription<StepCount>? _stepSubscription;
  int _lastRecordedStepCount = -1;
  int _todaySteps = 0;
  bool _isPedometerAvailable = true;

  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initPedometer();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  void _initializeData() {
    _dayData = List.filled(24, 0);
    _weekData = List.filled(7, 0);
    _monthData = List.filled(4, 0);

    final now = DateTime.now();
    final random = Random();

    int currentHour = now.hour;
    for (int i = 0; i < currentHour; i++) {
      int simulatedSteps = 50 + random.nextInt(750);
      _dayData[i] = simulatedSteps;
      _todaySteps += simulatedSteps;
    }

    int currentDayIndex = now.weekday - 1;
    for (int i = 0; i < currentDayIndex; i++) {
      _weekData[i] = 3000 + random.nextInt(6000);
    }
    if (currentDayIndex >= 0 && currentDayIndex < 7) {
      _weekData[currentDayIndex] = _todaySteps;
    }

    int currentWeekIndex = (now.day / 7).floor().clamp(0, 3);
    for (int i = 0; i < currentWeekIndex; i++) {
      _monthData[i] = 20000 + random.nextInt(30000);
    }
    int currentWeekSum = _weekData.reduce((a, b) => a + b);
    _monthData[currentWeekIndex] = currentWeekSum;
  }

  int _calculateCurrentStreak() {
    int streak = 0;
    int todayIndex = DateTime.now().weekday - 1;
    for (int i = todayIndex; i >= 0; i--) {
      int steps = (i == todayIndex) ? _todaySteps : _weekData[i];
      if (steps >= _dailyGoal) streak++;
      else break;
    }
    return streak;
  }

  void _editDailyGoal() {
    int tempGoal = _dailyGoal;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: const Text("Set Daily Goal", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$tempGoal Steps", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: neonGreen)),
                  const SizedBox(height: 10),
                  Slider(
                    value: tempGoal.toDouble(), min: 1000, max: 20000, divisions: 19,
                    activeColor: neonGreen, inactiveColor: Colors.white10,
                    onChanged: (val) => setDialogState(() => tempGoal = val.toInt()),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                  onPressed: () {
                    setState(() {
                      _dailyGoal = tempGoal;
                      int todayIndex = DateTime.now().weekday - 1;
                      if(todayIndex >= 0) _weekData[todayIndex] = _todaySteps;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save Goal", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  double _convertStepsToMetric(int steps, String metric) {
    switch (metric) {
      case "Kcal": return steps * 0.045;
      case "Distance": return steps * 0.0008;
      case "Heart": return steps > 0 ? (70 + (steps / 50)).clamp(70, 160) : 72;
      default: return steps.toDouble();
    }
  }

  String _getUnit(String metric) {
    switch (metric) {
      case "Kcal": return "kcal";
      case "Distance": return "km";
      case "Heart": return "bpm";
      default: return "steps";
    }
  }

  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      try {
        _stepSubscription = Pedometer.stepCountStream.listen(
          _onStepCount, onError: (error) => setState(() => _isPedometerAvailable = false),
        );
      } catch (e) {
        setState(() => _isPedometerAvailable = false);
      }
    } else {
      setState(() => _isPedometerAvailable = false);
    }
  }

  void _onStepCount(StepCount event) {
    if (_lastRecordedStepCount == -1) {
      _lastRecordedStepCount = event.steps;
    } else {
      int delta = event.steps - _lastRecordedStepCount;
      _lastRecordedStepCount = event.steps;
      if (delta > 0) _addSteps(delta);
    }
  }

  void _addSteps(int delta) {
    setState(() {
      _todaySteps += delta;
      final now = DateTime.now();
      _dayData[now.hour] += delta;
      int dayIndex = now.weekday - 1;
      if (dayIndex >= 0 && dayIndex < 7) _weekData[dayIndex] = _todaySteps;
      int weekIndex = (now.day / 7).floor().clamp(0, 3);
      _monthData[weekIndex] += delta;
    });
  }

  Map<String, dynamic> _getCurrentGraphData() {
    List<int> rawSteps;
    if (_selectedPeriod == 'Day') rawSteps = _dayData;
    else if (_selectedPeriod == 'Week') rawSteps = _weekData;
    else rawSteps = _monthData;

    List<double> data = rawSteps.map((s) => _convertStepsToMetric(s, _selectedMetric)).toList();
    double total = data.isEmpty ? 0.0 : data.reduce((a, b) => a + b);

    List<String> labels = [];
    if (_selectedPeriod == 'Day') labels = List.generate(24, (i) => i % 6 == 0 ? "${i}h" : "");
    else if (_selectedPeriod == 'Week') labels = ["M", "T", "W", "T", "F", "S", "S"];
    else labels = ["W1", "W2", "W3", "W4"];

    return {'data': data, 'total': total, 'labels': labels};
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final activeBookingAsync = ref.watch(userActiveBookingProvider);
    final myGymsAsync = ref.watch(myGymsProvider);

    final graphState = _getCurrentGraphData();
    final List<double> values = graphState['data'];
    final List<String> labels = graphState['labels'];

    bool isFocusingFuture = false;
    if (_focusedIndex != null) {
      if (_selectedPeriod == 'Day') isFocusingFuture = _focusedIndex! > now.hour;
      else if (_selectedPeriod == 'Week') isFocusingFuture = _focusedIndex! > (now.weekday - 1);
      else isFocusingFuture = _focusedIndex! > ((now.day / 7).floor().clamp(0, 3));
    }

    final double displayValue = (_focusedIndex != null)
        ? (isFocusingFuture ? 0.0 : values[_focusedIndex!])
        : graphState['total'];

    final unit = _getUnit(_selectedMetric);
    final currentStreak = _calculateCurrentStreak();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Compact)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Activity Tracker", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (!_isPedometerAvailable)
                            GestureDetector(
                              onTap: () => _addSteps(50),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(6)),
                                child: const Row(children: [Icon(Icons.add, size: 12, color: Colors.white), Text(" TEST", style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold))]),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. GRAPH CARD (Height Reduced)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    _selectedMetric == "Steps" || _selectedMetric == "Heart"
                                        ? displayValue.toInt().toString()
                                        : displayValue.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: neonGreen)
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text("$_selectedMetric ($unit)", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildToggle(),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // --- GRAPH BARS ---
                    SizedBox(
                      height: 120,
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (_) => Container(height: 1, color: Colors.white10, width: double.infinity)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(values.length, (i) {
                              bool isFuture = false;
                              if (_selectedPeriod == 'Day') isFuture = i > now.hour;
                              else if (_selectedPeriod == 'Week') isFuture = i > (now.weekday - 1);
                              else isFuture = i > ((now.day / 7).floor().clamp(0, 3));

                              final val = values[i];
                              final maxVal = values.reduce(max) == 0 ? 1.0 : values.reduce(max);
                              final h = isFuture ? 0.0 : (val / maxVal).clamp(0.05, 1.0);
                              final isSelected = _focusedIndex == i;

                              return MouseRegion(
                                onEnter: (_) => setState(() => _focusedIndex = i),
                                onExit: (_) => setState(() => _focusedIndex = null),
                                child: GestureDetector(
                                  onTap: () => setState(() => _focusedIndex = i),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: _selectedPeriod == 'Day' ? 6 : 18,
                                        height: isFuture ? 5 : (80 * h),
                                        decoration: BoxDecoration(
                                          color: isFuture
                                              ? Colors.white10
                                              : (isSelected ? neonGreen : Colors.white24),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (labels.length > i)
                                        Text(labels[i], style: TextStyle(fontSize: 10, color: isSelected ? neonGreen : Colors.white38, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text("Activity Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),

              // 3. COMPACT BADGES
              Row(
                children: [
                  Expanded(child: _buildInteractiveStatCard("Steps", _todaySteps.toString(), "steps", Icons.directions_walk, Colors.green)),
                  const SizedBox(width: 7),
                  Expanded(child: _buildInteractiveStatCard("Kcal", _convertStepsToMetric(_todaySteps, "Kcal").toInt().toString(), "kcal", Icons.local_fire_department, Colors.orange)),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(child: _buildInteractiveStatCard("Heart", _convertStepsToMetric(_todaySteps, "Heart").toInt().toString(), "bpm", Icons.favorite, Colors.red)),
                  const SizedBox(width: 7),
                  Expanded(child: _buildInteractiveStatCard("Distance", _convertStepsToMetric(_todaySteps, "Distance").toStringAsFixed(2), "km", Icons.map, Colors.indigo)),
                ],
              ),

              const SizedBox(height: 24),

              // --- STREAK & PLANS BELOW ---
              _buildStreakCard(currentStreak),
              const SizedBox(height: 20),

              myGymsAsync.when(
                data: (gyms) {
                  if (gyms.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("My Gyms", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        SizedBox(height: 120, child: ListView(scrollDirection: Axis.horizontal, children: gyms.map((g) => _buildOwnerCard(g)).toList())),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Active Membership", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      activeBookingAsync.when(
                        data: (booking) => booking == null ? _buildEmptyPlanCard() : _buildActivePlanCard(context, booking),
                        loading: () => const Center(child: CircularProgressIndicator(color: neonGreen)),
                        error: (e, _) => const SizedBox(),
                      )
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade700)),
      child: Row(
        children: ["Day", "Week", "Month"].map((p) => GestureDetector(
          onTap: () => setState(() { _selectedPeriod = p; _focusedIndex = null; }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedPeriod == p ? neonGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(p, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _selectedPeriod == p ? Colors.black : Colors.grey)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInteractiveStatCard(String metric, String v, String u, IconData i, Color color) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMetric = metric;
        _focusedIndex = null;
      }),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: isSelected ? neonGreen.withOpacity(0.1) : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? neonGreen : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 14, backgroundColor: isSelected ? neonGreen.withOpacity(0.2) : color.withOpacity(0.1), child: Icon(i, color: isSelected ? neonGreen : color, size: 14)),
                const SizedBox(height: 8),
                Text(metric, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                RichText(text: TextSpan(text: v, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), children: [TextSpan(text: " $u", style: const TextStyle(fontSize: 10, color: Colors.grey))]))
              ]
          )
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak) {
    final todayIndex = DateTime.now().weekday - 1;
    return GestureDetector(
      onTap: _editDailyGoal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.local_fire_department, color: currentStreak > 0 ? Colors.orange : Colors.grey, size: 18),
                    const SizedBox(width: 5),
                    const Icon(Icons.edit, size: 12, color: Colors.white38)
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    currentStreak > 0 ? "$currentStreak Day Streak!" : "Hit $_dailyGoal steps to ignite!",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (i) {
                final isDayMet = _weekData[i] >= _dailyGoal;
                final isFuture = i > todayIndex;
                Color dotColor;
                if (isFuture) dotColor = Colors.white10;
                else if (isDayMet) dotColor = neonGreen;
                else dotColor = Colors.grey.shade800;

                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 5, color: isDayMet && !isFuture ? Colors.black : Colors.transparent),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  // --- UPDATED: Shorter Card Height (Reduced Padding & Spacing) ---
  Widget _buildActivePlanCard(BuildContext context, Map<String, dynamic> booking) {
    final daysLeft = DateTime.parse(booking['expiryDate']).difference(DateTime.now()).inDays;
    final planName = booking['plan'].toString();

    Color cardColor = Colors.grey.shade800;
    if (planName.contains("Silver")) cardColor = const Color(0xFFC0C0C0);
    else if (planName.contains("Gold")) cardColor = const Color(0xFFFFD54F);
    else if (planName.contains("Platinum")) cardColor = const Color(0xFF4FC3F7);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivePlanScreen(booking: booking, bookingId: booking['id'] ?? '', themeColor: Colors.black))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16), // Reduced padding from 24
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15)
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(booking['gymName'], style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w900)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(12)), child: Text(planName.toUpperCase(), style: const TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12), // Reduced spacing from 24
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("TIME SLOT", style: TextStyle(color: Colors.black54, fontSize: 8, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(booking['slot'].toString().split(' ').first, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 10))]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("TAP FOR DETAILS", style: TextStyle(color: Colors.black54, fontSize: 8, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Row(children: [Text("$daysLeft Days Left", style: const TextStyle(color: Colors.black87,fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(width: 4), const Icon(Icons.arrow_forward_ios, color: Colors.black87, size: 10)])]),
          ]),
        ]),
      ),
    );
  }

  // Also reduced padding here for consistency
  Widget _buildEmptyPlanCard() => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade800)), child: Column(children: [Icon(Icons.card_membership, size: 40, color: Colors.grey.shade600), const SizedBox(height: 10), const Text("No active plan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))]));

  Widget _buildOwnerCard(GymModel g) => Container(width: 220, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis), Text("${GymLogic.getTotalActiveMembers(g.id)} Active Members", style: const TextStyle(color: Colors.white54)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: neonGreen, borderRadius: BorderRadius.circular(8)), child: Text("RATING ${g.rating}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)))]));
}