class Appointment {
  final int id;
  final int clinicId;
  final int patientId;
  final int psychologistId;
  final int packageId;
  final String status;
  final String? medicalRecord;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;
  final String dtAvailability;
  final String hrAvailability;

  Appointment({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.psychologistId,
    required this.packageId,
    required this.status,
    this.medicalRecord,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.dtAvailability,
    required this.hrAvailability,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      clinicId: json['clinic_id'],
      patientId: json['patient_id'],
      psychologistId: json['psychologist_id'],
      packageId: json['package_id'],
      status: json['status'],
      medicalRecord: json['medical_record'],
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dtAvailability: json['dt_Availability'],
      hrAvailability: json['hr_Availability'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'patient_id': patientId,
      'psychologist_id': psychologistId,
      'package_id': packageId,
      'status': status,
      'medical_record': medicalRecord,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'dt_Availability': dtAvailability,
      'hr_Availability': hrAvailability,
    };
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(dtAvailability);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dtAvailability;
    }
  }

  String get formattedTime {
    return hrAvailability;
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Concluída';
      case 'scheduled':
        return 'Agendada';
      case 'cancelled':
        return 'Cancelada';
      case 'no_show':
        return 'Faltou';
      default:
        return status;
    }
  }

  String get paymentStatusText {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'Pago';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelado';
      default:
        return paymentStatus;
    }
  }
}