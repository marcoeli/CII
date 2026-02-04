import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/settings/presentation/providers/tenant_provider.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';

class TenantSelectorPage extends ConsumerWidget {
  const TenantSelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(allTenantsProvider);
    final selectedTenant = ref.watch(selectedTenantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTenantDialog(context, ref),
          ),
        ],
      ),
      body: tenantsAsync.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Nenhum perfil cadastrado.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showCreateTenantDialog(context, ref),
                    child: const Text('CRIAR MEU PRIMEIRO PERFIL'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              final isSelected = selectedTenant?.id == tenant.id;

              return RadioListTile<int>(
                title: Text(tenant.name),
                subtitle: Text(tenant.tenantId),
                value: tenant.id,
                groupValue: selectedTenant?.id,
                onChanged: (_) {
                  ref
                      .read(sessionProvider.notifier)
                      .setContext(tenant: tenant, home: null);
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

  void _showCreateTenantDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome (ex: Marco)'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID Técnico (ex: marco)',
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
              if (nameController.text.isNotEmpty &&
                  idController.text.isNotEmpty) {
                final db = ref.read(databaseProvider);
                final id = idController.text.trim();

                await db.tenantsHomesDao.upsertTenant(
                  TenantsCompanion.insert(
                    tenantId: id,
                    name: nameController.text.trim(),
                  ),
                );

                // Fetch to get the ID
                final newTenant = await db.tenantsHomesDao.getTenantById(id);
                if (newTenant != null) {
                  ref
                      .read(sessionProvider.notifier)
                      .setContext(tenant: newTenant, home: null);
                }

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
