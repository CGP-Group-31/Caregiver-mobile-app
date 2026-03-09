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

  Future<void> pickDate() async {

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if(picked!=null){
      setState(() => appointmentDate = picked);
    }
  }

  Future<void> pickTime() async {

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if(picked!=null){
      setState(() => appointmentTime = picked);
    }
  }

  Future<void> createAppointment() async {

    if(!_formKey.currentState!.validate()) return;

    final elderId = await SessionManager.getElderId();

    setState(()=>loading=true);

    await AppointmentService.createAppointment(
      elderId: elderId!,
      doctorName: doctorCtrl.text,
      title: titleCtrl.text,
      location: locationCtrl.text,
      notes: notesCtrl.text,
      appointmentDate: DateFormat('yyyy-MM-dd').format(appointmentDate!),
      appointmentTime: "${appointmentTime!.hour}:${appointmentTime!.minute}",
    );

    setState(()=>loading=false);

    if(!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Appointment created")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("Create Appointment"),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              _input(doctorCtrl,"Doctor Name"),
              const SizedBox(height:16),

              _input(titleCtrl,"Title"),
              const SizedBox(height:16),

              _input(locationCtrl,"Location"),
              const SizedBox(height:16),

              _input(notesCtrl,"Notes"),
              const SizedBox(height:20),

              ElevatedButton(
                onPressed: pickDate,
                child: Text(
                    appointmentDate==null
                        ? "Select Date"
                        : DateFormat('yyyy-MM-dd').format(appointmentDate!)
                ),
              ),

              const SizedBox(height:10),

              ElevatedButton(
                onPressed: pickTime,
                child: Text(
                    appointmentTime==null
                        ? "Select Time"
                        : "${appointmentTime!.hour}:${appointmentTime!.minute}"
                ),
              ),

              const SizedBox(height:30),

              ElevatedButton(
                onPressed: loading ? null : createAppointment,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Appointment"),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c,String label){

    return TextFormField(
      controller: c,
      validator: (v)=>v!.isEmpty?"Required":null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.sectionBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}