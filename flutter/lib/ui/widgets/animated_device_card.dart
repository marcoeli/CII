import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cii/core/widgets/staleness_indicator.dart';

class AnimatedDeviceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final Widget? trailing;
  final List<Widget>? children;
  final bool isOnline;
  final VoidCallback? onTap;
  final DateTime? lastUpdate; // NEW: for staleness tracking

  const AnimatedDeviceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.children,
    this.isOnline = true,
    this.onTap,
    this.lastUpdate, // NEW
  });

  @override
  State<AnimatedDeviceCard> createState() => _AnimatedDeviceCardState();
}

class _AnimatedDeviceCardState extends State<AnimatedDeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface.withValues(alpha: 0.8),
                colorScheme.surface.withValues(alpha: 0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  if (widget.onTap != null && !expanded) {
                    widget.onTap!();
                  }
                },
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
                collapsedShape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (widget.isOnline ? colorScheme.primary : Colors.grey)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: widget.isOnline
                          ? colorScheme.primary
                          : Colors.grey,
                      size: 24,
                    ),
                    child: widget.icon,
                  ),
                ),
                title: Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // NEW: Staleness indicator
                    if (widget.lastUpdate != null) ...[
                      const SizedBox(width: 8),
                      StalenessIndicator(
                        lastUpdate: widget.lastUpdate,
                        showIcon: false,
                        shortFormat: true,
                      ),
                    ],
                  ],
                ),
                trailing: widget.trailing,
                children: widget.children ?? [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




