import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';

class WifiProvisioningPage extends ConsumerStatefulWidget {
  const WifiProvisioningPage({super.key});

  @override
  ConsumerState<WifiProvisioningPage> createState() =>
      _WifiProvisioningPageState();
}

class _WifiProvisioningPageState extends ConsumerState<WifiProvisioningPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(selectedTenantProvider);
    final home = ref.watch(selectedHomeProvider);

    if (tenant == null || home == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provisionamento')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_work_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecione um Perfil e uma Residência antes de começar.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('VOLTAR'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Provisionar Dispositivo')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () => _handleNext(tenant.tenantId, home.homeId),
        onStepCancel: _currentStep > 0
            ? () => setState(() => _currentStep--)
            : null,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : details.onStepContinue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _currentStep == 2
                              ? 'CONFIGURAR DISPOSITIVO'
                              : 'PRÓXIMO',
                        ),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _isLoading ? null : details.onStepCancel,
                    child: const Text('VOLTAR'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Conectar ao Dispositivo'),
            content: const Text(
              '1. Ligue o dispositivo.\n'
              '2. Conecte seu celular ao Wi-Fi "CII-Setup-XXXX".\n'
              '3. Clique em Próximo quando estiver conectado.',
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Dados da sua Rede'),
            content: Column(
              children: [
                TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do seu Wi-Fi (SSID)',
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha do seu Wi-Fi',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Revisar Contexto'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('O dispositivo será configurado para:'),
                const SizedBox(height: 8),
                Text(
                  'Inquilino: ${tenant.tenantId} (${tenant.name})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Residência: ${home.homeId} (${home.label})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nota: Estas informações são automáticas baseadas no seu perfil ativo.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(String tenantId, String homeId) async {
    if (_currentStep == 0) {
      setState(() => _isLoading = true);
      final accessible = await ref
          .read(provisioningServiceProvider)
          .isDeviceAccessible();
      setState(() => _isLoading = false);

      if (accessible) {
        setState(() => _currentStep++);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dispositivo não encontrado em 192.168.4.1. Verifique o Wi-Fi.',
              ),
            ),
          );
        }
      }
      return;
    }

    if (_currentStep == 1) {
      if (_ssidController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha os dados do seu Wi-Fi.')),
        );
        return;
      }
      setState(() => _currentStep++);
      return;
    }

    if (_currentStep == 2) {
      setState(() => _isLoading = true);
      final ok = await ref
          .read(provisioningServiceProvider)
          .bootstrapDevice(
            ssid: _ssidController.text.trim(),
            password: _passwordController.text,
            tenant: tenantId,
            home: homeId,
            isDevMode: true,
          );
      setState(() => _isLoading = false);

      if (ok) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Sucesso!'),
              content: const Text(
                'O dispositivo foi configurado e irá reiniciar. Você já pode voltar para sua rede Wi-Fi normal.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao enviar configurações.')),
          );
        }
      }
    }
  }
}
