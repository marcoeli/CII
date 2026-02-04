import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

class ProvisioningService {
  final _log = Logger('ProvisioningService');
  static const String deviceIp = '192.168.4.1';

  Future<bool> bootstrapDevice({
    required String ssid,
    required String password,
    required String tenant,
    required String home,
    String? devToken,
    String? claimCode,
    bool isDevMode = false,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    try {
      _log.info('Connecting to device at $deviceIp...');
      final request = await client.post(deviceIp, 80, '/api/wifi');
      request.headers.set('Content-Type', 'application/json');

      final body = {
        'ssid': ssid,
        'password': password,
        'tenant': tenant,
        'home': home,
        if (isDevMode && devToken != null) 'dev_token': devToken,
        if (!isDevMode && claimCode != null) 'claim_code': claimCode,
        'auth_mode': isDevMode ? 'dev' : 'prod',
      };

      _log.fine('Sending bootstrap payload: ${jsonEncode(body)}');
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      _log.info('Device response (${response.statusCode}): $responseBody');

      if (response.statusCode != 200) return false;

      final json = jsonDecode(responseBody);
      return json['ok'] == true;
    } catch (e) {
      _log.severe('Error bootstrapping device: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// Verifica se o dispositivo está acessível no modo SoftAP
  Future<bool> isDeviceAccessible() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.get(deviceIp, 80, '/api/mode');
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }
}




