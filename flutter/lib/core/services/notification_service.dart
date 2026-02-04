import 'dart:io';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

/// Serviço de notificações locais para alertas críticos
/// Suporta notificações críticas, avisos e informações
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final _log = Logger('NotificationService');

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) {
      _log.info('NotificationService já inicializado');
      return;
    }

    try {
      // Configurações Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Configurações iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar plugin
      final result = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result == true) {
        _initialized = true;
        _log.info('NotificationService inicializado com sucesso');
        await _createNotificationChannels();
      } else {
        _log.warning('Falha ao inicializar NotificationService');
      }
    } catch (e, stack) {
      _log.severe('Erro ao inicializar NotificationService', e, stack);
    }
  }

  /// Cria os canais de notificação (Android)
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    // Canal para alertas críticos
    const criticalChannel = AndroidNotificationChannel(
      'critical_alerts',
      'Alertas Críticos',
      description:
          'Notificações de eventos críticos (vazamento de gás, overflow)',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Canal para avisos
    const warningChannel = AndroidNotificationChannel(
      'warnings',
      'Avisos',
      description:
          'Notificações de avisos (níveis anormais, dispositivos offline)',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Canal para informações
    const infoChannel = AndroidNotificationChannel(
      'info',
      'Informações',
      description: 'Notificações informativas',
      importance: Importance.defaultImportance,
      playSound: false,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(criticalChannel);
      await androidPlugin.createNotificationChannel(warningChannel);
      await androidPlugin.createNotificationChannel(infoChannel);
      _log.info('Canais de notificação criados');
    }
  }

  /// Solicita permissão para notificações (iOS e Android 13+)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Mostra um alerta crítico (vazamento de gás, overflow, etc.)
  Future<void> showCriticalAlert({
    required String title,
    required String body,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService não inicializado');
      return;
    }

    final id = _generateNotificationId(deviceId);

    const androidDetails = AndroidNotificationDetails(
      'critical_alerts',
      'Alertas Críticos',
      channelDescription: 'Notificações de eventos críticos',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Alerta Crítico',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: Color.fromARGB(255, 220, 38, 38), // Red
      ledColor: Color.fromARGB(255, 220, 38, 38),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: _encodePayload(deviceId, payload),
    );

    _log.info('Alerta crítico mostrado: $title');
  }

  /// Mostra um aviso (nível anormal, dispositivo offline, etc.)
  Future<void> showWarning({
    required String title,
    required String body,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService não inicializado');
      return;
    }

    final id = _generateNotificationId(deviceId);

    const androidDetails = AndroidNotificationDetails(
      'warnings',
      'Avisos',
      channelDescription: 'Notificações de avisos',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Aviso',
      playSound: true,
      enableVibration: true,
      color: Color.fromARGB(255, 234, 179, 8), // Yellow
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: _encodePayload(deviceId, payload),
    );

    _log.info('Aviso mostrado: $title');
  }

  /// Mostra uma notificação informativa
  Future<void> showInfo({
    required String title,
    required String body,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService não inicializado');
      return;
    }

    final id = _generateNotificationId(deviceId);

    const androidDetails = AndroidNotificationDetails(
      'info',
      'Informações',
      channelDescription: 'Notificações informativas',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Informação',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: _encodePayload(deviceId, payload),
    );

    _log.info('Info mostrada: $title');
  }

  /// Cancela uma notificação específica
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancela todas as notificações
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Gera um ID único para a notificação baseado no deviceId
  int _generateNotificationId(String? deviceId) {
    if (deviceId == null) {
      return DateTime.now().millisecondsSinceEpoch.remainder(100000);
    }
    return deviceId.hashCode.abs().remainder(100000);
  }

  /// Codifica o payload para string
  String? _encodePayload(String? deviceId, Map<String, dynamic>? payload) {
    if (deviceId == null && payload == null) return null;

    final data = <String, dynamic>{};
    if (deviceId != null) data['deviceId'] = deviceId;
    if (payload != null) data.addAll(payload);

    return data.toString(); // Simplificado, pode usar jsonEncode se necessário
  }

  /// Callback quando notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    _log.info('Notificação tocada: ${response.payload}');

    // TODO: Implementar navegação baseada no payload
    // Exemplo: navegar para tela de detalhes do dispositivo
    // Pode usar um StreamController ou callback para comunicar com a UI
  }

  /// Verifica se notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS não tem API pública para verificar
  }
}




