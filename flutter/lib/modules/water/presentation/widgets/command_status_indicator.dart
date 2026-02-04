import 'package:flutter/material.dart';
import 'package:cii/core/widgets/staleness_indicator.dart';

/// RCO-2401: Widget para exibir o status de um comando (UX Pessimista)
/// e a obsolescência dos dados (Staleness).
class CommandStatusIndicator extends StatelessWidget {
  final bool isLoading;
  final bool isStale;
  final DateTime? lastUpdate;
  final String? loadingMessage;

  const CommandStatusIndicator({
    super.key,
    required this.isLoading,
    required this.isStale,
    this.lastUpdate,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          if (loadingMessage != null) ...[
            const SizedBox(width: 8),
            Text(
              loadingMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
          const SizedBox(width: 8),
        ],
        if (!isLoading)
          StalenessIndicator(lastUpdate: lastUpdate, showIcon: true),
      ],
    );
  }
}
