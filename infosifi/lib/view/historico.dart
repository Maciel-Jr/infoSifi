import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../services/atendimento_service.dart';
import '../services/authService.dart';
import 'login.dart';

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final AtendimentoService _service = AtendimentoService();
  late Future<List<Atendimento>> _atendimentos;

  @override
  void initState() {
    super.initState();
    _atendimentos = _carregar();
  }

  Future<List<Atendimento>> _carregar() async {
    try {
      return await _service.listar();
    } on SessionExpiredException {
      await _irParaLogin();
      return [];
    }
  }

  Future<void> _irParaLogin() async {
    await Authservice().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  Future<void> _handleLogout() async {
    await Authservice().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  Future<void> _abrirDetalhe(Atendimento atendimento) async {
    if (atendimento.id == null) return;
    try {
      final detalhe = await _service.buscarPorId(atendimento.id!);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AtendimentoDetalhe(atendimento: detalhe),
        ),
      );
    } on SessionExpiredException {
      await _irParaLogin();
    } catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<Atendimento>>(
        future: _atendimentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _mensagem(snapshot.error.toString());
          }
          final atendimentos = snapshot.data ?? [];
          if (atendimentos.isEmpty) {
            return _mensagem('Nenhum atendimento encontrado.');
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _atendimentos = _carregar());
              await _atendimentos;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: atendimentos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final atendimento = atendimentos[index];
                return ListTile(
                  tileColor: const Color(0xFFF4EAF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(atendimento.nomePaciente),
                  subtitle: Text(
                    '${atendimento.codigoAtendimento} • ${atendimento.tipoTeste}\n'
                    'Resultado: ${atendimento.resultado?.isNotEmpty == true ? atendimento.resultado : 'PENDENTE'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _abrirDetalhe(atendimento),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _mensagem(String texto) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(texto, textAlign: TextAlign.center),
    ),
  );
}

class AtendimentoDetalhe extends StatelessWidget {
  const AtendimentoDetalhe({super.key, required this.atendimento});
  final Atendimento atendimento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do atendimento')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.assignment_turned_in, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          _linha('Paciente', atendimento.nomePaciente),
          _linha('Data de nascimento', atendimento.dataNascimento),
          _linha('WhatsApp', atendimento.whatsapp),
          _linha('Código', atendimento.codigoAtendimento),
          _linha('Tipo de teste', atendimento.tipoTeste),
          _linha('Lote', atendimento.lote),
          _linha('Validade', atendimento.validade),
          _linha('Realização', atendimento.dataRealizacao),
          _linha('Profissional', atendimento.profissionalResponsavel),
          _linha('Resultado do reagente', atendimento.resultado ?? 'PENDENTE'),
        ],
      ),
    );
  }

  Widget _linha(String titulo, String valor) => ListTile(
    title: Text(titulo),
    subtitle: Text(
      valor.isEmpty ? '-' : valor,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
