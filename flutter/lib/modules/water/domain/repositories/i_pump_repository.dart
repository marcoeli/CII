import '../entities/pump.dart';

abstract class IPumpRepository {
  /// Monitora o estado da bomba em tempo real
  /// Retorna null se a bomba não for encontrada
  Stream<Pump?> watchPump(String id);

  /// Envia comando de LIGAR/DESLIGAR
  Future<bool> sendCommand(String id, bool turnOn, {bool force = false});

  /// Define o modo de operação (AUTO/MANUAL)
  Future<bool> setMode(String id, String mode);
}
