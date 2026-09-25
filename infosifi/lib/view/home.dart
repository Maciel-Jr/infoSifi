import 'package:flutter/material.dart';
import '../models/dashboard.dart';
import '../services/atendimento_service.dart';
import '../services/authService.dart';
import 'login.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _service = AtendimentoService();
  late Future<DashboardData> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = _load();
  }

  Future<DashboardData> _load() async {
    try {
      return DashboardData.fromJson(await _service.dashboard());
    } on SessionExpiredException {
      await _logout();
      rethrow;
    }
  }

  Future<void> _logout() async {
    await Authservice().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  Future<void> _refresh() async {
    setState(() => _dashboard = _load());
    await _dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo geral'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _ErrorView(
              message:
                  snapshot.error?.toString().replaceFirst('Exception: ', '') ??
                  'A API não retornou dados para o dashboard.',
              onRetry: () => setState(() => _dashboard = _load()),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _Dashboard(data: snapshot.data!),
          );
        },
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Indicadores dos atendimentos realizados.'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: compact ? 2 : 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: compact ? 1.35 : 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _Summary(
              'Atendimentos realizados',
              data.atendimentosRealizados,
              Icons.groups_2,
              const Color(0xFFE8F3FB),
              const Color(0xFF2587B8),
            ),
            _Summary(
              'Não reagentes',
              data.naoReagentes,
              Icons.add_circle,
              const Color(0xFFEAF7E8),
              const Color(0xFF2BAA62),
            ),
            _Summary(
              'Reagentes',
              data.reagentes,
              Icons.add_circle,
              const Color(0xFFFCEAEC),
              const Color(0xFFD33C4A),
            ),
            _Summary(
              'Inconclusivos',
              data.inconclusivos,
              Icons.help,
              const Color(0xFFFFF4E2),
              const Color(0xFFD59016),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (compact) ...[
          _Chart(points: data.testesPorDia),
          const SizedBox(height: 16),
          _Metrics(data: data),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Chart(points: data.testesPorDia)),
              const SizedBox(width: 16),
              SizedBox(width: 300, child: _Metrics(data: data)),
            ],
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary(
    this.label,
    this.value,
    this.icon,
    this.background,
    this.accent,
  );

  final String label;
  final int value;
  final IconData icon;
  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '$value',
              style: TextStyle(
                color: accent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.points});

  final List<DashboardPoint> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Testes por dia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: points.isEmpty
                  ? const Center(child: Text('Sem dados no período.'))
                  : CustomPaint(
                      painter: _ChartPainter(points),
                      child: const SizedBox.expand(),
                    ),
            ),
            if (points.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    points.first.label,
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(points.last.label, style: const TextStyle(fontSize: 11)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final rate = data.taxaReagentes <= 1
        ? data.taxaReagentes * 100
        : data.taxaReagentes;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _Metric(
              Icons.schedule,
              'Tempo médio até validação',
              data.tempoMedioValidacao,
              const Color(0xFF27305C),
            ),
            const Divider(height: 28),
            _Metric(
              Icons.water_drop,
              'Taxa de resultados reagentes',
              '${rate.toStringAsFixed(1)}%',
              const Color(0xFFD33C4A),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.label, this.value, this.color);

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.points);

  final List<DashboardPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(28, 8, size.width - 36, size.height - 20);
    final values = points.map((point) => point.value).toList();
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final scale = maximum == 0 ? 1 : maximum;
    final grid = Paint()..color = const Color(0xFFE5E8F0);
    for (var index = 0; index < 4; index++) {
      final y = rect.top + rect.height * index / 3;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), grid);
    }
    final line = Paint()
      ..color = const Color(0xFF342266)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dots = Paint()..color = const Color(0xFF342266);
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? rect.center.dx
          : rect.left + rect.width * index / (values.length - 1);
      final point = Offset(
        x,
        rect.bottom - rect.height * values[index] / scale,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 4, dots);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.points != points;
}
