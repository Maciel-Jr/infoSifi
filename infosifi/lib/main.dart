import 'package:flutter/material.dart';
import 'package:infosifi/view/login.dart';
import 'package:infosifi/view/home.dart';
import 'package:infosifi/view/historico.dart';
import 'package:infosifi/view/novoTeste.dart';
import 'package:infosifi/view/main.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/historico': (context) => const Historico(), 
        '/novoTeste': (context) => const Novoteste(),
        '/mainView': (context) => const MainView(),
      },

    );
  }
}