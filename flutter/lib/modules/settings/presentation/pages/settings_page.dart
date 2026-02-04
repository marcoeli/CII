import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/theme/app_themes.dart';
import 'package:cii/core/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          // Theme Selection Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tema do Aplicativo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.nebula,
                      label: Text('Nebula'),
                      icon: Icon(Icons.gradient),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.deepOcean,
                      label: Text('Ocean'),
                      icon: Icon(Icons.water),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.midnight,
                      label: Text('Midnight'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {currentTheme},
                  onSelectionChanged: (Set<AppThemeMode> newSelection) {
                    themeNotifier.setTheme(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // Context Management
          ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: const Text('Gerenciar Residências'),
            subtitle: const Text('Alternar entre Tenants e Homes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Modular.to.pushNamed('/settings/context'),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin_circle_outlined),
            title: const Text('Selecionar Perfil'),
            subtitle: const Text('Trocar ou criar Tenants (Inquilinos)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Modular.to.pushNamed('/settings/tenant-selector'),
          ),
          const Divider(),

          // Device Management
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Gerenciar Dispositivos'),
            subtitle: const Text('Renomear e organizar dispositivos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Modular.to.pushNamed('/settings/devices'),
          ),
          const Divider(),

          // Wi-Fi Configuration

          // Wi-Fi Configuration
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Configurar Wi-Fi dos Dispositivos'),
            subtitle: const Text('Provisionamento de novos hardwares'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Modular.to.pushNamed('/settings/setup'),
          ),
          const Divider(),

          // About Section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre o App'),
            subtitle: const Text('Versão 1.0.0 (V2.4 Architecture)'),
          ),
          const Divider(),

          // Dev Tools Section
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('Ferramentas de Desenvolvedor'),
            subtitle: const Text('Diagnóstico, MQTT e Reset de Banco'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Modular.to.pushNamed('/dev/'),
          ),
        ],
      ),
    );
  }
}
