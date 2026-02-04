import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/settings/presentation/providers/home_provider.dart';

class HomeManagementPage extends ConsumerStatefulWidget {
  const HomeManagementPage({super.key});

  @override
  ConsumerState<HomeManagementPage> createState() => _HomeManagementPageState();
}

class _HomeManagementPageState extends ConsumerState<HomeManagementPage> {
  final _homeController = TextEditingController();
  final _labelController = TextEditingController();

  void _showAddHomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Residência'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _homeController,
              decoration: const InputDecoration(
                labelText: 'Home ID (ex: casa_01)',
              ),
            ),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Nome Amigável'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final homeId = _homeController.text.trim();
              final label = _labelController.text.trim();
              final activeTenant = ref.read(selectedTenantProvider);

              if (homeId.isNotEmpty &&
                  label.isNotEmpty &&
                  activeTenant != null) {
                try {
                  final db = ref.read(databaseProvider);
                  await db.tenantsHomesDao.upsertHome(
                    HomesCompanion.insert(
                      tenantId: activeTenant.id,
                      homeId: homeId,
                      label: label,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Residência "$label" criada com sucesso!',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Erro ao criar home: $e');
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantAsync = ref.watch(selectedTenantProvider);
    final homesAsync = ref.watch(allHomesProvider);
    final activeHome = ref.watch(selectedHomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Residências')),
      body: tenantAsync == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum inquilino selecionado.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/settings/tenant-selector',
                    ),
                    child: const Text('SELECIONAR OU CRIAR PERFIL'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                ListTile(
                  title: Text('Inquilino: ${tenantAsync.name}'),
                  subtitle: Text('ID Técncio: ${tenantAsync.tenantId}'),
                ),
                const Divider(),
                Expanded(
                  child: homesAsync.when(
                    data: (homes) {
                      if (homes.isEmpty) {
                        return const Center(
                          child: Text('Nenhuma residência encontrada.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: homes.length,
                        itemBuilder: (context, index) {
                          final home = homes[index];
                          final isActive = activeHome?.id == home.id;

                          return ListTile(
                            leading: Icon(
                              Icons.home,
                              color: isActive ? Colors.blue : Colors.grey,
                            ),
                            title: Text(home.label),
                            subtitle: Text('Home ID: ${home.homeId}'),
                            trailing: isActive
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () {
                              ref
                                  .read(sessionProvider.notifier)
                                  .setContext(home: home);
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro: $e')),
                  ),
                ),
              ],
            ),
      floatingActionButton: tenantAsync != null
          ? FloatingActionButton(
              onPressed: _showAddHomeDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
