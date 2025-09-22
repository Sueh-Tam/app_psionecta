import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../models/package.dart';
import '../../models/availability.dart';
import '../financeiro/compra_pacotes_page.dart';

class AgendarConsultaPage extends StatefulWidget {
  const AgendarConsultaPage({Key? key}) : super(key: key);

  @override
  State<AgendarConsultaPage> createState() => _AgendarConsultaPageState();
}

class _AgendarConsultaPageState extends State<AgendarConsultaPage> {
  List<Package> _activePackages = [];
  bool _isLoading = true;
  List<Availability> _availabilities = [];
  bool _isLoadingAvailabilities = false;
  Availability? _selectedAvailability;

  @override
  void initState() {
    super.initState();
    _loadActivePackages();
  }

  Future<void> _loadActivePackages() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        print('Carregando pacotes ativos para usuário ID: ${currentUser.id}');
        final packages = await DataService.getActivePackages(currentUser.id);
        print('Pacotes carregados: ${packages.length}');
        setState(() {
          _activePackages = packages;
          _isLoading = false;
        });
      } else {
        print('Usuário não está logado');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar pacotes ativos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agendar Consulta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1565C0)),
              ),
            )
          : _activePackages.isEmpty
              ? _buildEmptyState()
              : _buildPackagesList(),
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
            'Nenhum pacote ativo encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você precisa ter um pacote ativo para agendar consultas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompraPacotesPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Comprar Pacote'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seus Pacotes Ativos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione um pacote para agendar sua consulta',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _activePackages.length,
              itemBuilder: (context, index) {
                final package = _activePackages[index];
                return _buildPackageCard(package);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar para tela de agendamento específica do pacote
          _showScheduleDialog(package);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade800,
                    child: Text(
                      package.psychologist.name.split(' ').first[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.psychologist.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.psychologist.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consultas restantes:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${package.balance}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Valor por consulta:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          'R\$ ${package.psychologist.appointmentPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Forma de pagamento:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _getPaymentMethodText(package.paymentMethod),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showScheduleDialog(package);
                  },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Agendar Consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'pix':
        return 'PIX';
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'debit_card':
        return 'Cartão de Débito';
      case 'health_plan':
        return 'Plano de Saúde';
      default:
        return paymentMethod;
    }
  }

  Future<void> _loadAvailabilities(int psychologistId) async {
    try {
      final availabilities = await DataService.getAvailabilities(psychologistId);
      if (mounted) {
        setState(() {
          _availabilities = availabilities;
          _isLoadingAvailabilities = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar disponibilidades: $e');
      if (mounted) {
        setState(() {
          _isLoadingAvailabilities = false;
        });
      }
    }
  }

  Future<void> _loadAvailabilitiesForDialog(int psychologistId, StateSetter setDialogState) async {
    try {
      final availabilities = await DataService.getAvailabilities(psychologistId);
      setDialogState(() {
        _availabilities = availabilities;
        _isLoadingAvailabilities = false;
      });
    } catch (e) {
      print('Erro ao carregar disponibilidades: $e');
      setDialogState(() {
        _isLoadingAvailabilities = false;
      });
    }
  }

  void _showScheduleDialog(Package package) {
    // Resetar estado local
    _selectedAvailability = null;
    _availabilities = [];
    _isLoadingAvailabilities = true;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Carregar disponibilidades apenas uma vez
            if (_isLoadingAvailabilities && _availabilities.isEmpty) {
              _loadAvailabilitiesForDialog(package.psychologist.id, setDialogState);
            }
            
            return AlertDialog(
              title: Text(
                'Agendar Consulta - ${package.psychologist.name}',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultas restantes: ${package.balance}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selecione um horário disponível:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _isLoadingAvailabilities
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                              ),
                            )
                          : _availabilities.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nenhum horário disponível',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _availabilities.length,
                                  itemBuilder: (context, index) {
                                    final availability = _availabilities[index];
                                    final isSelected = _selectedAvailability?.id == availability.id;
                                    
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      elevation: isSelected ? 4 : 1,
                                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.access_time,
                                          color: isSelected ? Colors.blue.shade800 : Colors.grey[600],
                                        ),
                                        title: Text(
                                          availability.formattedDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.blue.shade800 : Colors.black87,
                                          ),
                                        ),
                                        subtitle: Text(
                                          availability.formattedTime,
                                          style: TextStyle(
                                            color: isSelected ? Colors.blue.shade700 : Colors.grey[600],
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: Colors.blue.shade800,
                                              )
                                            : null,
                                        onTap: () {
                                          setDialogState(() {
                                            _selectedAvailability = availability;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectedAvailability = null;
                    _availabilities = [];
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _selectedAvailability == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _confirmSchedule(package, _selectedAvailability!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirmar Agendamento'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmSchedule(Package package, Availability availability) async {
    try {
      // Mostrar indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
            ),
          );
        },
      );

      // Fazer a requisição de agendamento
      final result = await DataService.scheduleAppointment(package.id, availability.id);
      
      // Fechar o indicador de carregamento
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar mensagem de resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] 
                ? Colors.green.shade700 
                : Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Se foi bem-sucedido, navegar para a tela inicial
      if (result['success'] && mounted) {
        // Navegar para a tela inicial, removendo todas as telas anteriores da pilha
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Fechar o indicador de carregamento em caso de erro
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Mostrar mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar consulta: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
    
    // Limpar estado local
    _selectedAvailability = null;
    _availabilities = [];
  }
}