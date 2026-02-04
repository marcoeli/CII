import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/home/widgets/home_cards.dart';
import 'package:cii/core/services/alert_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final AlertService _alertService = AlertService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mqttRepositoryProvider).connect();
    });
  }

  @override
  void dispose() {
    _alertService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removida em favor do ReactiveHeader global (MainScaffold)
      body: CustomScrollView(
        slivers: [
          // Grid de Destaques (Cards Vivos)
          _buildStatusCards(context),

          // Grid de Destaques (Cards Vivos)
          _buildStatusCards(context),

          // Espaço extra
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  /// Grid de cards de status (Água, Ambiente, Eventos, Analytics)
  Widget _buildStatusCards(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1, // Quadrado/Retangular para "Big Widgets"
        ),
        delegate: SliverChildListDelegate([
          const WaterStatusCard(),
          const EnvironmentStatusCard(),
          const EventsStatusCard(),
          const AnalyticsStatusCard(), // ✅ Novo Card
        ]),
      ),
    );
  }

  /// Determina número de colunas baseado na largura da tela
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 3; // Desktop
    if (width >= 600) return 2; // Tablet
    return 1; // Mobile: 1 coluna para destaque (Big Cards)
  }
}
