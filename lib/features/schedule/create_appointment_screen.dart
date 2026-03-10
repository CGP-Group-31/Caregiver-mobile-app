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
        centerTitle: true,
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

                  _input(locationCtrl,"Location"),

                  const SizedBox(height:16),

                  _input(notesCtrl,"Notes"),

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
                  ),

                  const SizedBox(height:12),

                  _dateTile(
                    icon: Icons.access_time,
                    title: appointmentTime==null
                        ? "Select Time"
                        : "${appointmentTime!.hour}:${appointmentTime!.minute}",
                    onTap: pickTime,
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

      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }){

    return Container(

      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: Icon(icon,color: AppColors.primary),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}