class Availability {
  final int id;
  final int idPsychologist;
  final int? idAppointments;
  final String status;
  final String dtAvailability;
  final String hrAvailability;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Availability({
    required this.id,
    required this.idPsychologist,
    this.idAppointments,
    required this.status,
    required this.dtAvailability,
    required this.hrAvailability,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],
      idPsychologist: json['id_psychologist'],
      idAppointments: json['id_appointments'],
      status: json['status'],
      dtAvailability: json['dt_Availability'],
      hrAvailability: json['hr_Availability'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_psychologist': idPsychologist,
      'id_appointments': idAppointments,
      'status': status,
      'dt_Availability': dtAvailability,
      'hr_Availability': hrAvailability,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Método para formatar a data de forma mais legível
  String get formattedDate {
    try {
      final date = DateTime.parse(dtAvailability);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dtAvailability;
    }
  }

  // Método para formatar o horário de forma mais legível
  String get formattedTime {
    return hrAvailability;
  }

  // Método para obter DateTime combinando data e hora
  DateTime get dateTime {
    try {
      final date = DateTime.parse(dtAvailability);
      final timeParts = hrAvailability.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return DateTime.parse(dtAvailability);
    }
  }
}