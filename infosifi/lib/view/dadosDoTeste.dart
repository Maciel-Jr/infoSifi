import 'package:flutter/material.dart';
import '../services/authService.dart';


class Dadosdoteste extends StatelessWidget {
  const Dadosdoteste({super.key});

  void _fotoTeste(BuildContext context) {
      Navigator.of(context).pushReplacementNamed('/fotoTeste'); 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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
                  labelText: 'Tipo de Teste',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Lote',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Validade',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data/Hora da Realização',
              ),),
              SizedBox(height: 16,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Profissional Responsável',
              ),),

              TextButton(onPressed: (()=>{_fotoTeste(context)}), child: Text('Fotografe o Teste'))
            ],
          ),
        ),
      ),
    );
  }
}