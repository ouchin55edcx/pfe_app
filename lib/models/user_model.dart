class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String createdAt;
  final String updatedAt;
  
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class SyndicUser extends User {
  final String company;
  final String licenseNumber;

  SyndicUser({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    required this.company,
    required this.licenseNumber,
  });

  factory SyndicUser.fromJson(Map<String, dynamic> json) {
    return SyndicUser(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      company: json['company'],
      licenseNumber: json['licenseNumber'],
    );
  }
}

class ProprietaireUser extends User {
  ProprietaireUser({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
    required String createdAt,
    required String updatedAt,
  }) : super(
          id: id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          role: role,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ProprietaireUser.fromJson(Map<String, dynamic> json) {
    return ProprietaireUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'proprietaire',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
