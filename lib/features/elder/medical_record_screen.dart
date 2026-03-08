import 'package:flutter/material.dart';
import 'elder_service.dart';
import '../auth/theme.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  late Future<Map<String, dynamic>> _medicalProfileFuture;
  Map<String, dynamic>? _editableData;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _medicalProfileFuture = ElderService.getMedicalProfile().then((data) {
      setState(() {
        _editableData = Map<String, dynamic>.from(data);
      });
      return data;
    });
  }

  Future<void> _updateMedicalProfile() async {
    if (_editableData == null) return;

    setState(() => _isSaving = true);

    try {
      final elderId = _editableData!['elder_id'] ?? _editableData!['id'];
      if (elderId == null) throw Exception("Elder ID not found");

      // We use the same structure as the creation but as a patch/update if possible, 
      // or using the patchElderDetails if that's the intended way.
      // Based on ElderService, let's see what's available.
      
      final payload = {
        "blood_type": _editableData!['blood_type'] ?? _editableData!['BloodType'] ?? "",
        "allergies": _editableData!['allergies'] ?? _editableData!['Allergies'] ?? "",
        "chronic_conditions": _editableData!['chronic_conditions'] ?? _editableData!['ChronicConditions'] ?? "",
        "emergency_notes": _editableData!['emergency_notes'] ?? _editableData!['EmergencyNotes'] ?? "",
        "past_surgeries": _editableData!['past_surgeries'] ?? _editableData!['PastSurgeries'] ?? "",
      };

      await ElderService.patchElderDetails(elderId: elderId is int ? elderId : int.parse(elderId.toString()), data: payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medical profile updated successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showEditDialog(String title, List<String> keys, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Edit $title", style: const TextStyle(color: AppColors.primary)),
        content: TextField(
          controller: controller,
          maxLines: title == "Blood Type" ? 1 : null,
          decoration: InputDecoration(
            hintText: "Enter $title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                for (var key in keys) {
                  if (_editableData!.containsKey(key)) {
                    _editableData![key] = controller.text;
                  }
                }
                // If none of the keys existed, add the first one
                if (!keys.any((k) => _editableData!.containsKey(k))) {
                  _editableData![keys.first] = controller.text;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Medical Background", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _medicalProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _editableData == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError && _editableData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _loadData()),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),
            );
          }

          final displayData = _editableData ?? {};

          String getValue(List<String> keys) {
            for (var key in keys) {
              if (displayData.containsKey(key) && displayData[key] != null) {
                return displayData[key].toString();
              }
            }
            return "None";
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildEditableCard(
                      "Blood Type",
                      getValue(['blood_type', 'BloodType', 'bloodType']),
                      ['blood_type', 'BloodType', 'bloodType'],
                      Icons.bloodtype,
                      isExpandable: false,
                    ),
                    _buildEditableCard(
                      "Allergies",
                      getValue(['allergies', 'Allergies']),
                      ['allergies', 'Allergies'],
                      Icons.warning_amber,
                    ),
                    _buildEditableCard(
                      "Chronic Conditions",
                      getValue(['chronic_conditions', 'ChronicConditions', 'chronicConditions']),
                      ['chronic_conditions', 'ChronicConditions', 'chronicConditions'],
                      Icons.history,
                    ),
                    _buildEditableCard(
                      "Past Surgeries",
                      getValue(['past_surgeries', 'PastSurgeries', 'pastSurgeries']),
                      ['past_surgeries', 'PastSurgeries', 'pastSurgeries'],
                      Icons.medical_services,
                    ),
                    _buildEditableCard(
                      "Emergency Notes",
                      getValue(['emergency_notes', 'EmergencyNotes', 'emergencyNotes']),
                      ['emergency_notes', 'EmergencyNotes', 'emergencyNotes'],
                      Icons.note_alt,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : _updateMedicalProfile,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Update", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditableCard(String title, String value, List<String> keys, IconData icon, {bool isExpandable = true}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _showEditDialog(title, keys, value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, color: AppColors.descriptionText)),
                    const SizedBox(height: 4),
                    isExpandable ? ExpandableText(text: value) : Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  ],
                ),
              ),
              const Icon(Icons.edit, size: 18, color: AppColors.descriptionText),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({super.key, required this.text, this.maxLines = 2});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText);

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(widget.text, style: textStyle);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: isExpanded ? null : widget.maxLines,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: textStyle,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Text(
                isExpanded ? "Read Less" : "Read More",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
