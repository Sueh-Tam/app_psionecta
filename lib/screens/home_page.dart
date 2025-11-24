import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clinic.dart';
import '../models/appointment.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/clinic_item.dart';
import '../widgets/home_slider.dart';
import 'psychologists_page.dart';
import 'clinics_page.dart';
import 'Auth/login_page.dart';
import 'Auth/update_profile_page.dart';
import 'financeiro/financeiro_page.dart';
import 'consultas/agendar_consulta_page.dart';
import 'consultas/consultas_agendadas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _checkedTomorrowNotification = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context);
    if (authService.isAuthenticated && !_checkedTomorrowNotification) {
      Future.microtask(_checkTomorrowAppointment);
    }
  }

  Future<void> _checkTomorrowAppointment() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;
      if (userId == null) return;

      await NotificationService.ensureInitialized();

      final appointments = await DataService.getScheduledAppointments(userId);
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      Appointment? nextDayAppointment;
      for (final a in appointments) {
        if (a.status.toLowerCase() != 'scheduled') continue;
        final date = DateTime.tryParse(a.dtAvailability);
        if (date == null) continue;
        if (date.year == tomorrow.year &&
            date.month == tomorrow.month &&
            date.day == tomorrow.day) {
          nextDayAppointment = a;
          break;
        }
      }

      if (nextDayAppointment != null && mounted) {
        String doctorName = 'Psicólogo(a)';
        try {
          final psychs = await DataService.getPsychologistsByClinic(nextDayAppointment.clinicId);
          final matches = psychs.where((p) => p.id == nextDayAppointment!.psychologistId).toList();
          if (matches.isNotEmpty) {
            doctorName = matches.first.name;
          } else if (psychs.isNotEmpty) {
            doctorName = psychs.first.name;
          }
        } catch (_) {}

        await NotificationService.showNow(
          'Consulta amanhã',
          'Você tem consulta amanhã às ${nextDayAppointment!.formattedTime} com $doctorName.'
        );

        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Colors.blue.shade50,
              title: Text(
                'Consulta amanhã',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Você tem consulta amanhã às ${nextDayAppointment!.formattedTime} com $doctorName.',
                style: TextStyle(color: Colors.blue.shade800),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsultasAgendadasPage(),
                      ),
                    );
                  },
                  child: const Text('Ver consultas'),
                ),
              ],
            );
          },
        );
      }

      _checkedTomorrowNotification = true;
    } catch (_) {
      _checkedTomorrowNotification = true;
    }
  }

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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.account_circle, color: Colors.white),
                      onSelected: (String value) {
                        switch (value) {
                          case 'perfil':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpdateProfilePage(),
                              ),
                            );
                            break;
                          case 'agendar':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AgendarConsultaPage(),
                              ),
                            );
                            break;
                          case 'consultas':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConsultasAgendadasPage(),
                              ),
                            );
                            break;
                          case 'financeiro':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FinanceiroPage(),
                              ),
                            );
                            break;
                          case 'logout':
                            authService.logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logout realizado com sucesso')),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'perfil',
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Perfil'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'agendar',
                          child: ListTile(
                            leading: Icon(Icons.calendar_today),
                            title: Text('Agendar consulta'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'consultas',
                          child: ListTile(
                            leading: Icon(Icons.event_note),
                            title: Text('Consultas agendadas'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'financeiro',
                          child: ListTile(
                            leading: Icon(Icons.attach_money),
                            title: Text('Financeiro'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text('Sair', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
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