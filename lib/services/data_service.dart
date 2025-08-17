import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clinic.dart';
import '../models/psychologist.dart';
import '../models/package.dart';

class DataService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<Clinic>> getClinics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clinics'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Clinic(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          address: item['email'] ?? '',
          imageUrl: 'assets/images/clinic${(int.parse(item['id'].toString()) % 4) + 1}.svg',
          description: (item['document_type'] ?? '') + ': ' + (item['document_number'] ?? ''),
        )).toList();
      } else {
        print('Erro ao carregar clínicas: ${response.statusCode}');
        return _getStaticClinics();
      }
    } catch (e) {
      print('Exceção ao carregar clínicas: $e');
      return _getStaticClinics();
    }
  }

  static List<Clinic> _getStaticClinics() {
    return [
      Clinic(
        id: '1',
        name: 'Clínica Mente Sã',
        address: 'Rua das Flores, 123 - Centro',
        imageUrl: 'assets/images/clinic1.svg',
        description: 'Clínica especializada em terapia cognitivo-comportamental com profissionais experientes.',
      ),
      Clinic(
        id: '2',
        name: 'Instituto de Psicologia Aplicada',
        address: 'Av. Paulista, 1000 - Bela Vista',
        imageUrl: 'assets/images/clinic2.svg',
        description: 'Instituto com foco em psicologia aplicada e tratamentos inovadores para diversos transtornos.',
      ),
      Clinic(
        id: '3',
        name: 'Centro de Bem-Estar Mental',
        address: 'Rua Augusta, 500 - Consolação',
        imageUrl: 'assets/images/clinic3.svg',
        description: 'Centro dedicado ao bem-estar mental com abordagem holística e multidisciplinar.',
      ),
      Clinic(
        id: '4',
        name: 'Espaço Terapêutico Renovar',
        address: 'Rua Oscar Freire, 200 - Jardins',
        imageUrl: 'assets/images/clinic4.svg',
        description: 'Espaço acolhedor para terapias individuais e em grupo com foco na renovação emocional.',
      ),
    ];
  }

  static List<Psychologist> getPsychologists() {
    return [
      Psychologist(
        id: 1,
        idClinic: 1,
        name: 'Dra. Ana Silva',
        email: 'ana.silva@psiconecta.com',
        documentType: 'crp',
        documentNumber: '12345678',
        appointmentPrice: 150,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Terapia Cognitivo-Comportamental',
        imageUrl: 'assets/images/psy1.svg',
        bio: 'Especialista em tratamento de ansiedade e depressão com mais de 10 anos de experiência.',
      ),
      Psychologist(
        id: 2,
        idClinic: 1,
        name: 'Dr. Carlos Mendes',
        email: 'carlos.mendes@psiconecta.com',
        documentType: 'crp',
        documentNumber: '23456789',
        appointmentPrice: 160,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Psicanálise',
        imageUrl: 'assets/images/psy2.svg',
        bio: 'Psicanalista com formação pela Sociedade Brasileira de Psicanálise, atende adultos e adolescentes.',
      ),
      Psychologist(
        id: 3,
        idClinic: 2,
        name: 'Dra. Mariana Costa',
        email: 'mariana.costa@psiconecta.com',
        documentType: 'crp',
        documentNumber: '34567890',
        appointmentPrice: 140,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Psicologia Infantil',
        imageUrl: 'assets/images/psy3.svg',
        bio: 'Especializada em desenvolvimento infantil e problemas de aprendizagem.',
      ),
      Psychologist(
        id: 4,
        idClinic: 2,
        name: 'Dr. Roberto Almeida',
        email: 'roberto.almeida@psiconecta.com',
        documentType: 'crp',
        documentNumber: '45678901',
        appointmentPrice: 180,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Neuropsicologia',
        imageUrl: 'assets/images/psy4.svg',
        bio: 'Doutor em neurociências, trabalha com reabilitação cognitiva e avaliação neuropsicológica.',
      ),
      Psychologist(
        id: 5,
        idClinic: 3,
        name: 'Dra. Juliana Ferreira',
        email: 'juliana.ferreira@psiconecta.com',
        documentType: 'crp',
        documentNumber: '56789012',
        appointmentPrice: 170,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Terapia de Casal',
        imageUrl: 'assets/images/psy5.svg',
        bio: 'Especialista em relacionamentos e conflitos familiares, com abordagem sistêmica.',
      ),
      Psychologist(
        id: 6,
        idClinic: 3,
        name: 'Dr. Paulo Santos',
        email: 'paulo.santos@psiconecta.com',
        documentType: 'crp',
        documentNumber: '67890123',
        appointmentPrice: 165,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Psicologia Organizacional',
        imageUrl: 'assets/images/psy6.svg',
        bio: 'Consultor organizacional com foco em saúde mental no trabalho e desenvolvimento de equipes.',
      ),
      Psychologist(
        id: 7,
        idClinic: 4,
        name: 'Dra. Camila Oliveira',
        email: 'camila.oliveira@psiconecta.com',
        documentType: 'crp',
        documentNumber: '78901234',
        appointmentPrice: 155,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Terapia Humanista',
        imageUrl: 'assets/images/psy7.svg',
        bio: 'Terapeuta centrada na pessoa, com foco no autoconhecimento e crescimento pessoal.',
      ),
      Psychologist(
        id: 8,
        idClinic: 4,
        name: 'Dr. Fernando Lima',
        email: 'fernando.lima@psiconecta.com',
        documentType: 'crp',
        documentNumber: '89012345',
        appointmentPrice: 175,
        type: 'psychologist',
        situation: 'valid',
        status: 'active',
        createdAt: '2025-01-01T00:00:00.000000Z',
        updatedAt: '2025-01-01T00:00:00.000000Z',
        specialty: 'Psicologia do Esporte',
        imageUrl: 'assets/images/psy8.svg',
        bio: 'Especialista em preparação mental de atletas e equipes esportivas.',
      ),
    ];
  }

  static Future<List<Psychologist>> getPsychologistsByClinic(int clinicId) async {
    return getPsychologists().where((psy) => psy.idClinic == clinicId).toList();
  }

  static List<Map<String, String>> getSliderData() {
    return [
      {
        'imageUrl': 'assets/images/slider1.svg',
        'title': 'Cuide da sua saúde mental',
        'description': 'Encontre o profissional ideal para você',
      },
      {
        'imageUrl': 'assets/images/slider2.svg',
        'title': 'Agende sua consulta',
        'description': 'Processo simples e rápido',
      },
      {
        'imageUrl': 'assets/images/slider3.svg',
        'title': 'Atendimento online ou presencial',
        'description': 'Escolha a modalidade que melhor se adapta a você',
      },
    ];
  }

  static Future<List<Package>> getPackages(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/packages?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Package.fromJson(item)).toList();
      } else {
        print('Erro ao carregar pacotes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exceção ao carregar pacotes: $e');
      return [];
    }
  }

  static Future<Package?> getPackage(int packageId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/packages/$packageId'),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Package.fromJson(data);
      } else {
        print('Erro ao carregar pacote: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exceção ao carregar pacote: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> buyPackage({
    required int patientId,
    required int psychologistId,
    required int totalAppointments,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/packages/buyPackage'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patient_id': patientId,
          'psychologist_id': psychologistId,
          'total_appointments': totalAppointments,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body.replaceAll('"', ''),
        };
      } else {
        return {
          'success': false,
          'message': response.body.replaceAll('"', ''),
        };
      }
    } catch (e) {
      print('Exceção ao comprar pacote: $e');
      return {
        'success': false,
        'message': 'Erro de conexão. Tente novamente.',
      };
    }
  }
}