import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/gym_model.dart';
import '../domain/gym_logic.dart';
import 'gym_controller.dart';

class GymDetailScreen extends ConsumerStatefulWidget {
  final GymModel gym;
  const GymDetailScreen({super.key, required this.gym});

  @override
  ConsumerState<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends ConsumerState<GymDetailScreen> {
  String? _selectedPlan;
  String? _selectedSlot;
  bool _addTrainer = false;
  final _bankController = TextEditingController();
  static const Color neonGreen = Color(0xFFD0FD3E);

  double get _totalPrice {
    double base = 0;
    if (_selectedPlan == 'Silver') base = widget.gym.priceSilver;
    if (_selectedPlan == 'Gold') base = widget.gym.priceGold;
    if (_selectedPlan == 'Platinum') base = widget.gym.pricePlatinum;
    if (_addTrainer) base += widget.gym.trainerFee;
    return base;
  }

  void _handleJoinAttempt() {
    if (_selectedPlan == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Plan & Slot first!")));
      return;
    }

    final activeBooking = ref.read(userActiveBookingProvider).value;

    if (activeBooking != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text("Active Plan Found", style: TextStyle(color: Colors.white)),
          content: Text("You are currently subscribed to ${activeBooking['gymName']}.\n\nYou cannot have two active plans. Do you want to CANCEL your current plan and subscribe to this new one?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No, Keep Current")),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  // Calls the updated method in GymController
                  await ref.read(gymControllerProvider).cancelBooking(activeBooking['id']);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Previous plan cancelled.")));
                    _showPaymentDialog();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Yes, Replace Plan"),
            ),
          ],
        ),
      );
    } else {
      _showPaymentDialog();
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text("Secure Payment", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Total: \$${_totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: neonGreen)),
          const SizedBox(height: 20),
          TextField(
            controller: _bankController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: "Card Number (16 Digits)", labelStyle: TextStyle(color: Colors.white54), border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card, color: Colors.white54), counterText: "", enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            keyboardType: TextInputType.number,
            maxLength: 16,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
            onPressed: () async {
              if (_bankController.text.length != 16) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card must be 16 digits"), backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(ctx);
              try {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Processing...")));
                await ref.read(gymControllerProvider).joinGym(
                  gym: widget.gym, planName: _selectedPlan!, price: _totalPrice,
                  timeSlot: _selectedSlot!.split(' (').first, hasTrainer: _addTrainer,
                  bankAccountNumber: _bankController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membership Active! Check Dashboard.")));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("PAY & JOIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = widget.gym;
    final bookingsAsync = ref.watch(gymBookingsProvider(gym.id));

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250, pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: neonGreen),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(gym.name, style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Image.network(gym.images.first, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.location_on, color: Colors.white54), const SizedBox(width: 5), Text(gym.address, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white))]),
                const SizedBox(height: 12),
                Text(gym.description, style: const TextStyle(color: Colors.white54, height: 1.4)),
                const Divider(height: 40, color: Colors.white10),
                const Text("1. Select Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                _planCard("Silver", "Weekly Access", gym.priceSilver),
                _planCard("Gold", "Monthly Access", gym.priceGold),
                _planCard("Platinum", "Yearly Access", gym.pricePlatinum),
                const SizedBox(height: 30),
                const Text("2. Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                bookingsAsync.when(
                  data: (bookings) {
                    final slotCounts = GymLogic.getSlotCounts(gym.id);
                    final slotLabels = GymLogic.getSlotLabels(gym.openTime, gym.closeTime);
                    final dropdownItems = <DropdownMenuItem<String>>[];
                    for(int i=0; i<4; i++) {
                      final slotName = slotLabels[i];
                      final total = slotCounts[i] + bookings.where((b) => b['slot'] == slotName).length;
                      dropdownItems.add(DropdownMenuItem(value: slotName, child: Text("$slotName  ($total People)", style: const TextStyle(color: Colors.white))));
                    }
                    return DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey.shade900,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                      ),
                      isExpanded: true,
                      hint: const Text("Choose a time slot...", style: TextStyle(color: Colors.white38)),
                      value: _selectedSlot,
                      items: dropdownItems,
                      onChanged: (v) => setState(() => _selectedSlot = v),
                    );
                  },
                  loading: () => const LinearProgressIndicator(color: neonGreen),
                  error: (_,__) => const Text("Could not load slots", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                SwitchListTile(title: const Text("Add Personal Trainer?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), subtitle: Text("+\$${gym.trainerFee}", style: const TextStyle(color: neonGreen)), value: _addTrainer, activeColor: neonGreen, onChanged: (v) => setState(() => _addTrainer = v)),
                const SizedBox(height: 40),
                SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _handleJoinAttempt, child: Text("PAY \$${_totalPrice.toStringAsFixed(0)} & JOIN", style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(String title, String sub, double price) {
    final isSelected = _selectedPlan == title;
    // Selection Logic: Selected = Neon Green BG, Black Text. Unselected = Dark Grey BG, White Text.
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? neonGreen : Colors.grey.shade900, border: Border.all(color: isSelected ? neonGreen : Colors.white10), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(color: isSelected ? Colors.black54 : Colors.white54, fontSize: 12))]),
          Text("\$$price", style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ),
    );
  }
}