import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';
import '../viewModels/novoTesteViewModels.dart';
import 'fotoTeste.dart';

class Dadosdoteste extends StatefulWidget {
  const Dadosdoteste({
    super.key,
    required this.viewModel,
    required this.nomePaciente,
    required this.dataNascimento,
    required this.whatsapp,
    required this.codigoAtendimento,
  });
  final NovoTesteViewModel viewModel;
  final String nomePaciente;
  final String dataNascimento;
  final String whatsapp;
  final String codigoAtendimento;

  @override
  State<Dadosdoteste> createState() => _DadosdotesteState();
}

class _DadosdotesteState extends State<Dadosdoteste> {
  final _lote = TextEditingController();
  final _validade = TextEditingController();
  final _realizacao = TextEditingController();
  final _profissional = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _tipoTeste = 'Teste Rápido Sífilis';

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _realizacao.text =
        '${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';
  }

  @override
  void dispose() {
    _lote.dispose();
    _validade.dispose();
    _realizacao.dispose();
    _profissional.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.viewModel.definirDados(
      nomePaciente: widget.nomePaciente,
      dataNascimento: widget.dataNascimento,
      whatsapp: widget.whatsapp,
      codigoAtendimento: widget.codigoAtendimento,
      tipoTeste: _tipoTeste,
      lote: _lote.text.trim(),
      validade: _validade.text.trim(),
      dataRealizacao: _realizacao.text.trim(),
      profissionalResponsavel: _profissional.text.trim(),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Fototeste(viewModel: widget.viewModel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: const Color(0xFFFFF8FF),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Dados do teste',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _tipoTeste,
                  decoration: _decoration('Tipo de teste'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Teste Rápido Sífilis',
                      child: Text('Teste Rápido Sífilis'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _tipoTeste = value!),
                ),
                _field(_lote, 'Lote', maxLength: 15),
                _field(_validade, 'Validade (dd/MM/aaaa)', mask: '##/##/####'),
                _field(
                  _realizacao,
                  'Data de realização (dd/MM/aaaa)',
                  mask: '##/##/####',
                  keyboardType: TextInputType.number,
                ),
                _field(
                  _profissional,
                  'Profissional responsável',
                  maxLength: 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _continuar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 50),
            ),
            child: const Text('FOTOGRAFAR TESTE'),
          ),
        ],
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
    padding: const EdgeInsets.only(top: 16),
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
}
