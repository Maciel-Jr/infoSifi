import 'package:flutter/material.dart';
import '../services/authService.dart';
import 'login.dart';

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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Teste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome do Paciente',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data de Nascimento',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Whatsapp',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Codigo do Atendimento',
              ),),

              TextButton(onPressed: ((){}), child: Text('Iniciar Teste'))
            ],
          ),
        ),
      ),
    );
  }
}