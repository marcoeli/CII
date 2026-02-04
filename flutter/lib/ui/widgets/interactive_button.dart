import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleOnTap;
  final Duration animationDuration;

  const InteractiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleOnTap = 0.95,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedScaleButton(
      onPressed: onPressed,
      scaleOnTap: scaleOnTap,
      duration: animationDuration,
      child: child,
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleOnTap;
  final Duration duration;

  const _AnimatedScaleButton({
    required this.child,
    this.onPressed,
    required this.scaleOnTap,
    required this.duration,
  });

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}




