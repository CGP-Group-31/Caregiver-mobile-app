class ElderModel {
  final int id;
  final String name;
  final String address;
  final String gender;
  final String dateOfBirth;
  final String phone;
  final String relationship;
  final String email;

  ElderModel({
    required this.id,
    required this.name,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.relationship,
    required this.email,
  });

  factory ElderModel.fromJson(Map<String, dynamic> json) {
    return ElderModel(
      // CRITICAL FIX: Checking every possible name for the ID field
      id: json['id'] ?? 
          json['elder_id'] ?? 
          json['user_id'] ?? 
          json['UserID'] ?? 
          json['ElderID'] ?? 
          json['elderId'] ?? 0,
      name: (json['full_name'] ?? json['FullName'] ?? json['name'] ?? 'N/A').toString(),
      address: (json['address'] ?? json['Address'] ?? 'N/A').toString(),
      gender: (json['gender'] ?? json['Gender'] ?? 'N/A').toString(),
      dateOfBirth: (json['date_of_birth'] ?? json['DateOfBirth'] ?? '').toString(),
      phone: (json['phone'] ?? json['Phone'] ?? 'N/A').toString(),
      relationship: (json['relationship_type'] ?? json['Relationship'] ?? 'N/A').toString(),
      email: (json['email'] ?? json['Email'] ?? 'N/A').toString(),
    );
  }
}
