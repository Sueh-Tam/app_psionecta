import 'package:flutter/material.dart';
import '../models/clinic.dart';
import '../services/data_service.dart';
import '../widgets/clinic_item.dart';
import '../widgets/home_slider.dart';
import 'psychologists_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clinics = DataService.getClinics();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Psiconecta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        actions: [
          TextButton.icon(
            onPressed: () {
              // Implementar lógica de login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Função de login será implementada em breve')),
              );
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Slider
          const HomeSlider(),
          
          // Título da seção de clínicas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Clínicas Parceiras',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Ver todas as clínicas
                  },
                  child: Text(
                    'Ver todas',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de clínicas
          Expanded(
            child: ListView.builder(
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                return ClinicItem(
                  clinic: clinics[index],
                  onTap: () {
                    // Navegar para a página de psicólogos da clínica
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PsychologistsPage(
                          clinic: clinics[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}