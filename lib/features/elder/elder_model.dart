import '../../core/utils/encryption_utils.dart';

class ElderModel {
  final int id;
  final String name;
  final String address;
  final String gender;
  final String dateOfBirth;
  final String phone;
  final String relationship;

  ElderModel({
    required this.id,
    required this.name,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.relationship,
  });

  factory ElderModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['full_name'] ?? json['FullName'] ?? json['name'] ?? 'N/A';
    final rawAddress = json['address'] ?? json['Address'] ?? 'N/A';
    final rawGender = json['gender'] ?? json['Gender'] ?? 'N/A';
    final rawPhone = json['phone'] ?? json['Phone'] ?? 'N/A';
    final rawRelation = json['relationship_type'] ?? json['Relationship'] ?? 'N/A';

    return ElderModel(
      id: json['id'] ?? json['UserID'] ?? 0,
      name: EncryptionUtils.decrypt(rawName.toString()),
      address: EncryptionUtils.decrypt(rawAddress.toString()),
      gender: EncryptionUtils.decrypt(rawGender.toString()),
      dateOfBirth: json['date_of_birth'] ?? json['DateOfBirth'] ?? '',
      phone: EncryptionUtils.decrypt(rawPhone.toString()),
      relationship: rawRelation.toString(),
    );
  }
}
