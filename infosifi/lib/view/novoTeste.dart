import 'package:flutter/material.dart';
import '../services/authService.dart';
import 'login.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Novoteste extends StatelessWidget {
  const Novoteste({super.key});

  void _handleLogout(BuildContext context) async {
    final authService = Authservice();
    await authService.logout();

    if (context.mounted) {
      // Remove todas as rotas e volta para o login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }

  void _iniciarTeste(BuildContext context) {
      Navigator.of(context).pushReplacementNamed('/dadosDoTeste'); 

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Novo atendimento',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),

              const SizedBox(height: 13),

              Column(
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: Color(0xFF6A1B9A),
                  ),
                  const Icon(
                    Icons.groups,
                    size: 60,
                    color: Color(0xFF6A1B9A),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome do Paciente',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

        TextField(
          inputFormatters: [
            MaskTextInputFormatter(mask: '##/##/####'),
          ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                inputFormatters: [
                  MaskTextInputFormatter(mask: '(##) #####-####'),
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  labelText: 'Whatsapp',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  labelText: 'Código do Atendimento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => _iniciarTeste(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('INICIAR TESTE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}