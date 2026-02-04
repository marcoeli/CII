import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';

class ProvisioningWizardPage extends ConsumerStatefulWidget {
  const ProvisioningWizardPage({super.key});

  @override
  ConsumerState<ProvisioningWizardPage> createState() =>
      _ProvisioningWizardPageState();
}

class _ProvisioningWizardPageState
    extends ConsumerState<ProvisioningWizardPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantController = TextEditingController();
  final _homeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with current context if available
    Future.microtask(() async {
      final context = await ref
          .read(secureCredentialsServiceProvider)
          .getContext();
      if (mounted) {
        setState(() {
          _tenantController.text = context?['tenant'] ?? '';
          _homeController.text = context?['home'] ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'NOVO DISPOSITIVO',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(child: _buildCurrentStepView()),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.blue
                        : (isActive
                              ? Colors.blue.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.1)),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < _currentStep
                          ? Colors.blue
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildCheckConnectionStep();
      case 2:
        return _buildCredentialsStep();
      case 3:
        return _buildFinalStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroStep() {
    return _buildStepBase(
      icon: Icons.wifi_tethering_rounded,
      title: 'Modo de Configuração',
      description:
          'Ligue o dispositivo e conecte seu celular à rede Wi-Fi:\n\n"CII-Setup-XXXX"\n\nSenha: 12345678 (se solicitado)',
    );
  }

  Widget _buildCheckConnectionStep() {
    return _buildStepBase(
      icon: _isLoading ? Icons.sync : Icons.router_rounded,
      title: 'Buscando Hardware',
      description: _isLoading
          ? 'Tentando contato com o dispositivo (192.168.4.1)...'
          : 'Clique em "PRÓXIMO" quando estiver conectado ao Wi-Fi do dispositivo.',
      child: _isLoading ? const CircularProgressIndicator() : null,
    );
  }

  Widget _buildCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'CONFIGURAÇÃO DE REDE',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(_ssidController, 'SSID da sua Rede', Icons.wifi),
          const SizedBox(height: 16),
          _buildTextField(
            _passwordController,
            'Senha do Wi-Fi',
            Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _tenantController,
                  'Tenant',
                  Icons.business,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _homeController,
                  'Home ID',
                  Icons.home_work_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'O dispositivo irá reiniciar e tentar se conectar ao broker MQTT usando estas credenciais.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return _buildStepBase(
      icon: Icons.check_circle_outline,
      title: 'Envio Concluído!',
      description:
          'As configurações foram enviadas. O dispositivo agora irá reiniciar.\n\nVocê já pode voltar para sua rede Wi-Fi normal.',
    );
  }

  Widget _buildStepBase({
    required IconData icon,
    required String title,
    required String description,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.blue),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          if (child != null) ...[const SizedBox(height: 32), child],
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0 && _currentStep < 3)
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _currentStep--),
              child: const Text('VOLTAR'),
            )
          else
            const SizedBox.shrink(),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(_currentStep == 3 ? 'CONCLUIR' : 'PRÓXIMO'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      setState(() => _currentStep++);
      return;
    }

    if (_currentStep == 1) {
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
                'Não foi possível encontrar o dispositivo. Você está no Wi-Fi correto?',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      return;
    }

    if (_currentStep == 2) {
      if (_ssidController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha os dados da rede Wi-Fi')),
        );
        return;
      }

      setState(() => _isLoading = true);
      final ok = await ref
          .read(provisioningServiceProvider)
          .bootstrapDevice(
            ssid: _ssidController.text,
            password: _passwordController.text,
            tenant: _tenantController.text,
            home: _homeController.text,
            isDevMode: true, // For demo purposes
          );
      setState(() => _isLoading = false);

      if (ok) {
        setState(() => _currentStep++);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Falha ao enviar configurações para o dispositivo.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    if (_currentStep == 3) {
      Navigator.pop(context);
    }
  }
}
