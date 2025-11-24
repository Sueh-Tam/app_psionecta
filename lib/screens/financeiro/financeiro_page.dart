import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'compra_pacotes_page.dart';
import 'consulta_pacotes_page.dart';
import '../../services/auth_service.dart';

class FinanceiroPage extends StatelessWidget {
  const FinanceiroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financeiro',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Área Financeira',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gerencie suas finanças e pacotes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            _buildFinanceButton(
              context,
              'Compra de Pacotes',
              'Adquira novos pacotes de consultas',
              Icons.shopping_cart,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompraPacotesPage(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFinanceButton(
              context,
              'Consulta de Pacotes',
              'Verifique seus pacotes ativos',
              Icons.inventory,
              () {
                final authService = Provider.of<AuthService>(context, listen: false);
                final userId = authService.currentUser?.id ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsultaPacotesPage(userId: userId),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1565C0),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: const Color(0xFF1565C0).withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 30,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF1565C0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature será implementado em breve'),
        backgroundColor: const Color(0xFF1565C0),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}