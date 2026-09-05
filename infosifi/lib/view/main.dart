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

  // Lista para registrar o histórico de abas visitadas
  final List<int> _navigationHistory = [0];

  // Lista com as telas que serão alternadas
  final List<Widget> _pages = const [
    HomeView(),
    Novoteste(),
    Historico()
  ];

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _navigationHistory.add(index); // Salva no histórico
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: true se estiver no índice inicial e não houver histórico anterior
      canPop: _navigationHistory.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        // Se o Flutter já fechou o app, não faz nada
        if (didPop) return;

        // Se há abas no histórico para voltar:
        if (_navigationHistory.length > 1) {
          setState(() {
            _navigationHistory.removeLast(); // Remove a tela atual
            _currentIndex = _navigationHistory.last; // Volta para a anterior
          });
        }
      },
      child: Scaffold(
      // Exibe a tela correspondente ao índice atual
      body: _pages[_currentIndex],

      // ONDE FICA A BARRA DE NAVEGAÇÃO:
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
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
    )
    );
  }
}