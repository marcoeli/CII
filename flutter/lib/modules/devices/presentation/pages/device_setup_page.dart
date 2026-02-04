import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceSetupPage extends ConsumerStatefulWidget {
  const DeviceSetupPage({super.key});

  @override
  ConsumerState<DeviceSetupPage> createState() => _DeviceSetupPageState();
}

class _DeviceSetupPageState extends ConsumerState<DeviceSetupPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantController = TextEditingController();
  final _homeController = TextEditingController();

  bool _isSubmitting = false;
  String? _statusMessage;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _tenantController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Dispositivo')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (!_isSubmitting)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(
                      _currentStep == 2 ? 'ENVIAR CONFIGURAÇÃO' : 'CONTINUAR',
                    ),
                  ),
                if (!_isSubmitting)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('VOLTAR'),
                  ),
                if (_isSubmitting) const CircularProgressIndicator(),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Conectar ao Dispositivo'),
            subtitle: const Text('Modo SoftAP'),
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Conecte o Wi-Fi do seu celular à rede do dispositivo.',
                ),
                Text(
                  'A rede deve começar com "ICODZ_SETUP_".',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('2. Após conectar, volte para este app.'),
                SizedBox(height: 12),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Dados do Wi-Fi'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _ssidController,
                    decoration: const InputDecoration(
                      labelText: 'SSID (Nome da sua rede)',
                    ),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha do Wi-Fi',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Contexto (Tenant/Home)'),
            content: Column(
              children: [
                TextFormField(
                  controller: _tenantController,
                  decoration: const InputDecoration(
                    labelText: 'Tenant (ID do proprietário)',
                  ),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                TextFormField(
                  controller: _homeController,
                  decoration: const InputDecoration(
                    labelText: 'ID da Residência (Home)',
                  ),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                if (_statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _statusMessage!.contains('Sucesso')
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Enviando dados para o dispositivo...';
    });

    try {
      final payload = {
        'wifi_ssid': _ssidController.text,
        'wifi_pass': _passwordController.text,
        'tenant': _tenantController.text,
        'home': _homeController.text,
      };

      // ESP32 SoftAP IP padrão: 192.168.4.1
      final response = await http
          .post(
            Uri.parse('http://192.168.4.1/config'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(
          () => _statusMessage =
              'Sucesso! O dispositivo irá reiniciar e se conectar.',
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(
          () => _statusMessage =
              'Erro: Dispositivo retornou ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(
        () => _statusMessage =
            'Erro de conexão: Certifique-se de estar conectado ao Wi-Fi do dispositivo.',
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
