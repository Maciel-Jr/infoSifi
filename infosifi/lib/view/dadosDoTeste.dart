import 'package:flutter/material.dart';
import '../services/authService.dart';


class Dadosdoteste extends StatefulWidget {
  const Dadosdoteste({super.key});

  @override
  State<Dadosdoteste> createState() => _DadosdotesteState();
}

class _DadosdotesteState extends State<Dadosdoteste> {
  final TextEditingController _validadeController = TextEditingController();
  final TextEditingController _dataHoraController = TextEditingController();
  void _fotoTeste(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/fotoTeste');
  }

  void _voltarParaNovoTeste(BuildContext context) {
    // Redireciona e limpa a pilha até a rota desejada
    Navigator.of(context).pushNamedAndRemoveUntil('/mainView', (route) => false, arguments: 1); // faz voltar para a tela de novo teste (index 1)
  } 

  Future<void> _selecionarValidade(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      _validadeController.text =
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    }
  }

  Future<void> _selecionarDataHora(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null) return;

    _dataHoraController.text =
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloqueia o fechamento padrão da tela
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Executa a navegação personalizada quando o usuário aperta <
        _voltarParaNovoTeste(context);
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/mainView'),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Dados do teste',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),

              const SizedBox(height: 30),
              const Icon(
                Icons.medication_outlined,
                size: 60,
                color: Color(0xFF6A1B9A),
              ),

              const SizedBox(height: 30),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Teste',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Treponêmico',
                    child: Text('Treponêmico'),
                  ),
                  DropdownMenuItem(
                    value: 'Não treponêmico',
                    child: Text('Não treponêmico'),
                  ),
                ],
                onChanged: (value) {},
              ),

              SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Lote',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _validadeController,
                readOnly: true,
                onTap: () => _selecionarValidade(context),
                decoration: InputDecoration(
                  labelText: 'Validade',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 16,),

              TextField(
                controller: _dataHoraController,
                readOnly: true,
                onTap: () => _selecionarDataHora(context),
                decoration: InputDecoration(
                  labelText: 'Data/Hora da Realização',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Profissional Responsável',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Profissional 1',
                    child: Text('Profissional 1'),
                  ),
                  DropdownMenuItem(
                    value: 'Profissional 2',
                    child: Text('Profissional 2'),
                  ),
                ],
                onChanged: (value) {},
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => _fotoTeste(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('FOTOGRAFAR TESTE'),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}