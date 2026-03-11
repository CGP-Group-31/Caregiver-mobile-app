import 'package:flutter/material.dart';
//import 'package:dio/dio.dart';

import 'medicine_reminders_screen.dart';
import 'doctor_service.dart';
import '../../../core/network/dio_client.dart';
import 'theme.dart';

class MedicalDetailsScreen extends StatefulWidget {
  final int elderId;

  const MedicalDetailsScreen({super.key, required this.elderId});

  @override
  State<MedicalDetailsScreen> createState() => _MedicalDetailsScreenState();
}

class _MedicalDetailsScreenState extends State<MedicalDetailsScreen> {

  final _formKey = GlobalKey<FormState>();

  String? bloodType;

  final allergiesCtrl = TextEditingController();
  final chronicCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final surgeriesCtrl = TextEditingController();
  final preferredDoctorCtrl = TextEditingController();

  DoctorItem? selectedDoctor;

  bool loading = false;

  final List<String> bloodTypes = const [
    "A+","A-","B+","B-","O+","O-","AB+","AB-","Unknown"
  ];

  @override
  void dispose() {
    allergiesCtrl.dispose();
    chronicCtrl.dispose();
    notesCtrl.dispose();
    surgeriesCtrl.dispose();
    preferredDoctorCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint,{Widget? suffix,Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.descriptionText,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.containerBackground,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal:18,vertical:18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.textShade.withValues(alpha:0.30),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary,width:1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent,width:1.6),
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius:14,
            offset: const Offset(0,6),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _stepDots() {
    const int total = 6;
    const int active = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total,(i){
        final filled = i < active;
        return Container(
          width:10,
          height:10,
          margin: const EdgeInsets.symmetric(horizontal:6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColors.primaryText
                : AppColors.textShade.withValues(alpha:0.35),
          ),
        );
      }),
    );
  }

  String? _allergyValidator(String? v){
    final t=v?.trim()??"";
    if(t.isEmpty) return null;
    if(!RegExp(r'^[A-Za-z\s,]+$').hasMatch(t)){
      return "Allergies can contain letters only";
    }
    if(t.length>120) return "Too long";
    return null;
  }

  String? _chronicValidator(String? v){
    final t=v?.trim()??"";
    if(t.isEmpty) return null;
    if(!RegExp(r'^[A-Za-z0-9\s,]+$').hasMatch(t)){
      return "No symbols allowed";
    }
    if(t.length>140) return "Too long";
    return null;
  }

  String? _notesValidator(String? v){
    final t=v?.trim()??"";
    if(t.isEmpty) return null;
    if(!RegExp(r'^[A-Za-z\s,]+$').hasMatch(t)){
      return "Notes must contain letters only";
    }
    if(t.length>200) return "Too long";
    return null;
  }

  String? _surgeryValidator(String? v){
    final t=v?.trim()??"";
    if(t.isEmpty) return null;
    if(!RegExp(r'^[A-Za-z0-9\s,]+$').hasMatch(t)){
      return "No symbols allowed";
    }
    if(t.length>200) return "Too long";
    return null;
  }

  Future<void> _openDoctorSearch() async {
    FocusScope.of(context).unfocus();

    final picked = await Navigator.push<DoctorItem?>(
      context,
      MaterialPageRoute(
        builder: (_) => const DoctorSearchPage(),
      ),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        selectedDoctor = picked;
        preferredDoctorCtrl.text = picked.fullName;
      });
    }
  }

  Future<void> _submitMedicalDetailsToApi() async {
    final dio = DioClient.dio;

    final payload = {
      "elder_id": widget.elderId,
      "blood_type": bloodType ?? "",
      "allergies": allergiesCtrl.text.trim(),
      "chronic_conditions": chronicCtrl.text.trim(),
      "emergency_notes": notesCtrl.text.trim(),
      "past_surgeries": surgeriesCtrl.text.trim(),
      "preferred_doctor_id": selectedDoctor?.doctorId ?? 0,
    };

    final res = await dio.post(
      "/api/v1/caregiver/elder-create/elder-profile",
      data: payload,
    );

    final ok = res.statusCode!=null && res.statusCode!>=200 && res.statusCode!<300;

    if(!ok){
      throw Exception("Failed");
    }
  }

  Future<void> _continue() async {

    FocusScope.of(context).unfocus();

    if(!(_formKey.currentState?.validate()??false)) return;

    if(selectedDoctor==null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:Text("Please select a doctor")),
      );
      return;
    }

    setState(()=>loading=true);

    try{

      await _submitMedicalDetailsToApi();

      if(!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:(_)=>MedicineRemindersScreen(elderId:widget.elderId),
        ),
      );

    }catch(e){

      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text(e.toString().replaceFirst("Exception: ",""))),
      );
    }

    if(mounted) setState(()=>loading=false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:0,
        title: const Text(
          "Medical Details",
          style: TextStyle(fontWeight:FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18,18,18,18),
          child: Column(
            children:[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.sectionBackground.withValues(alpha:0.35),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.textShade.withValues(alpha:0.20),
                      ),
                      boxShadow:[
                        BoxShadow(
                          color:Colors.black.withValues(alpha:0.05),
                          blurRadius:18,
                          offset: const Offset(0,8),
                        )
                      ],
                    ),
                    child: Form(
                      key:_formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children:[

                          _fieldCard(
                            child: DropdownButtonFormField<String>(
                              initialValue: bloodType,
                              items: bloodTypes.map((b)=>DropdownMenuItem(
                                value:b,
                                child:Text(
                                  b,
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )).toList(),
                              onChanged:(v)=>setState(()=>bloodType=v),
                              decoration:_decor(
                                "Blood Type",
                                prefix: const Icon(Icons.bloodtype_outlined),
                              ),
                              validator:(v)=>v==null?"Please select blood type":null,
                            ),
                          ),

                          const SizedBox(height:14),

                          _fieldCard(
                            child: TextFormField(
                              controller: allergiesCtrl,
                              decoration:_decor(
                                "Allergies",
                                prefix: const Icon(Icons.warning_amber_outlined),
                              ),
                              validator:_allergyValidator,
                            ),
                          ),

                          const SizedBox(height:14),

                          _fieldCard(
                            child: TextFormField(
                              controller: chronicCtrl,
                              decoration:_decor(
                                "Chronic Conditions",
                                prefix: const Icon(Icons.healing_outlined),
                              ),
                              validator:_chronicValidator,
                            ),
                          ),

                          const SizedBox(height:14),

                          _fieldCard(
                            child: TextFormField(
                              controller: notesCtrl,
                              maxLines:2,
                              decoration:_decor(
                                "Emergency Notes",
                                prefix: const Icon(Icons.note_alt_outlined),
                              ),
                              validator:_notesValidator,
                            ),
                          ),

                          const SizedBox(height:14),

                          _fieldCard(
                            child: TextFormField(
                              controller: surgeriesCtrl,
                              maxLines:2,
                              decoration:_decor(
                                "Past Surgeries",
                                prefix: const Icon(Icons.local_hospital_outlined),
                              ),
                              validator:_surgeryValidator,
                            ),
                          ),

                          const SizedBox(height:14),

                          _fieldCard(
                            child: TextFormField(
                              controller: preferredDoctorCtrl,
                              readOnly:true,
                              onTap:_openDoctorSearch,
                              decoration:_decor(
                                "Preferred Doctor",
                                prefix: const Icon(Icons.medical_services_outlined),
                                suffix: const Icon(Icons.search),
                              ),
                              validator:(v){
                                if(selectedDoctor==null){
                                  return "Please select a doctor";
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height:22),

                          SizedBox(
                            width:double.infinity,
                            height:54,
                            child: ElevatedButton(
                              onPressed:loading?null:_continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:AppColors.primary,
                                shape:RoundedRectangleBorder(
                                  borderRadius:BorderRadius.circular(18),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(color:Colors.white)
                                  : const Text(
                                "Continue",
                                style:TextStyle(
                                  fontSize:16,
                                  fontWeight:FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height:16),
                          _stepDots(),

                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {

  List<DoctorItem> doctors=[];
  List<DoctorItem> filtered=[];
  bool loading=true;

  @override
  void initState(){
    super.initState();
    loadDoctors();
  }

  Future<void> loadDoctors() async{
    final res=await DoctorService.searchDoctors(doctorName:"",hospital:"");
    setState(() {
      doctors=res;
      filtered=res;
      loading=false;
    });
  }

  void search(String q){
    setState(() {
      filtered = doctors
          .where((d)=>d.fullName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor:AppColors.primary,
        title: TextField(
          style: const TextStyle(color:Colors.white),
          decoration: const InputDecoration(
            hintText:"Search Doctor",
            hintStyle:TextStyle(color:Colors.white70),
            prefixIcon:Icon(Icons.search,color:Colors.white),
            border:InputBorder.none,
          ),
          onChanged:search,
        ),
      ),
      body: loading
          ? const Center(child:CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder:(c,i){
          final d=filtered[i];
          return Card(
            shape:RoundedRectangleBorder(
              borderRadius:BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom:12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:AppColors.primary.withValues(alpha:0.15),
                child: const Icon(Icons.person,color:AppColors.primary),
              ),
              title:Text(d.fullName),
              subtitle:Text(d.specialization),
              trailing: const Icon(Icons.chevron_right),
              onTap:()=>Navigator.pop(context,d),
            ),
          );
        },
      ),
    );
  }
}