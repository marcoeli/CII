import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/core/domain/entities/system_status.dart';
import 'package:cii/core/providers/system_status_provider.dart';
import 'package:cii/core/providers/alert_provider.dart';
import 'package:cii/core/providers/navigation_provider.dart';
import 'package:cii/core/theme/app_themes.dart';
import 'package:cii/modules/home/presentation/providers/home_providers.dart';

/// Widget de cabeçalho reativo que muda de aparência baseado no status do sistema
/// Implementa uma animação pulsante para erros críticos.
class ReactiveHeader extends ConsumerStatefulWidget {
  const ReactiveHeader({super.key});

  @override
  ConsumerState<ReactiveHeader> createState() => _ReactiveHeaderState();
}

class _ReactiveHeaderState extends ConsumerState<ReactiveHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final systemStatus = ref.watch(systemStatusProvider);
    final statusLevel = systemStatus.level;
    final themeExt = AppThemeExtension.of(context);
    final theme = Theme.of(context);
    final alertState = ref.watch(alertProvider);
    final isSilenced = alertState.isSilenced;
    final isSilencedMessageVisible =
        statusLevel == SystemStatusLevel.critical && isSilenced;

    // Gerenciar pulsação
    debugPrint(
      'ReactiveHeader: statusLevel=$statusLevel, isSilenced=$isSilenced',
    );

    if (statusLevel == SystemStatusLevel.critical && !isSilenced) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Calcula altura baseada no status
    final screenHeight = MediaQuery.of(context).size.height;
    final heightPercent = _getHeightPercent(statusLevel);

    // Garantir altura mínima absoluta
    final minHeight = _getMinHeight(statusLevel);
    final headerHeight = (screenHeight * heightPercent).clamp(minHeight, 400.0);

    // Determina cor de fundo baseada no status
    final backgroundColor = _getBackgroundColor(statusLevel, theme, themeExt);

    // Determina cor do texto
    final textColor = _getTextColor(statusLevel, theme);

    return ScaleTransition(
      scale: _pulseAnimation,
      child: MouseRegion(
        cursor: statusLevel == SystemStatusLevel.critical
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () {
            if (statusLevel == SystemStatusLevel.critical) {
              ref.read(alertProvider.notifier).toggleSilence();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: headerHeight,
            decoration: BoxDecoration(
              gradient: statusLevel == SystemStatusLevel.ok
                  ? themeExt.gradientPrimary
                  : null,
              color: statusLevel == SystemStatusLevel.ok
                  ? null
                  : backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: headerHeight < 140 ? 8 : 16,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Lógica de "Voltar": Navigator History OU Tab != Home
                          // Se Navigator.canPop => botão voltar (padrão)
                          // Se Tab != Home => botão voltar (para home)
                          Builder(
                            builder: (context) {
                              final canPop = Navigator.of(context).canPop();
                              final currentTab = ref.watch(
                                navigationTabProvider,
                              );
                              final isNotHome =
                                  currentTab != NavigationTab.home;

                              if (!canPop && !isNotHome) {
                                return const SizedBox.shrink();
                              }

                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: textColor,
                                    ),
                                    onPressed: () {
                                      if (canPop) {
                                        Navigator.of(context).pop();
                                      } else {
                                        ref
                                            .read(
                                              navigationTabProvider.notifier,
                                            )
                                            .setTab(NavigationTab.home);
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    style: IconButton.styleFrom(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              );
                            },
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Casa Inteligente',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      systemStatus.statusMessage ??
                                          (systemStatus.isOnline
                                              ? 'Online'
                                              : 'Offline'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    if (alertState.isSilenced &&
                                        statusLevel ==
                                            SystemStatusLevel.critical)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.volume_off,
                                          size: 16,
                                          color: textColor.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildStatusIcon(statusLevel, textColor),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(Icons.settings, color: textColor),
                                onPressed: () {
                                  Modular.to.pushNamed('/settings/');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (statusLevel != SystemStatusLevel.ok)
                        _buildInfoRow(systemStatus, textColor, ref),

                      if (isSilencedMessageVisible)
                        Text(
                          "ALARME SILENCIADO - TOQUE PARA REATIVAR",
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeightPercent(SystemStatusLevel status) {
    switch (status) {
      case SystemStatusLevel.ok:
        return 0.15;
      case SystemStatusLevel.warning:
      case SystemStatusLevel.offline:
        return 0.20;
      case SystemStatusLevel.critical:
        return 0.30;
    }
  }

  double _getMinHeight(SystemStatusLevel status) {
    switch (status) {
      case SystemStatusLevel.ok:
        return 120.0;
      case SystemStatusLevel.warning:
      case SystemStatusLevel.offline:
        return 160.0;
      case SystemStatusLevel.critical:
        return 200.0;
    }
  }

  Color _getBackgroundColor(
    SystemStatusLevel status,
    ThemeData theme,
    AppThemeExtension themeExt,
  ) {
    switch (status) {
      case SystemStatusLevel.ok:
        return theme.colorScheme.primary;
      case SystemStatusLevel.warning:
        return themeExt.statusWarning;
      case SystemStatusLevel.critical:
        return themeExt.statusError;
      case SystemStatusLevel.offline:
        return const Color(0xFF37474F);
    }
  }

  Color _getTextColor(SystemStatusLevel status, ThemeData theme) {
    if (status == SystemStatusLevel.warning) {
      return Colors.black87;
    }
    return Colors.white;
  }

  Widget _buildStatusIcon(SystemStatusLevel status, Color color) {
    IconData icon;
    switch (status) {
      case SystemStatusLevel.ok:
        icon = Icons.check_circle;
        break;
      case SystemStatusLevel.warning:
        icon = Icons.warning_amber_rounded;
        break;
      case SystemStatusLevel.critical:
        icon = Icons.error;
        break;
      case SystemStatusLevel.offline:
        icon = Icons.cloud_off;
        break;
    }
    return Icon(icon, size: 32, color: color);
  }

  Widget _buildInfoRow(SystemStatus status, Color textColor, WidgetRef ref) {
    final statusState = ref.watch(systemStatusNotifierProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoChip(
            icon: Icons.flash_on,
            label: 'Dispositivos',
            value: '${statusState.devicesOnline}/${statusState.devicesTotal}',
            textColor: textColor,
          ),
          if (statusState.criticalAlerts > 0)
            _buildInfoChip(
              icon: Icons.notifications_active,
              label: 'Críticos',
              value: statusState.criticalAlerts.toString(),
              textColor: Colors.red.shade100,
              backgroundColor: Colors.red.shade900.withValues(alpha: 0.5),
            ),
          if (statusState.warningAlerts > 0)
            _buildInfoChip(
              icon: Icons.notification_important,
              label: 'Alertas',
              value: statusState.warningAlerts.toString(),
              textColor: Colors.orange.shade100,
              backgroundColor: Colors.orange.shade900.withValues(alpha: 0.5),
            ),
          if (statusState.criticalAlerts == 0 && statusState.warningAlerts == 0)
            _buildInfoChip(
              icon: Icons.home,
              label: 'Casa Ativa',
              value: status.activeHomeLabel,
              textColor: textColor,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
