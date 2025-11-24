class User {
  final int id;
  final int? idClinic;
  final String name;
  final String email;
  final String documentType;
  final String documentNumber;
  final String? birthDate;
  final double? appointmentPrice;
  final String type;
  final String situation;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  User({
    required this.id,
    this.idClinic,
    required this.name,
    required this.email,
    required this.documentType,
    required this.documentNumber,
    this.birthDate,
    this.appointmentPrice,
    required this.type,
    required this.situation,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      idClinic: json['id_clinic'],
      name: json['name'],
      email: json['email'],
      documentType: json['document_type'],
      documentNumber: json['document_number'],
      birthDate: json['birth_date'],
      appointmentPrice: json['appointment_price']?.toDouble(),
      type: json['type'],
      situation: json['situation'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_clinic': idClinic,
      'name': name,
      'email': email,
      'document_type': documentType,
      'document_number': documentNumber,
      'birth_date': birthDate,
      'appointment_price': appointmentPrice,
      'type': type,
      'situation': situation,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}