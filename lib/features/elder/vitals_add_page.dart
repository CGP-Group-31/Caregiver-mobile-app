import 'package:flutter/material.dart';
import '../auth/theme.dart';
import '../../core/session/session_manager.dart';
import 'vitals_api.dart';

class VitalsAddPage extends StatefulWidget {
  const VitalsAddPage({super.key});

  @override
  State<VitalsAddPage> createState() => _VitalsAddPageState();
}

class _VitalsAddPageState extends State<VitalsAddPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<Map<String, dynamic>> _types = [];
  int? _selectedTypeId;

  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final types = await VitalsApi.getVitalTypes();
      setState(() {
        _types = types;
        if (_types.isNotEmpty) {
          _selectedTypeId ??= _types.first["vital_type_id"] as int;
        }
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final int? elderId = await SessionManager.getElderId();
    if (elderId == null) {
      _showCustomSnackBar("No elder selected. Please link/select an elder first.", isError: true);
      return;
    }

    final int? caregiverId = await SessionManager.getUserId();
    if (caregiverId == null) {
      _showCustomSnackBar("Caregiver not logged in.", isError: true);
      return;
    }

    final selectedTypeId = _selectedTypeId;
    if (selectedTypeId == null) {
      _showCustomSnackBar("Please select a vital type.", isError: true);
      return;
    }

    final value = double.tryParse(_valueController.text.trim());
    if (value == null) {
      _showCustomSnackBar("Enter a valid number value.", isError: true);
      return;
    }

    setState(() => _saving = true);

    try {
      await VitalsApi.addVital(
        elderId: elderId,
        vitalTypeId: selectedTypeId,
        value: value,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        recordedBy: caregiverId,
      );

      if (!mounted) return;
      _showCustomSnackBar("Vital saved successfully!");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showCustomSnackBar(e.toString().replaceFirst("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _unitForSelected() {
    final id = _selectedTypeId;
    final t = _types.where((x) => x["vital_type_id"] == id).toList();
    if (t.isEmpty) return "";
    return (t.first["unit"] ?? "").toString();
  }

  InputDecoration _inputDecoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.descriptionText, fontWeight: FontWeight.w500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unit = _unitForSelected();

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Add Vital", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "New Measurement",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Select a category and enter the recorded value.",
                          style: TextStyle(fontSize: 14, color: AppColors.descriptionText),
                        ),
                        const SizedBox(height: 32),
                        
                        DropdownButtonFormField<int>(
                          value: _selectedTypeId,
                          decoration: _inputDecoration("Vital Type", icon: Icons.category_rounded),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          items: _types.map((t) {
                            final id = t["vital_type_id"] as int;
                            final name = (t["vital_name"] ?? "").toString();
                            final u = (t["unit"] ?? "").toString();
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(u.isEmpty ? name : "$name ($u)", style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedTypeId = v),
                          validator: (v) => v == null ? "Please select a type" : null,
                        ),
                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _valueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryText),
                          decoration: _inputDecoration(
                            "Value",
                            hint: unit.isEmpty ? "0.0" : "Enter value in $unit",
                            icon: Icons.speed_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return "Value is required";
                            if (double.tryParse(v) == null) return "Invalid number";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: _inputDecoration("Notes", hint: "Any additional observations...", icon: Icons.note_add_rounded),
                        ),
                        const SizedBox(height: 40),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _saving
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Save Measurement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
