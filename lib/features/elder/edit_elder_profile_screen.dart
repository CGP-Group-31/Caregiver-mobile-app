import 'package:flutter/material.dart';
import 'elder_model.dart';
import 'elder_service.dart';
import '../auth/theme.dart';

class EditElderProfileScreen extends StatefulWidget {
  final ElderModel elder;
  const EditElderProfileScreen({super.key, required this.elder});

  @override
  State<EditElderProfileScreen> createState() => _EditElderProfileScreenState();
}

class _EditElderProfileScreenState extends State<EditElderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  
  String? _selectedDoctorName;
  int? _selectedDoctorId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.elder.name);
    _phoneController = TextEditingController(text: widget.elder.phone);
    _addressController = TextEditingController(text: widget.elder.address);
    _emailController = TextEditingController(text: widget.elder.email);
    _loadCurrentDoctor();
  }

  Future<void> _loadCurrentDoctor() async {
    try {
      final docData = await ElderService.getPreferredDoctor();
      if (mounted) {
        setState(() {
          _selectedDoctorName = docData['DoctorName'] ?? docData['full_name'] ?? docData['doctor_name'] ?? docData['name'];
          _selectedDoctorId = docData['PreferredDoctorID'] ?? docData['id'] ?? docData['doctor_id'];
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _openDoctorSearch() async {
    final Map<String, dynamic>? result = await showSearch<Map<String, dynamic>?>(
      context: context,
      delegate: DoctorSearchDelegate(),
    );
    
    if (result != null) {
      setState(() {
        _selectedDoctorId = result['id'];
        _selectedDoctorName = result['name'];
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileData = {
        "full_name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "email": _emailController.text.trim(),
      };

      await ElderService.patchElderDetails(
        elderId: widget.elder.id, 
        data: profileData,
      );

      if (_selectedDoctorId != null) {
        await ElderService.updatePreferredDoctor(
          elderId: widget.elder.id,
          doctorId: _selectedDoctorId!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text("Elder Details Info", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("General Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              const SizedBox(height: 20),
              // CHANGED: Full Name is now read-only (locked)
              _buildReadOnlyField("Full Name", widget.elder.name, Icons.person_outline),
              const SizedBox(height: 16),
              _buildEditField("Email", _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildEditField("Phone", _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildReadOnlyField("Date of Birth", widget.elder.dateOfBirth, Icons.calendar_today_outlined),
              const SizedBox(height: 16),
              _buildReadOnlyField("Gender", widget.elder.gender, Icons.wc_outlined),
              const SizedBox(height: 16),
              _buildEditField("Address", _addressController, Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 24),
              const Text("Healthcare Provider", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              const SizedBox(height: 16),
              _buildDoctorField(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Update Profile", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorField() {
    return InkWell(
      onTap: _openDoctorSearch,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textShade.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Preferred Doctor", style: TextStyle(fontSize: 12, color: AppColors.descriptionText)),
                  Text(_selectedDoctorName ?? "Tap to assign a doctor", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                ],
              ),
            ),
            const Icon(Icons.search, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.descriptionText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.textShade.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.textShade.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.descriptionText)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.sectionBackground.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.sectionSeparator.withOpacity(0.5))),
          child: Row(
            children: [
              Icon(icon, color: AppColors.descriptionText, size: 22),
              const SizedBox(width: 12),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
              const Spacer(),
              const Icon(Icons.lock_outline, size: 18, color: AppColors.descriptionText),
            ],
          ),
        ),
      ],
    );
  }
}

class DoctorSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  String get searchFieldLabel => "Search doctor name";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear, color: Colors.white), onPressed: () => query = "")
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white), 
    onPressed: () => close(context, null)
  );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.sectionSeparator),
            SizedBox(height: 16),
            Text("Search for a doctor by name or hospital", style: TextStyle(color: AppColors.descriptionText)),
          ],
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: ElderService.searchDoctors(name: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final docs = snapshot.data ?? [];
        if (docs.isEmpty) return const Center(child: Text("No doctors found", style: TextStyle(color: AppColors.descriptionText)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final name = doc['full_name'] ?? doc['doctor_name'] ?? doc['name'] ?? doc['FullName'] ?? 'Unknown Doctor';
            final id = doc['DoctorID'] ?? doc['id'] ?? doc['doctor_id'];
            final hospital = doc['hospital'] ?? doc['Hospital'] ?? 'General Hospital';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              subtitle: Text(hospital, style: const TextStyle(color: AppColors.descriptionText)),
              onTap: () => close(context, {'id': id, 'name': name}),
            );
          },
        );
      },
    );
  }
}
