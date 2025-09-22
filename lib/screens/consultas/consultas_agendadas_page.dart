import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import 'agendar_consulta_page.dart';

class ConsultasAgendadasPage extends StatefulWidget {
  const ConsultasAgendadasPage({super.key});

  @override
  State<ConsultasAgendadasPage> createState() => _ConsultasAgendadasPageState();
}

class _ConsultasAgendadasPageState extends State<ConsultasAgendadasPage> {
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  
  // Filtros
  String _selectedStatus = 'scheduled';
  int? _selectedMonth;
  int? _selectedYear;
  
  final List<String> _statusOptions = [
    'todos',
    'scheduled',
    'completed',
    'cancelled',
    'canceled_late',
    'canceled_early'
  ];
  
  final List<String> _statusLabels = [
    'Todos',
    'Agendado',
    'Realizada',
    'Cancelado',
    'Cancelado tardiamente',
    'Cancelado antecipadamente'
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      final appointments = await DataService.getScheduledAppointments(userId);
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar consultas: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar consultas: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredAppointments = _appointments.where((appointment) {
      // Filtro por status
      if (_selectedStatus != 'todos' && appointment.status.toLowerCase() != _selectedStatus) {
        return false;
      }
      
      // Filtro por mês
      if (_selectedMonth != null) {
final appointmentDate = DateTime.parse(appointment.dtAvailability);
        if (appointmentDate.month != _selectedMonth) {
          return false;
        }
      }
      
      // Filtro por ano
      if (_selectedYear != null) {
        final appointmentDate = DateTime.parse(appointment.dtAvailability);
        if (appointmentDate.year != _selectedYear) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Ordenar por data (próximas consultas primeiro)
    _filteredAppointments.sort((a, b) {
      final dateA = DateTime.parse(a.dtAvailability);
      final dateB = DateTime.parse(b.dtAvailability);
      return dateA.compareTo(dateB);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consultas Agendadas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            )
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: _filteredAppointments.isEmpty
                      ? _buildEmptyState()
                      : _buildAppointmentsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              // Primeira linha - Status
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _statusOptions.asMap().entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(_statusLabels[entry.key]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Segunda linha - Mês e Ano
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'Mês',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...List.generate(12, (index) {
                          final month = index + 1;
                          final monthNames = [
                            'Janeiro', 'Fevereiro', 'Março', 'Abril',
                            'Maio', 'Junho', 'Julho', 'Agosto',
                            'Setembro', 'Outubro', 'Novembro', 'Dezembro'
                          ];
                          return DropdownMenuItem<int>(
                            value: month,
                            child: Text(monthNames[index]),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Ano',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...List.generate(5, (index) {
                          final year = DateTime.now().year + index;
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma consulta agendada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas consultas agendadas aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: Colors.blue.shade800,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _filteredAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.blue.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consulta #${appointment.id}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(appointment.status),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data: ${appointment.formattedDate}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.blue.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Horário: ${appointment.formattedTime}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: appointment.status.toLowerCase() == 'scheduled'
                        ? () => _showCancelDialog(appointment)
                        : null,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: appointment.status.toLowerCase() == 'scheduled'
                        ? () => _showRescheduleDialog(appointment)
                        : null,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Reagendar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.green.shade700;
      case 'completed':
        return Colors.blue.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'no_show':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendado';
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelado';
      case 'canceled_late':
        return 'Cancelado tardiamente';
      case 'canceled_early':
        return 'Cancelado antecipadamente';
      default:
        return status;
    }
  }

  void _showCancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancelar Consulta',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Tem certeza que deseja cancelar a consulta agendada para ${appointment.formattedDate} às ${appointment.formattedTime}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sim, Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reagendar Consulta',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja reagendar a consulta de ${appointment.formattedDate} às ${appointment.formattedTime}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rescheduleAppointment(appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reagendar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    try {
      await DataService.cancelAppointment(appointment.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Consulta #${appointment.id} cancelada com sucesso!',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Recarregar a lista
        _loadAppointments();
      }
    } catch (e) {
      print('Erro ao cancelar consulta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar consulta: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment(Appointment appointment) async {
    try {
      // Cancelar a consulta atual via API
      await DataService.cancelAppointment(appointment.id);
      
      if (mounted) {
        // Navegar para a tela de agendamento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AgendarConsultaPage(),
          ),
        );
        
        // Recarregar a lista de consultas
        _loadAppointments();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Consulta cancelada com sucesso. Selecione um pacote para reagendar.'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar consulta: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}