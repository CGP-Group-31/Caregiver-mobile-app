import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/session/session_manager.dart';
import '../auth/theme.dart';
import 'appointment_service.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {

  final _formKey = GlobalKey<FormState>();

  final doctorCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;

  bool loading = false;

  bool showDateError = false;
  bool showTimeError = false;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        appointmentDate = picked;
        showDateError = false;
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        appointmentTime = picked;
        showTimeError = false;
      });
    }
  }

  Future<void> createAppointment() async {

    if (!_formKey.currentState!.validate()) return;

    if (appointmentDate == null) {
      setState(() => showDateError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select appointment date")),
      );
      await pickDate();
      return;
    }

    if (appointmentTime == null) {
      setState(() => showTimeError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select appointment time")),
      );
      await pickTime();
      return;
    }

    final elderId = await SessionManager.getElderId();

    if (elderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Elder ID not found")),
      );
      return;
    }

    final formattedTime =
        "${appointmentTime!.hour.toString().padLeft(2, '0')}:"
        "${appointmentTime!.minute.toString().padLeft(2, '0')}";

    setState(() => loading = true);

    try {
      await AppointmentService.createAppointment(
        elderId: elderId,
        doctorName: doctorCtrl.text,
        title: titleCtrl.text,
        location: locationCtrl.text,
        notes: notesCtrl.text,
        appointmentDate: DateFormat('yyyy-MM-dd').format(appointmentDate!),
        appointmentTime: formattedTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment created successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Create Appointments",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0,5),
                )
              ],
            ),

            child: Form(
              key: _formKey,

              child: ListView(
                children: [

                  const Text(
                    "Doctor Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _input(doctorCtrl,"Doctor Name"),

                  const SizedBox(height:16),

                  _input(titleCtrl,"Title"),

                  const SizedBox(height:16),

                  _input(locationCtrl,"Hospital Name"),

                  const SizedBox(height:16),

                  TextFormField(
                    controller: notesCtrl,
                    maxLength: 200,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    decoration: _inputDecoration("Notes"),
                  ),

                  const SizedBox(height:30),

                  const Text(
                    "Appointment Schedule",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height:15),

                  _dateTile(
                    icon: Icons.calendar_today,
                    title: appointmentDate==null
                        ? "Select Date"
                        : DateFormat('yyyy-MM-dd').format(appointmentDate!),
                    onTap: pickDate,
                    showError: showDateError,
                    errorText: "Date is required",
                  ),

                  const SizedBox(height:12),

                  _dateTile(
                    icon: Icons.access_time,
                    title: appointmentTime==null
                        ? "Select Time"
                        : "${appointmentTime!.hour.toString().padLeft(2,'0')}:${appointmentTime!.minute.toString().padLeft(2,'0')}",
                    onTap: pickTime,
                    showError: showTimeError,
                    errorText: "Time is required",
                  ),

                  const SizedBox(height:30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical:14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: loading ? null : createAppointment,

                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Create Appointment",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c,String label){

    return TextFormField(
      controller: c,
      validator: (v)=>v!.isEmpty?"Required":null,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label){
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textShade),
      filled: true,
      fillColor: AppColors.sectionBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal:16,vertical:14),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showError,
    required String errorText,
  }){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          decoration: BoxDecoration(
            color: AppColors.sectionBackground,
            borderRadius: BorderRadius.circular(14),
            border: showError
                ? Border.all(color: Colors.red)
                : null,
          ),

          child: ListTile(
            leading: Icon(icon,color: AppColors.primary),
            title: Text(title),
            onTap: onTap,
          ),
        ),

        if(showError)
          Padding(
            padding: const EdgeInsets.only(left:12, top:4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
      ],
    );
  }
}