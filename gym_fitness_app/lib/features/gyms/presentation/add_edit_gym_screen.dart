import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gym_controller.dart';
import '../domain/gym_model.dart';

class AddEditGymScreen extends ConsumerStatefulWidget {
  final GymModel? gymToEdit; // Null = Add, Not Null = Edit

  const AddEditGymScreen({super.key, this.gymToEdit});

  @override
  ConsumerState<AddEditGymScreen> createState() => _AddEditGymScreenState();
}

class _AddEditGymScreenState extends ConsumerState<AddEditGymScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _capacityController;
  late TextEditingController _silverController;
  late TextEditingController _goldController;
  late TextEditingController _platinumController;
  late TextEditingController _trainerController;

  String _status = 'open';
  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  void initState() {
    super.initState();
    final g = widget.gymToEdit;

    // Pre-fill fields if editing
    _nameController = TextEditingController(text: g?.name ?? "");
    _addressController = TextEditingController(text: g?.address ?? "");
    _descriptionController = TextEditingController(text: g?.description ?? "");
    _imageController = TextEditingController(text: g?.images.firstOrNull ?? "");
    _openTimeController = TextEditingController(text: g?.openTime ?? "06:00");
    _closeTimeController = TextEditingController(text: g?.closeTime ?? "22:00");
    _capacityController = TextEditingController(text: g?.slotCapacity.toString() ?? "50");
    _silverController = TextEditingController(text: g?.priceSilver.toString() ?? "20.0");
    _goldController = TextEditingController(text: g?.priceGold.toString() ?? "50.0");
    _platinumController = TextEditingController(text: g?.pricePlatinum.toString() ?? "400.0");
    _trainerController = TextEditingController(text: g?.trainerFee.toString() ?? "15.0");
    _status = g?.status ?? 'open';
  }

  // --- VALIDATORS ---
  String? _requiredValidator(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _numberValidator(String? v) => (v == null || double.tryParse(v) == null) ? 'Invalid Number' : null;
  String? _imageValidator(String? v) {
    if (v == null || v.isEmpty) return 'Image URL is mandatory';
    if (!v.startsWith('http')) return 'Must be a valid link';
    return null;
  }

  Future<void> _saveGym() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(gymControllerProvider).createOrUpdateGym(
        existingId: widget.gymToEdit?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        status: _status,
        openTime: _openTimeController.text.trim(),
        closeTime: _closeTimeController.text.trim(),
        slotCapacity: int.parse(_capacityController.text.trim()),
        priceSilver: double.parse(_silverController.text.trim()),
        priceGold: double.parse(_goldController.text.trim()),
        pricePlatinum: double.parse(_platinumController.text.trim()),
        trainerFee: double.parse(_trainerController.text.trim()),
        images: [_imageController.text.trim()],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gym Saved!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGym() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text("Delete Gym?", style: TextStyle(color: Colors.white)),
        content: const Text("This cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await ref.read(gymControllerProvider).deleteGym(widget.gymToEdit!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gymToEdit != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Branch" : "Add New Branch", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: neonGreen),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _deleteGym,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Basic Info"),
              TextFormField(controller: _nameController, decoration: _inputDec("Name", Icons.fitness_center), validator: _requiredValidator, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              TextFormField(controller: _imageController, decoration: _inputDec("Image URL", Icons.image), validator: _imageValidator, keyboardType: TextInputType.url, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              TextFormField(controller: _addressController, decoration: _inputDec("Address", Icons.location_on), validator: _requiredValidator, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              TextFormField(controller: _descriptionController, decoration: _inputDec("Description", Icons.description), maxLines: 3, validator: _requiredValidator, style: const TextStyle(color: Colors.white)),

              const SizedBox(height: 20),
              _buildSectionTitle("Operations"),
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: Colors.grey.shade900,
                items: ['open', 'closed', 'maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase(), style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: _inputDec("Status", Icons.info),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _openTimeController, decoration: _inputDec("Opens", Icons.schedule), validator: _requiredValidator, style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _closeTimeController, decoration: _inputDec("Closes", Icons.schedule), validator: _requiredValidator, style: const TextStyle(color: Colors.white))),
              ]),
              const SizedBox(height: 10),
              TextFormField(controller: _capacityController, decoration: _inputDec("Capacity", Icons.groups), validator: _numberValidator, style: const TextStyle(color: Colors.white)),

              const SizedBox(height: 20),
              _buildSectionTitle("Pricing"),
              Row(children: [
                Expanded(child: TextFormField(controller: _silverController, decoration: _inputDec("Silver (Weekly)", Icons.attach_money), validator: _numberValidator, style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _goldController, decoration: _inputDec("Gold (Monthly)", Icons.attach_money), validator: _numberValidator, style: const TextStyle(color: Colors.white))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _platinumController, decoration: _inputDec("Platinum (Yearly)", Icons.attach_money), validator: _numberValidator, style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _trainerController, decoration: _inputDec("Trainer Fee", Icons.person_add), validator: _numberValidator, style: const TextStyle(color: Colors.white))),
              ]),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : _saveGym,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : Text(isEditing ? "UPDATE GYM" : "SAVE GYM", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)));
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, size: 20, color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade900
    );
  }
}