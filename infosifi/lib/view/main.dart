import 'package:flutter/material.dart';
import 'home.dart';
import 'historico.dart'; 
import 'novoTeste.dart'; 

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // Índice da aba atualmente selecionada
  int _currentIndex = 0;

  // Lista com as telas que serão alternadas
  final List<Widget> _pages = const [
    HomeView(),
    Novoteste(),
    Historico()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a tela correspondente ao índice atual
      body: _pages[_currentIndex],

      // ONDE FICA A BARRA DE NAVEGAÇÃO:
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded),
            label: 'Novo Teste',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_outlined),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}