class ContactModel {
  final String name;
  final String phone;
  final String relation;

  ContactModel({
    required this.name,
    required this.phone,
    required this.relation,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['contact_name'] ?? '',
      phone: json['phone'] ?? '',
      relation: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "contact_name": name,
      "phone": phone,
      "relationship": relation,
    };
  }
}
