import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clinic.dart';
import '../models/psychologist.dart';

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
        id: '1',
        name: 'Dra. Ana Silva',
        specialty: 'Terapia Cognitivo-Comportamental',
        imageUrl: 'assets/images/psy1.svg',
        clinicId: '1',
        bio: 'Especialista em tratamento de ansiedade e depressão com mais de 10 anos de experiência.',
      ),
      Psychologist(
        id: '2',
        name: 'Dr. Carlos Mendes',
        specialty: 'Psicanálise',
        imageUrl: 'assets/images/psy2.svg',
        clinicId: '1',
        bio: 'Psicanalista com formação pela Sociedade Brasileira de Psicanálise, atende adultos e adolescentes.',
      ),
      Psychologist(
        id: '3',
        name: 'Dra. Mariana Costa',
        specialty: 'Psicologia Infantil',
        imageUrl: 'assets/images/psy3.svg',
        clinicId: '2',
        bio: 'Especializada em desenvolvimento infantil e problemas de aprendizagem.',
      ),
      Psychologist(
        id: '4',
        name: 'Dr. Roberto Almeida',
        specialty: 'Neuropsicologia',
        imageUrl: 'assets/images/psy4.svg',
        clinicId: '2',
        bio: 'Doutor em neurociências, trabalha com reabilitação cognitiva e avaliação neuropsicológica.',
      ),
      Psychologist(
        id: '5',
        name: 'Dra. Juliana Ferreira',
        specialty: 'Terapia de Casal',
        imageUrl: 'assets/images/psy5.svg',
        clinicId: '3',
        bio: 'Especialista em relacionamentos e conflitos familiares, com abordagem sistêmica.',
      ),
      Psychologist(
        id: '6',
        name: 'Dr. Paulo Santos',
        specialty: 'Psicologia Organizacional',
        imageUrl: 'assets/images/psy6.svg',
        clinicId: '3',
        bio: 'Consultor organizacional com foco em saúde mental no trabalho e desenvolvimento de equipes.',
      ),
      Psychologist(
        id: '7',
        name: 'Dra. Camila Oliveira',
        specialty: 'Terapia Humanista',
        imageUrl: 'assets/images/psy7.svg',
        clinicId: '4',
        bio: 'Terapeuta centrada na pessoa, com foco no autoconhecimento e crescimento pessoal.',
      ),
      Psychologist(
        id: '8',
        name: 'Dr. Fernando Lima',
        specialty: 'Psicologia do Esporte',
        imageUrl: 'assets/images/psy8.svg',
        clinicId: '4',
        bio: 'Especialista em preparação mental de atletas e equipes esportivas.',
      ),
    ];
  }

  static Future<List<Psychologist>> getPsychologistsByClinic(String clinicId) async {
    return getPsychologists().where((psy) => psy.clinicId == clinicId).toList();
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
}