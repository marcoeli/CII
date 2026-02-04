import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/settings/presentation/providers/tenant_provider.dart';
import 'package:cii/modules/settings/presentation/providers/home_provider.dart';

class DevPage extends ConsumerStatefulWidget {
  const DevPage({super.key});

  @override
  ConsumerState<DevPage> createState() => _DevPageState();
}

class _DevPageState extends ConsumerState<DevPage> {
  final _passwordController = TextEditingController();
  bool _unlocked = false;

  void _checkPassword() {
    if (_passwordController.text == 'icodz') {
      setState(() => _unlocked = true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Senha Incorreta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Restrito')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha do Desenvolvedor',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _checkPassword(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPassword,
                child: const Text('Desbloquear'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Developer Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolCard(
            context,
            title: 'Limpar Banco de Dados',
            subtitle: 'Remove todos os tenants, homes e dispositivos locais.',
            icon: Icons.delete_forever,
            color: Colors.red,
            onTap: () => _showWipeConfirm(context),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            title: 'MQTT Inspector',
            subtitle: 'Visualizar logs de rede em tempo real (em breve).',
            icon: Icons.network_check,
            color: Colors.blue,
            onTap: () => Modular.to.pushNamed('/dev/inspector'),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            title: 'Forçar Inscrições (Resubscribe)',
            subtitle: 'Recarrega tenant/home e assina tópicos novamente.',
            icon: Icons.refresh,
            color: Colors.purple,
            onTap: () async {
              ref.read(mqttRepositoryProvider).refreshDevices();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comando de refresh enviado! Verifique logs.'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            title: 'Logs de Sistema',
            subtitle: 'Auditoria de comandos e eventos.',
            icon: Icons.list_alt,
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            title: 'Forçar Inicialização (Emergency)',
            subtitle: 'Tenta carregar o primeiro Tenant/Home encontrado no DB.',
            icon: Icons.healing,
            color: Colors.orange,
            onTap: () => _emergencyInit(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Future<void> _emergencyInit(BuildContext context) async {
    try {
      final db = ref.read(databaseProvider);

      // 1. Buscar Tenants
      final tenants = await db.tenantsHomesDao.watchAllTenants().first;
      if (tenants.isEmpty) {
        throw Exception('Nenhum Tenant encontrado no banco de dados!');
      }
      final tenant = tenants.first;

      // 2. Setar Tenant
      await ref.read(sessionProvider.notifier).setContext(tenant: tenant);

      // 3. Buscar Homes
      final homes = await db.tenantsHomesDao
          .watchHomesByTenant(tenant.id)
          .first;
      if (homes.isEmpty) {
        throw Exception(
          'Nenhuma Home encontrada para o tenant ${tenant.name}!',
        );
      }
      final home = homes.first;

      // 4. Setar Home
      await ref.read(sessionProvider.notifier).setContext(home: home);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Inicialização Forçada: ${tenant.name} / ${home.label}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na emergência: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showWipeConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Wipe?'),
        content: const Text(
          'Isso apagará TODA a configuração local do App. O App será reiniciado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final db = ref.read(databaseProvider);
                await db.wipeEverything();
                if (context.mounted) {
                  // Invalidate memory state immediately
                  ref.invalidate(sessionProvider);
                  // ref.invalidate(selectedTenantProvider);
                  // ref.invalidate(selectedHomeProvider);
                  ref.invalidate(allTenantsProvider);
                  ref.invalidate(allHomesProvider);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Banco limpo! Perfil resetado.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao limpar banco: $e')),
                  );
                }
              }
            },
            child: const Text(
              'APAGAR TUDO',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
