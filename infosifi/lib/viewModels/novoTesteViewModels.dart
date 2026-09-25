import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/atendimento.dart';
import '../services/atendimento_service.dart';

class NovoTesteViewModel extends ChangeNotifier {
  NovoTesteViewModel({AtendimentoService? service})
    : _service = service ?? AtendimentoService();

  final AtendimentoService _service;
  Atendimento? atendimento;
  File? imagem;
  bool enviando = false;
  String? erro;
  bool sessaoExpirada = false;

  void definirDados({
    required String nomePaciente,
    required String dataNascimento,
    required String whatsapp,
    required String codigoAtendimento,
    required String tipoTeste,
    required String lote,
    required String validade,
    required String dataRealizacao,
    required String profissionalResponsavel,
  }) {
    atendimento = Atendimento(
      nomePaciente: nomePaciente,
      dataNascimento: dataNascimento,
      whatsapp: whatsapp,
      codigoAtendimento: codigoAtendimento,
      tipoTeste: tipoTeste,
      lote: lote,
      validade: validade,
      dataRealizacao: dataRealizacao,
      profissionalResponsavel: profissionalResponsavel,
    );
    erro = null;
    sessaoExpirada = false;
    notifyListeners();
  }

  void definirImagem(File arquivo) {
    imagem = arquivo;
    erro = null;
    sessaoExpirada = false;
    notifyListeners();
  }

  Future<void> enviar() async {
    final dados = atendimento;
    final arquivo = imagem;
    if (dados == null || arquivo == null) {
      erro = 'Preencha os dados e fotografe o teste antes de continuar.';
      notifyListeners();
      return;
    }
    enviando = true;
    erro = null;
    notifyListeners();
    try {
      atendimento = await _service.criar(atendimento: dados, imagem: arquivo);
    } catch (exception) {
      sessaoExpirada = exception is SessionExpiredException;
      erro = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      enviando = false;
      notifyListeners();
    }
  }
}
