import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';

class CompraPacotesPage extends StatefulWidget {
  final dynamic clinicaPreSelecionada;
  
  const CompraPacotesPage({super.key, this.clinicaPreSelecionada});

  @override
  State<CompraPacotesPage> createState() => _CompraPacotesPageState();
}

class _CompraPacotesPageState extends State<CompraPacotesPage> {
  List<dynamic> clinicas = [];
  List<dynamic> psicologos = [];
  dynamic clinicaSelecionada;
  dynamic psicologoSelecionado;
  bool carregandoClinicas = true;
  bool carregandoPsicologos = false;
  String? erro;
  int numeroConsultas = 1;
  String metodoPagamento = 'pix';
  final TextEditingController _consultasController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _carregarClinicas();
  }

  Future<void> _carregarClinicas() async {
    try {
      if (!mounted) return;
      setState(() {
        carregandoClinicas = true;
        erro = null;
      });

      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/clinics'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          clinicas = data;
          carregandoClinicas = false;
          
          // Se há uma clínica pré-selecionada, definir como selecionada
          if (widget.clinicaPreSelecionada != null) {
            clinicaSelecionada = widget.clinicaPreSelecionada;
            // Carregar psicólogos da clínica pré-selecionada
            final clinicaId = int.tryParse(widget.clinicaPreSelecionada['id'].toString()) ?? 0;
            if (clinicaId > 0) {
              _carregarPsicologos(clinicaId);
            }
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          clinicas = _getClinicasEstaticas();
          carregandoClinicas = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        clinicas = _getClinicasEstaticas();
        carregandoClinicas = false;
        
        // Se há uma clínica pré-selecionada, definir como selecionada
        if (widget.clinicaPreSelecionada != null) {
          clinicaSelecionada = widget.clinicaPreSelecionada;
          // Carregar psicólogos da clínica pré-selecionada
          final clinicaId = int.tryParse(widget.clinicaPreSelecionada['id'].toString()) ?? 0;
          if (clinicaId > 0) {
            _carregarPsicologos(clinicaId);
          }
        }
      });
    }
  }

  Future<void> _carregarPsicologos(int clinicaId) async {
    try {
      if (!mounted) return;
      setState(() {
        carregandoPsicologos = true;
        psicologos = [];
        psicologoSelecionado = null;
        erro = null;
      });

      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/clinics/$clinicaId/psychologists'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          psicologos = data;
          carregandoPsicologos = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          erro = 'Erro ao carregar psicólogos';
          carregandoPsicologos = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        psicologos = _getPsicologosEstaticos();
        carregandoPsicologos = false;
      });
    }
  }

  Future<void> _comprarPacote() async {
    if (psicologoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um psicólogo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await DataService.buyPackage(
        patientId: user.id,
        psychologistId: psicologoSelecionado!['id'],
        totalAppointments: numeroConsultas,
        paymentMethod: metodoPagamento,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao processar compra. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> _getClinicasEstaticas() {
    return [
      {
        'id': 1,
        'name': 'Clínica Bem-Estar',
        'email': 'contato@clinicabemestar.com',
      },
      {
        'id': 2,
        'name': 'Saúde Mental',
        'email': 'clinica1@psiconecta.com',
      },
    ];
  }

  List<dynamic> _getPsicologosEstaticos() {
    return [
      {
        'id': 1,
        'name': 'Dr. João Silva',
        'appointment_price': 150,
      },
      {
        'id': 2,
        'name': 'Dra. Maria Santos',
        'appointment_price': 180,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compra de Pacotes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecione uma Clínica',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 20),
            if (carregandoClinicas)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1565C0),
                ),
              )
            else if (erro != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      erro!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _carregarClinicas,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                  itemCount: clinicas.length,
                  itemBuilder: (context, index) {
                    final clinica = clinicas[index];
                    // Comparar IDs convertendo ambos para string para garantir compatibilidade
                    final isSelected = clinicaSelecionada?['id'].toString() == clinica['id'].toString();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF1565C0) 
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected 
                            ? const Color(0xFF1565C0).withOpacity(0.1) 
                            : Colors.white,
                      ),
                      child: ListTile(
                        title: Text(
                          clinica['name'] ?? 'Nome não disponível',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                            ? const Color(0xFF1565C0) 
                            : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          clinica['email'] ?? 'Email não disponível',
                          style: TextStyle(
                            color: isSelected 
                              ? const Color(0xFF1565C0).withOpacity(0.7) 
                              : Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected 
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF2E8B57),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                              ),
                        onTap: () {
                          setState(() {
                            clinicaSelecionada = clinica;
                          });
                          _carregarPsicologos(clinica['id']);
                        },
                      ),
                    );
                  },
                ),
            
            if (clinicaSelecionada != null) ...[
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text(
                    'Psicólogos da Clínica',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E8B57),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        clinicaSelecionada = null;
                        psicologos = [];
                        psicologoSelecionado = null;
                      });
                    },
                    child: const Text(
                      'Alterar Clínica',
                      style: TextStyle(color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              if (carregandoPsicologos)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E8B57),
                  ),
                )
              else if (psicologos.isEmpty)
                const Center(
                  child: Text(
                    'Nenhum psicólogo encontrado para esta clínica',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                    itemCount: psicologos.length,
                    itemBuilder: (context, index) {
                      final psicologo = psicologos[index];
                      final isSelected = psicologoSelecionado?['id'] == psicologo['id'];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF2E8B57) 
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected 
                              ? const Color(0xFF2E8B57).withOpacity(0.1) 
                              : Colors.white,
                        ),
                        child: ListTile(
                          title: Text(
                            psicologo['name'] ?? 'Nome não disponível',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? const Color(0xFF2E8B57) 
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Valor da consulta: R\$ ${psicologo['appointment_price']?.toString() ?? 'N/A'}',
                            style: TextStyle(
                              color: isSelected 
                                  ? const Color(0xFF2E8B57).withOpacity(0.7) 
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: isSelected 
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1565C0),
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            setState(() {
                              psicologoSelecionado = psicologo;
                            });
                          },
                        ),
                      );
                    },
                  ),
            ],
            
            if (psicologoSelecionado != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuração do Pacote',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Clínica: ${clinicaSelecionada!['name']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Psicólogo: ${psicologoSelecionado!['name']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Valor por consulta: R\$ ${psicologoSelecionado!['appointment_price']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Número de consultas:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (numeroConsultas > 1) {
                              setState(() {
                                numeroConsultas--;
                                _consultasController.text = numeroConsultas.toString();
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFF1565C0),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _consultasController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: const Color(0xFF1565C0),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              final int? novoValor = int.tryParse(value);
                              if (novoValor != null && novoValor > 0) {
                                setState(() {
                                  numeroConsultas = novoValor;
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              numeroConsultas++;
                              _consultasController.text = numeroConsultas.toString();
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF1565C0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Valor Total do Pacote',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'R\$ ${(psicologoSelecionado!['appointment_price'] * numeroConsultas).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$numeroConsultas consulta${numeroConsultas > 1 ? 's' : ''} × R\$ ${psicologoSelecionado!['appointment_price']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Método de Pagamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('PIX'),
                          value: 'pix',
                          groupValue: metodoPagamento,
                          onChanged: (value) {
                            setState(() {
                              metodoPagamento = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Dinheiro'),
                          value: 'cash',
                          groupValue: metodoPagamento,
                          onChanged: (value) {
                            setState(() {
                              metodoPagamento = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Plano de Saúde'),
                          value: 'health_plan',
                          groupValue: metodoPagamento,
                          onChanged: (value) {
                            setState(() {
                              metodoPagamento = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _comprarPacote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Comprar Pacote - R\$ ${(psicologoSelecionado!['appointment_price'] * numeroConsultas).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}