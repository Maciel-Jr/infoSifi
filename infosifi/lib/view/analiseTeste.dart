import 'package:flutter/material.dart';
import '../viewModels/novoTesteViewModels.dart';
import '../services/authService.dart';
import 'login.dart';

class AnaliseTeste extends StatefulWidget {
  const AnaliseTeste({super.key, required this.viewModel});
  final NovoTesteViewModel viewModel;

  @override
  State<AnaliseTeste> createState() => _AnaliseTesteState();
}

class _AnaliseTesteState extends State<AnaliseTeste> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.enviar();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        if (viewModel.enviando) {
          return _layout(
            'Analisando imagem',
            const CircularProgressIndicator(),
            'O atendimento está sendo enviado para análise.',
          );
        }
        if (viewModel.erro != null) {
          return _layout(
            'Não foi possível enviar',
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            viewModel.erro!,
            action: ElevatedButton(
              onPressed: viewModel.sessaoExpirada
                  ? () async {
                      await Authservice().logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (route) => false,
                      );
                    }
                  : viewModel.enviar,
              child: Text(
                viewModel.sessaoExpirada ? 'IR PARA LOGIN' : 'TENTAR NOVAMENTE',
              ),
            ),
          );
        }
        final atendimento = viewModel.atendimento;
        final cadastrado = atendimento?.cadastrado;
        final mensagem = atendimento?.mensagem;
        if (cadastrado == false) {
          return _layout(
            'Teste não cadastrado',
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 64),
            mensagem ?? 'O teste não foi cadastrado.',
            action: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('FINALIZAR ATENDIMENTO'),
            ),
          );
        }
        return _layout(
          'Validação profissional',
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
          mensagem ??
              'Confira o resultado retornado pela API antes de finalizar o atendimento.',
          action: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('FINALIZAR ATENDIMENTO'),
          ),
          resultado: viewModel.atendimento?.resultado,
        );
      },
    );
  }

  Widget _layout(
    String title,
    Widget icon,
    String message, {
    Widget? action,
    String? resultado,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (resultado != null && resultado.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Resultado do reagente',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 24), action],
            ],
          ),
        ),
      ),
    );
  }
}

class ResultadoTeste extends StatelessWidget {
  const ResultadoTeste({super.key, required this.viewModel});
  final NovoTesteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final atendimento = viewModel.atendimento!;
    final resultado = atendimento.resultado?.isNotEmpty == true
        ? atendimento.resultado!
        : 'PENDENTE';
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado validado')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 72),
          const SizedBox(height: 12),
          const Text(
            'Resultado do atendimento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          const SizedBox(height: 24),
          _line('Paciente', atendimento.nomePaciente),
          _line('Atendimento', atendimento.codigoAtendimento),
          _line('Teste', atendimento.tipoTeste),
          _line('Resultado', resultado),
          const SizedBox(height: 24),
          Text(
            resultado == 'PENDENTE'
                ? 'A API não retornou um diagnóstico. O atendimento foi salvo e aguarda validação.'
                : 'Resultado retornado pela API.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('FINALIZAR'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => ListTile(
    title: Text(label),
    trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}
