import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Evita processar a mesma mensagem MQTT múltiplas vezes
class MessageDeduplicator {
  final _cache = <String, String>{}; // topic -> payload_hash
  final int _maxSize;

  MessageDeduplicator({int maxSize = 100}) : _maxSize = maxSize;

  /// Retorna true se a mensagem for duplicada (mesmo tópico e payload)
  bool isDuplicate(String topic, String payload) {
    // Calcula MD5 do payload
    final hash = md5.convert(utf8.encode(payload)).toString();

    // Verifica se já processamos este hash para este tópico
    if (_cache[topic] == hash) {
      return true;
    }

    // Armazena novo hash
    _cache[topic] = hash;

    // Limpeza FIFO simples se exceder tamanho
    if (_cache.length > _maxSize) {
      _cache.remove(_cache.keys.first);
    }

    return false;
  }

  void clear() {
    _cache.clear();
  }
}
