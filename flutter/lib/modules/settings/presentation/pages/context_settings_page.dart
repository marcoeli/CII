import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';

class ContextSettingsPage extends ConsumerStatefulWidget {
  const ContextSettingsPage({super.key});

  @override
  ConsumerState<ContextSettingsPage> createState() =>
      _ContextSettingsPageState();
}

class _ContextSettingsPageState extends ConsumerState<ContextSettingsPage> {
  final _tenantController = TextEditingController();
  final _homeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentContext();
  }

  Future<void> _loadCurrentContext() async {
    setState(() => _isLoading = true);
    final context = await ref
        .read(secureCredentialsServiceProvider)
        .getContext();
    if (mounted) {
      setState(() {
        _tenantController.text = context?['tenant'] ?? '';
        _homeController.text = context?['home'] ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContext() async {
    if (_tenantController.text.isEmpty || _homeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final secureStorage = ref.read(secureCredentialsServiceProvider);
      await secureStorage.saveContext(
        tenant: _tenantController.text.trim(),
        home: _homeController.text.trim(),
      );

      // Trigger MQTT refresh to update subscriptions with new context
      await ref.read(mqttRepositoryProvider).refreshDevices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contexto atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar contexto: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Residência')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Defina o contexto da sua residência para que o aplicativo possa descobrir seus dispositivos.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _tenantController,
                    decoration: const InputDecoration(
                      labelText: 'Tenant (Inquilino)',
                      hintText: 'ex: marco',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _homeController,
                    decoration: const InputDecoration(
                      labelText: 'Home ID (Residência)',
                      hintText: 'ex: casa_principal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  _buildActivationStatus(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showActivationDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('ATIVAR COM CLAIM CODE'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveContext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('SALVAR CONFIGURAÇÃO'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActivationStatus() {
    return FutureBuilder(
      future: ref.read(secureCredentialsServiceProvider).getMqttCredentials(),
      builder: (context, snapshot) {
        final hasCreds = snapshot.hasData && snapshot.data != null;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasCreds
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hasCreds ? Colors.green : Colors.orange),
          ),
          child: Row(
            children: [
              Icon(
                hasCreds ? Icons.verified_user : Icons.warning_amber,
                color: hasCreds ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCreds ? 'App Ativado' : 'App Não Ativado',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasCreds ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      hasCreds
                          ? 'Credenciais seguras configuradas.'
                          : 'É necessário um Claim Code para acesso seguro.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivationDialog() {
    final claimController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ativação Segura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Insira o Claim Code fornecido pelo proprietário da residência.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: claimController,
              decoration: const InputDecoration(
                labelText: 'Claim Code',
                hintText: 'ex: 123456',
                border: OutlineInputBorder(),
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
              if (claimController.text.isEmpty) return;
              Navigator.pop(context); // Fecha dialog
              _handleActivation(claimController.text.trim());
            },
            child: const Text('ATIVAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleActivation(String claimCode) async {
    setState(() => _isLoading = true);
    try {
      final success = await ref
          .read(appProvisioningServiceProvider)
          .bootstrapApp(
            tenant: _tenantController.text.trim(),
            home: _homeController.text.trim(),
            claimCode: claimCode,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App ativado com sucesso! Reconectando...'),
              backgroundColor: Colors.green,
            ),
          );
          // Força reconexão com novas credenciais
          ref.read(mqttRepositoryProvider).connect();
          _loadCurrentContext(); // Recarrega UI
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Falha na ativação. Verifique o código e o contexto.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tenantController.dispose();
    _homeController.dispose();
    super.dispose();
  }
}
