class InvitedProprietaire {
  final String id;
  final String reunionId;
  final String proprietaireId;
  final String status;
  final String attendance;
  final bool notificationSent;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String apartmentNumber;

  InvitedProprietaire({
    required this.id,
    required this.reunionId,
    required this.proprietaireId,
    required this.status,
    required this.attendance,
    required this.notificationSent,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.apartmentNumber,
  });

  factory InvitedProprietaire.fromJson(Map<String, dynamic> json) {
    final relationship = json['relationship'];
    final proprietaire = json['proprietaire'];
    
    return InvitedProprietaire(
      id: relationship['id'],
      reunionId: relationship['reunionId'],
      proprietaireId: relationship['proprietaireId'],
      status: relationship['status'],
      attendance: relationship['attendance'],
      notificationSent: relationship['notificationSent'],
      email: proprietaire['email'],
      firstName: proprietaire['firstName'],
      lastName: proprietaire['lastName'],
      phoneNumber: proprietaire['phoneNumber'],
      apartmentNumber: proprietaire['apartmentNumber'],
    );
  }
}