import 'package:flutter/material.dart';
import 'package:infosifi/view/login.dart';
import 'package:infosifi/view/home.dart';
import 'package:infosifi/view/historico.dart';
import 'package:infosifi/view/novoTeste.dart';
import 'package:infosifi/view/main.dart';
import 'package:infosifi/view/dadosDoTeste.dart';
import 'package:infosifi/view/fotoTeste.dart';
import 'services/authService.dart';

void main() {
  // Garante que os canais nativos estejam prontos antes de ler o storage
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final authService = Authservice();
    
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/historico': (context) => const Historico(), 
        '/novoTeste': (context) => const Novoteste(),
        '/mainView': (context) => const MainView(),
        '/dadosDoTeste': (context) => const Dadosdoteste(),
        '/fotoTeste': (context) => const Fototeste(),

      },
      home: FutureBuilder<bool>(
        future: authService.isAuthenticated(),
        builder: (context, snapshot) {
          // 1. Enquanto está lendo o storage do celular, exibe uma tela de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 2. Se encontrou o token, vai direto para a MainView
          if (snapshot.hasData && snapshot.data == true) {
            return const MainView();
          }

          // 3. Se não tem token ou deu erro, vai para a LoginView
          return const LoginView();
        },
      ),

      

    );
  }
}