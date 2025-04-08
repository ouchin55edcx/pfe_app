class Proprietaire {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String createdAt;
  final String updatedAt;
  final String appartementId;
  final String apartmentNumber;
  final String? buildingId;
  final String ownershipDate;
  final String createdBy;

  Proprietaire({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.appartementId,
    required this.apartmentNumber,
    this.buildingId,
    required this.ownershipDate,
    required this.createdBy,
  });

  factory Proprietaire.fromJson(Map<String, dynamic> json) {
    return Proprietaire(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      appartementId: json['appartementId'],
      apartmentNumber: json['apartmentNumber'],
      buildingId: json['buildingId'],
      ownershipDate: json['ownershipDate'],
      createdBy: json['createdBy'],
    );
  }
}