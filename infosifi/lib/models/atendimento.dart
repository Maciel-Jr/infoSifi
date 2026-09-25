class Atendimento {
  const Atendimento({
    this.id,
    required this.nomePaciente,
    required this.dataNascimento,
    required this.whatsapp,
    required this.codigoAtendimento,
    required this.tipoTeste,
    required this.lote,
    required this.validade,
    required this.dataRealizacao,
    required this.profissionalResponsavel,
    this.imagem,
    this.resultado,
    this.cadastrado,
    this.mensagem,
  });

  final int? id;
  final String nomePaciente;
  final String dataNascimento;
  final String whatsapp;
  final String codigoAtendimento;
  final String tipoTeste;
  final String lote;
  final String validade;
  final String dataRealizacao;
  final String profissionalResponsavel;
  final String? imagem;
  final String? resultado;
  final bool? cadastrado;
  final String? mensagem;

  factory Atendimento.fromJson(Map<String, dynamic> json) {
    return Atendimento(
      id: json['id'] as int?,
      nomePaciente: '${json['nomePaciente'] ?? json['nome_paciente'] ?? ''}',
      dataNascimento:
          '${json['dataNascimento'] ?? json['data_nascimento'] ?? ''}',
      whatsapp: '${json['whatsapp'] ?? ''}',
      codigoAtendimento:
          '${json['codigoAtendimento'] ?? json['codigo_atendimento'] ?? ''}',
      tipoTeste: '${json['tipoTeste'] ?? json['tipo_teste'] ?? ''}',
      lote: '${json['lote'] ?? ''}',
      validade: '${json['validade'] ?? ''}',
      dataRealizacao:
          '${json['dataRealizacao'] ?? json['data_realizacao'] ?? ''}',
      profissionalResponsavel:
          '${json['profissionalResponsavel'] ?? json['profissional_responsavel'] ?? ''}',
      imagem: json['imagem']?.toString(),
      resultado: (json['resultado'] ?? json['result'] ?? json['status'])
          ?.toString(),
      cadastrado: json['cadastrado'] is bool
          ? json['cadastrado'] as bool
          : null,
      mensagem: json['mensagem']?.toString(),
    );
  }
}
