import 'package:flutter/material.dart';
import 'package:cii/core/utils/datetime_utils.dart';

class StalenessIndicator extends StatelessWidget {
  final DateTime? lastUpdate;
  final bool showIcon;
  final bool shortFormat;

  const StalenessIndicator({
    super.key,
    required this.lastUpdate,
    this.showIcon = true,
    this.shortFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdate == null || lastUpdate!.year < 2020) {
      return const SizedBox.shrink();
    }

    final minutes = DateTimeUtils.minutesSince(lastUpdate);

    Color color;
    FontWeight fontWeight = FontWeight.normal;

    if (minutes < 5) {
      // Ok: Cinza se estiver curto e não estiver obsoleto, ou verde discreto
      if (shortFormat) return const SizedBox.shrink();
      color = Colors.grey;
    } else if (minutes < 30) {
      // Warning: Amarelo/Laranja
      color = Colors.orange;
    } else {
      // Critical: Vermelho
      color = Colors.red;
      fontWeight = FontWeight.bold;
    }

    final timeShort = DateTimeUtils.timeSince(lastUpdate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.access_time, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            shortFormat ? timeShort : 'Atualizado há $timeShort',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
