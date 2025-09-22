import 'appointment.dart';
import 'psychologist.dart';

class Package {
  final int id;
  final int patientId;
  final int psychologistId;
  final int totalAppointments;
  final String price;
  final int balance;
  final String paymentMethod;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final Psychologist psychologist;
  final Patient? patient;
  final List<Appointment> appointments;

  Package({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.totalAppointments,
    required this.price,
    required this.balance,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.psychologist,
    this.patient,
    required this.appointments,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      patientId: json['patient_id'],
      psychologistId: json['psychologist_id'],
      totalAppointments: json['total_appointments'],
      price: json['price'],
      balance: json['balance'],
      paymentMethod: json['payment_method'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      psychologist: Psychologist.fromJson(json['psychologist']),
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      appointments: (json['appointments'] as List<dynamic>? ?? [])
          .map((appointment) => Appointment.fromJson(appointment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'psychologist_id': psychologistId,
      'total_appointments': totalAppointments,
      'price': price,
      'balance': balance,
      'payment_method': paymentMethod,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'psychologist': psychologist.toJson(),
      'patient': patient?.toJson(),
      'appointments': appointments.map((appointment) => appointment.toJson()).toList(),
    };
  }
}

class Patient {
  final int id;
  final int? idClinic;
  final String name;
  final String email;
  final String documentType;
  final String documentNumber;
  final String? birthDate;
  final double? appointmentPrice;
  final String type;
  final String? situation;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Patient({
    required this.id,
    this.idClinic,
    required this.name,
    required this.email,
    required this.documentType,
    required this.documentNumber,
    this.birthDate,
    this.appointmentPrice,
    required this.type,
    this.situation,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
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