import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import '../database/app_database.dart';

// Classe de suporte temporária até o drift gerar o código
// Na verdade, usaremos PendingCommandEntity diretamente do banco
// mas precisamos importar o arquivo de tabelas/banco.

class CommandManager {
  final AppDatabase _db;
  final _uuid = const Uuid();
  final _log = Logger('CommandManager');

  CommandManager(this._db);

  /// Cria um comando e o persiste IMEDIATAMENTE no banco como 'pending'.
  /// Retorna o correlation_id gerado.
  Future<String> createCommand({
    required String resourceId,
    required String action,
    Map<String, dynamic>? params,
    required String origin,
  }) async {
    final correlationId = _uuid.v4();
    final now = DateTime.now();

    _log.info('Creating command $action for $resourceId (ID: $correlationId)');

    try {
      await _db.pendingCommandsDao.insertCommand(
        PendingCommandEntity(
          correlationId: correlationId,
          resourceId: resourceId,
          action: action,
          paramsJson: params != null ? jsonEncode(params) : null,
          origin: origin,
          status: 'pending',
          createdAt: now,
        ),
      );
    } catch (e) {
      _log.severe('Failed to persist pending command: $e');
      // Mesmo se falhar o banco, retornamos o ID para tentar enviar?
      // Pela regra de UX pessimista com persistência crítica, talvez devêssemos falhar.
      // Mas para resiliência de app, talvez logar e continuar.
      // Vou relançar para que a UI saiba que falhou a preparação.
      rethrow;
    }

    return correlationId;
  }

  /// Marca um comando como expirado (timeout)
  Future<void> markExpired(String correlationId) async {
    _log.warning('Command timeout: $correlationId');
    await _db.pendingCommandsDao.updateStatus(
      correlationId,
      'timeout',
      completedAt: DateTime.now(),
    );
  }

  /// Verifica se um comando existe e ainda está pendente (útil para UI)
  Future<bool> isPending(String correlationId) async {
    final cmd = await _db.pendingCommandsDao.getCommand(correlationId);
    return cmd?.status == 'pending';
  }

  /// Marca comando como sucesso/falha baseado no feedback
  Future<void> complete(String correlationId, {bool success = true}) async {
    final status = success ? 'success' : 'failed';
    _log.info('Completing command $correlationId: $status');
    await _db.pendingCommandsDao.updateStatus(
      correlationId,
      status,
      completedAt: DateTime.now(),
    );
  }

  /// Aguarda a conclusão do comando observando o banco
  Future<bool> waitForCompletion(
    String correlationId, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final Completer<bool> completer = Completer();

    final subscription = _db.pendingCommandsDao
        .watchCommand(correlationId)
        .listen((cmd) {
          if (cmd == null) return; // Deleted?

          if (cmd.status == 'success') {
            if (!completer.isCompleted) completer.complete(true);
          } else if (cmd.status == 'failed' || cmd.status == 'timeout') {
            if (!completer.isCompleted) completer.complete(false);
          }
          // 'pending' -> continue waiting
        });

    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () {
          // Local timeout if DB doesn't update
          markExpired(correlationId); // Mark as timeout in DB
          return false;
        },
      );
    } finally {
      await subscription.cancel();
    }
  }
}
