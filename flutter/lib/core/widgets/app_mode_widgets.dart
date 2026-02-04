import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/domain/enums/app_mode.dart';
import 'package:cii/core/providers/app_mode_provider.dart';

/// Widget que mostra/esconde conteúdo baseado no modo
class ModeGatedWidget extends ConsumerWidget {
  final Widget child;
  final AppMode minMode;

  const ModeGatedWidget({
    super.key,
    required this.child,
    this.minMode = AppMode.advanced,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(appModeProvider);

    // Ordem: simple < advanced < dev
    final modeOrder = {AppMode.simple: 0, AppMode.advanced: 1, AppMode.dev: 2};

    final shouldShow =
        (modeOrder[currentMode] ?? 0) >= (modeOrder[minMode] ?? 0);

    return shouldShow ? child : const SizedBox.shrink();
  }
}

/// Indicador visual do modo atual
class AppModeIndicator extends ConsumerWidget {
  final bool compact;

  const AppModeIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final theme = Theme.of(context);

    if (compact) {
      return Chip(
        avatar: Text(mode.icon),
        label: Text(mode.displayName),
        backgroundColor: _getModeColor(mode).withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getModeColor(mode).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getModeColor(mode).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mode.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            mode.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: _getModeColor(mode),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(AppMode mode) {
    switch (mode) {
      case AppMode.simple:
        return Colors.green;
      case AppMode.advanced:
        return Colors.blue;
      case AppMode.dev:
        return Colors.orange;
    }
  }
}

/// Seletor de modo
class AppModeSelector extends ConsumerWidget {
  const AppModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(appModeProvider);
    final modeNotifier = ref.read(appModeProvider.notifier);

    return SegmentedButton<AppMode>(
      segments: AppMode.values.map((mode) {
        return ButtonSegment<AppMode>(
          value: mode,
          label: Text(mode.displayName),
          icon: Text(mode.icon),
        );
      }).toList(),
      selected: {currentMode},
      onSelectionChanged: (Set<AppMode> newSelection) {
        modeNotifier.setMode(newSelection.first);
      },
    );
  }
}




