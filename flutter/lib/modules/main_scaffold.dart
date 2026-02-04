import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/ui/widgets/reactive_header.dart';
import 'package:cii/modules/home/presentation/pages/home_page.dart';
import 'package:cii/modules/water/presentation/pages/water_tab_content.dart';
import 'package:cii/modules/environment/presentation/pages/environment_tab_content.dart';
import 'package:cii/modules/events/presentation/pages/events_tab_content.dart';
import 'package:cii/core/widgets/system_monitor.dart';
import 'package:cii/core/providers/error_notifier.dart';

import 'package:cii/core/providers/navigation_provider.dart';

/// Scaffold principal do aplicativo com Bottom Navigation Bar
///
/// Conforme app_ui_blueprint.md:
/// - 4 abas: Casa, Água, Ambiente, Eventos
/// - Reactive Header persistente
/// - Animação de escala no ícone selecionado
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navigationTabProvider);
    final theme = Theme.of(context);

    // ✅ FASE 1: Listener para exibir erros via SnackBar
    ref.listen<String?>(errorNotifierProvider, (prev, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Auto-clear após mostrar
        Future.delayed(const Duration(seconds: 3), () {
          ref.read(errorNotifierProvider.notifier).clear();
        });
      }
    });

    return Scaffold(
      body: SystemMonitor(
        child: Column(
          children: [
            // Header reativo persistente
            const ReactiveHeader(),

            // Conteúdo da aba selecionada
            Expanded(child: _buildTabContent(currentTab)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab.index,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          ref
              .read(navigationTabProvider.notifier)
              .setTab(NavigationTab.values[index]);
        },
        items: [
          _buildNavigationItem(
            icon: Icons.home,
            label: 'Casa',
            isSelected: currentTab == NavigationTab.home,
          ),
          _buildNavigationItem(
            icon: Icons.water_drop,
            label: 'Água',
            isSelected: currentTab == NavigationTab.water,
          ),
          _buildNavigationItem(
            icon: Icons.thermostat,
            label: 'Ambiente',
            isSelected: currentTab == NavigationTab.environment,
          ),
          _buildNavigationItem(
            icon: Icons.notifications_active,
            label: 'Eventos',
            isSelected: currentTab == NavigationTab.events,
          ),
        ],
      ),
    );
  }

  /// Constrói o item do bottom navigation com animação de escala
  BottomNavigationBarItem _buildNavigationItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Icon(icon),
      ),
      label: label,
    );
  }

  /// Retorna o widget apropriado para a aba selecionada
  Widget _buildTabContent(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return const _HomeTabContent();
      case NavigationTab.water:
        return const _WaterTabContent();
      case NavigationTab.environment:
        return const _EnvironmentTabContent();
      case NavigationTab.events:
        return const _EventsTabContent();
    }
  }
}

/// Conteúdo da aba Casa
class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    // Reutiliza o HomePage existente (sem header, já está no MainScaffold)
    return const HomePage();
  }
}

/// Conteúdo da aba Água
class _WaterTabContent extends StatelessWidget {
  const _WaterTabContent();

  @override
  Widget build(BuildContext context) {
    return const WaterTabContent();
  }
}

/// Conteúdo da aba Ambiente
class _EnvironmentTabContent extends StatelessWidget {
  const _EnvironmentTabContent();

  @override
  Widget build(BuildContext context) {
    return const EnvironmentTabContent();
  }
}

/// Conteúdo da aba Eventos
class _EventsTabContent extends StatelessWidget {
  const _EventsTabContent();

  @override
  Widget build(BuildContext context) {
    return const EventsTabContent();
  }
}
