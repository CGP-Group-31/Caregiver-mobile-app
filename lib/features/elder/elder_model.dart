class ElderModel {
  final int id;
  final String name;
  final String address;
  final String gender;
  final String dateOfBirth;

  ElderModel({
    required this.id,
    required this.name,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
  });

  factory ElderModel.fromJson(Map<String, dynamic> json) {
    return ElderModel(
      id: json['id'] ?? json['UserID'] ?? 0,
      name: json['full_name'] ?? json['FullName'] ?? json['name'] ?? 'N/A',
      address: json['address'] ?? json['Address'] ?? 'N/A',
      gender: json['gender'] ?? json['Gender'] ?? 'N/A',
      dateOfBirth: json['date_of_birth'] ?? json['DateOfBirth'] ?? '',
    );
  }
}
