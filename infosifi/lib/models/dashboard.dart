class DashboardData {
  const DashboardData({
    required this.atendimentosRealizados,
    required this.naoReagentes,
    required this.reagentes,
    required this.inconclusivos,
    required this.testesPorDia,
    required this.tempoMedioValidacao,
    required this.taxaReagentes,
  });

  final int atendimentosRealizados;
  final int naoReagentes;
  final int reagentes;
  final int inconclusivos;
  final List<DashboardPoint> testesPorDia;
  final String tempoMedioValidacao;
  final double taxaReagentes;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final series = _value(json, [
      'testesPorDia',
      'testes_por_dia',
      'atendimentosPorDia',
      'atendimentos_por_dia',
      'daily',
    ]);
    return DashboardData(
      atendimentosRealizados: _intValue(json, [
        'atendimentosRealizados',
        'atendimentos_realizados',
        'totalAtendimentos',
        'total_atendimentos',
        'total',
      ]),
      naoReagentes: _intValue(json, [
        'total_nao_reagentes',
        'naoReagentes',
        'nao_reagentes',
        'nãoReagentes',
        'nao_reagente',
      ]),
      reagentes: _intValue(json, [
        'total_reagentes',
        'totalReagentes',
        'reagentes',
        'reagente',
      ]),
      inconclusivos: _intValue(json, [
        'total_inconclusivos',
        'totalInconclusivos',
        'inconclusivos',
        'invalidos',
        'inválidos',
        'invalidosCount',
        'invalidos_count',
      ]),
      testesPorDia: _points(series),
      tempoMedioValidacao: _stringValue(json, [
        'tempoMedioValidacao',
        'tempo_medio_validacao',
        'tempoMedioAteValidacao',
        'tempo_medio_ate_validacao',
      ], fallback: '-'),
      taxaReagentes: _doubleValue(json, [
        'taxaReagentes',
        'taxa_reagentes',
        'taxaResultadosReagentes',
        'taxa_resultados_reagentes',
      ]),
    );
  }

  static dynamic _value(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static int _intValue(Map<String, dynamic> json, List<String> keys) {
    final value = _value(json, keys);
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  static double _doubleValue(Map<String, dynamic> json, List<String> keys) {
    final value = _value(json, keys);
    if (value is num) return value.toDouble();
    return double.tryParse('$value'.replaceAll('%', '').replaceAll(',', '.')) ??
        0;
  }

  static String _stringValue(
    Map<String, dynamic> json,
    List<String> keys, {
    required String fallback,
  }) {
    final value = _value(json, keys);
    if (value == null || '$value'.isEmpty) return fallback;
    return '$value';
  }

  static List<DashboardPoint> _points(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) {
      final data = item.cast<String, dynamic>();
      final label =
          data['label'] ?? data['data'] ?? data['date'] ?? data['dia'];
      final count =
          data['value'] ?? data['valor'] ?? data['count'] ?? data['total'];
      return DashboardPoint(
        label: '$label',
        value: count is num ? count.toDouble() : double.tryParse('$count') ?? 0,
      );
    }).toList();
  }
}

class DashboardPoint {
  const DashboardPoint({required this.label, required this.value});

  final String label;
  final double value;
}
