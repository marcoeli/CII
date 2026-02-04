import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/settings/presentation/providers/home_provider.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';

class HomeSelectorPage extends ConsumerWidget {
  const HomeSelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(selectedTenantProvider);
    final homesAsync = ref.watch(allHomesProvider);
    final selectedHome = ref.watch(selectedHomeProvider);

    if (tenant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Selecionar Residência')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Selecione um perfil primeiro.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/settings/tenant-selector'),
                child: const Text('IR PARA SELEÇÃO DE PERFIL'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Residências de ${tenant.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateHomeDialog(context, ref, tenant),
          ),
        ],
      ),
      body: homesAsync.when(
        data: (homes) {
          if (homes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhuma residência cadastrada para este perfil.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        _showCreateHomeDialog(context, ref, tenant),
                    child: const Text('CADASTRAR MINHA PRIMEIRA CASA'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: homes.length,
            itemBuilder: (context, index) {
              final home = homes[index];
              final isSelected = selectedHome?.id == home.id;

              return RadioListTile<int>(
                title: Text(home.label),
                subtitle: Text(home.homeId),
                value: home.id,
                groupValue: selectedHome?.id,
                onChanged: (_) {
                  ref
                      .read(sessionProvider.notifier)
                      .setContext(tenant: tenant, home: home);
                  Navigator.pop(context);
                },
                secondary: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                selected: isSelected,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  void _showCreateHomeDialog(
    BuildContext context,
    WidgetRef ref,
    TenantEntity tenant,
  ) {
    final labelController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Residência'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Nome (ex: Minha Casa)',
              ),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID Técnico (ex: casa_1)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (labelController.text.isNotEmpty &&
                  idController.text.isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.tenantsHomesDao.upsertHome(
                  HomesCompanion.insert(
                    tenantId: tenant.id,
                    homeId: idController.text.trim(),
                    label: labelController.text.trim(),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('CRIAR'),
          ),
        ],
      ),
    );
  }
}
