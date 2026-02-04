import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';

/// Widget exemplo de uso do SystemStatusViewModel
///
/// Mostra header com status do sistema:
/// - Devices online/total
/// - Alertas ativos
/// - Última atualização
class SystemStatusHeader extends ConsumerWidget {
  const SystemStatusHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(systemStatusNotifierProvider);

    // Determine status level for styling
    final isCritical = state.criticalAlerts > 0;
    final isWarning = state.warningAlerts > 0;

    // Theme colors
    Color backgroundColor = Theme.of(context).primaryColor;
    if (isCritical) {
      backgroundColor = Colors.red.shade700;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade700;
    }

    final height = (isCritical || isWarning) ? 200.0 : 120.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),

            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        48,
        24,
        16,
      ), // Top padding for status bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title + Status Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCritical ? 'Atenção Necessária' : 'Sistema Online',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (state.lastUpdate != null)
                    Text(
                      'Atualizado ${_formatTime(state.lastUpdate!)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),

                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),

                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCritical
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Row 2: Metrics (Online/Total + Alerts)
          Row(
            children: [
              _buildMetricChip(
                context,
                icon: Icons.wifi,
                label: '${state.devicesOnline}/${state.devicesTotal} Online',
                isCritical: false,
              ),
              const SizedBox(width: 12),
              if (state.criticalAlerts > 0)
                _buildMetricChip(
                  context,
                  icon: Icons.error_outline,
                  label: '${state.criticalAlerts} Críticos',
                  isCritical: true,
                ),
              if (state.warningAlerts > 0)
                _buildMetricChip(
                  context,
                  icon: Icons.notification_important,
                  label: '${state.warningAlerts} Alertas',
                  isCritical: false,
                  backgroundColor: Colors.orange.shade100,
                  textColor: Colors.orange.shade900,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isCritical,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isCritical ? Colors.white : Colors.white.withValues(alpha: 0.15)),

        borderRadius: BorderRadius.circular(20),
        border: (isCritical || backgroundColor != null)
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor ?? (isCritical ? Colors.red : Colors.white),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? (isCritical ? Colors.red : Colors.white),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }
}
