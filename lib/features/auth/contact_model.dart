class ContactModel {
  final String name;
  final String phone;
  final String relation;
  final bool isPrimary;

  ContactModel({
    required this.name,
    required this.phone,
    required this.relation,
    required this.isPrimary,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['contact_name'] ?? '',
      phone: json['phone'] ?? '',
      relation: json['relationship'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "contact_name": name,
      "phone": phone,
      "relationship": relation,
      "is_primary": isPrimary,
    };
  }
}
