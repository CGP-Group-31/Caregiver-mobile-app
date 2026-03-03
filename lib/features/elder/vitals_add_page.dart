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
    // ✅ caregiver app: elderId comes from session mapping
    final int? elderId = await SessionManager.getElderId();
    if (elderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No elder selected. Please link/select an elder first.")),
      );
      return;
    }

    // ✅ caregiver user id
    final int? caregiverId = await SessionManager.getUserId();
    if (caregiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Caregiver not logged in.")),
      );
      return;
    }

    final selectedTypeId = _selectedTypeId;
    if (selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a vital type.")),
      );
      return;
    }

    final rawValue = _valueController.text.trim();
    final value = double.tryParse(rawValue);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid number value.")),
      );
      return;
    }

    final int recordedBy = caregiverId; // ✅ non-null now

    setState(() => _saving = true);

    try {
      await VitalsApi.addVital(
        elderId: elderId,
        vitalTypeId: selectedTypeId,
        value: value,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        recordedBy: recordedBy,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vital saved")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _unitForSelected() {
    final id = _selectedTypeId;
    final t = _types.where((x) => x["vital_type_id"] == id).toList();
    if (t.isEmpty) return "";
    return (t.first["unit"] ?? "").toString();
  }

  @override
  Widget build(BuildContext context) {
    final unit = _unitForSelected();

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Add Vital"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.containerBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sectionSeparator),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedTypeId,
                  isExpanded: true,
                  items: _types.map((t) {
                    final id = t["vital_type_id"] as int;
                    final name = (t["vital_name"] ?? "").toString();
                    final u = (t["unit"] ?? "").toString();
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(u.isEmpty ? name : "$name ($u)"),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedTypeId = v),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.containerBackground,
                hintText: unit.isEmpty ? "Value" : "Value ($unit)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.containerBackground,
                hintText: "Notes (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(_saving ? "Saving..." : "Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}