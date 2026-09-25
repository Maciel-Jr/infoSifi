import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';
import '../services/authService.dart';
import '../viewModels/novoTesteViewModels.dart';
import 'dadosDoTeste.dart';
import 'login.dart';

class Novoteste extends StatefulWidget {
  const Novoteste({super.key, this.viewModel});
  final NovoTesteViewModel? viewModel;

  @override
  State<Novoteste> createState() => _NovotesteState();
}

class _NovotesteState extends State<Novoteste> {
  late final NovoTesteViewModel _viewModel;
  final _nome = TextEditingController();
  final _nascimento = TextEditingController();
  final _whatsapp = TextEditingController();
  final _codigo = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? NovoTesteViewModel();
  }

  @override
  void dispose() {
    _nome.dispose();
    _nascimento.dispose();
    _whatsapp.dispose();
    _codigo.dispose();
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await Authservice().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  void _continuar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Dadosdoteste(
          viewModel: _viewModel,
          nomePaciente: _nome.text.trim(),
          dataNascimento: _nascimento.text.trim(),
          whatsapp: _whatsapp.text.trim(),
          codigoAtendimento: _codigo.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Novo atendimento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.groups, size: 64, color: Color(0xFF6A1B9A)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(_nome, 'Nome do paciente', maxLength: 100),
                  _field(
                    _nascimento,
                    'Data de nascimento (dd/MM/aaaa)',
                    mask: '##/##/####',
                    keyboardType: TextInputType.number,
                  ),
                  _field(
                    _whatsapp,
                    'Whatsapp',
                    maxLength: 15,
                    keyboardType: TextInputType.phone,
                  ),
                  _field(_codigo, 'Código do atendimento', maxLength: 15),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _button('INICIAR TESTE', _continuar),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? mask,
    int? maxLength,
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: [
        if (mask != null) MaskTextInputFormatter(mask: mask),
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: _decoration(label),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
    ),
  );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _button(String label, VoidCallback onPressed) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6A1B9A),
      foregroundColor: Colors.white,
      minimumSize: const Size(220, 50),
    ),
    child: Text(label),
  );
}
