import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clinic.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../widgets/clinic_item.dart';
import '../widgets/home_slider.dart';
import 'psychologists_page.dart';
import 'clinics_page.dart';
import 'Auth/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Consumer<AuthService>(
            builder: (context, authService, child) {
              if (authService.isAuthenticated) {
                return Row(
                  children: [
                    Text(
                      authService.currentUser?.name.split(' ')[0] ?? 'Usuário',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        authService.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logout realizado com sucesso')),
                        );
                      },
                    ),
                  ],
                );
              }
              return TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const HomeSlider(),
          
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClinicsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Ver todas',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<Clinic>>(
              future: DataService.getClinics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar clínicas: ${snapshot.error}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma clínica encontrada',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  final clinics = snapshot.data!;
                  return ListView.builder(
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      return ClinicItem(
                        clinic: clinics[index],
                        onTap: () {
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
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}