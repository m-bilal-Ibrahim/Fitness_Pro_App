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
  String? _numberValidator(String? v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null;
  String? _imageValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (!v.startsWith('http')) return 'Invalid Link';
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
        title: const Text("Delete Gym?", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("This cannot be undone.", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
        title: Text(isEditing ? "Edit Branch" : "Add New Branch", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: neonGreen, size: 20),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
              _buildCompactInput(_nameController, "Name", Icons.fitness_center, validator: _requiredValidator),
              _buildCompactInput(_imageController, "Image URL", Icons.image, validator: _imageValidator, type: TextInputType.url),
              _buildCompactInput(_addressController, "Address", Icons.location_on, validator: _requiredValidator),
              _buildCompactInput(_descriptionController, "Description", Icons.description, validator: _requiredValidator, maxLines: 3),

              const SizedBox(height: 15),
              _buildSectionTitle("Operations"),

              // Custom Compact Dropdown
              Container(
                height: 45,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    dropdownColor: Colors.grey.shade900,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    isExpanded: true,
                    items: ['open', 'closed', 'maintenance'].map((s) => DropdownMenuItem(value: s, child: Row(children: [
                      const Icon(Icons.info, size: 16, color: Colors.white54),
                      const SizedBox(width: 10),
                      Text(s.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13))
                    ]))).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ),

              Row(children: [
                Expanded(child: _buildCompactInput(_openTimeController, "Opens", Icons.schedule, validator: _requiredValidator)),
                const SizedBox(width: 10),
                Expanded(child: _buildCompactInput(_closeTimeController, "Closes", Icons.schedule, validator: _requiredValidator)),
              ]),
              _buildCompactInput(_capacityController, "Capacity", Icons.groups, validator: _numberValidator, type: TextInputType.number),

              const SizedBox(height: 15),
              _buildSectionTitle("Pricing"),
              Row(children: [
                Expanded(child: _buildCompactInput(_silverController, "Silver (Wk)", Icons.attach_money, validator: _numberValidator, type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildCompactInput(_goldController, "Gold (Mo)", Icons.attach_money, validator: _numberValidator, type: TextInputType.number)),
              ]),
              Row(children: [
                Expanded(child: _buildCompactInput(_platinumController, "Platinum (Yr)", Icons.attach_money, validator: _numberValidator, type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildCompactInput(_trainerController, "Trainer Fee", Icons.person_add, validator: _numberValidator, type: TextInputType.number)),
              ]),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45, // Compact Button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: _isLoading ? null : _saveGym,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : Text(isEditing ? "UPDATE GYM" : "SAVE GYM", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)));
  }

  // Helper for Compact Inputs
  Widget _buildCompactInput(TextEditingController ctrl, String label, IconData icon, {String? Function(String?)? validator, TextInputType? type, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: maxLines == 1 ? 45 : null, // Fixed height for single lines
        child: TextFormField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 13), // Smaller Text
          keyboardType: type,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
            floatingLabelStyle: const TextStyle(color: neonGreen),
            prefixIcon: Icon(icon, size: 16, color: Colors.white54), // Smaller Icon
            filled: true,
            fillColor: Colors.grey.shade900,
            isDense: true,
            // Vertical 0 centers text in fixed height container
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: maxLines > 1 ? 12 : 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: neonGreen)),
            errorStyle: const TextStyle(height: 0, fontSize: 0), // Hides error layout shift
          ),
        ),
      ),
    );
  }
}