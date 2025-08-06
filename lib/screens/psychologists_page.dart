import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/clinic.dart';
import '../models/psychologist.dart';
import '../services/data_service.dart';

class PsychologistsPage extends StatelessWidget {
  final Clinic clinic;

  const PsychologistsPage({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final psychologists = DataService.getPsychologistsByClinic(clinic.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          clinic.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          // Informações da clínica
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(
                        clinic.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.business, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinic.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            clinic.address,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            clinic.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Título da seção de psicólogos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Psicólogos Disponíveis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${psychologists.length} profissionais',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Lista de psicólogos
          Expanded(
            child: psychologists.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum psicólogo disponível nesta clínica no momento.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: psychologists.length,
                    itemBuilder: (context, index) {
                      final psychologist = psychologists[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: SvgPicture.asset(
                                  psychologist.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (context) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      psychologist.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      psychologist.specialty,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      psychologist.bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implementar lógica de agendamento
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Função de agendamento será implementada em breve')),
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Agendar Consulta'),
      ),
    );
  }
}