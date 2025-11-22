// ============================================================================
// LifeOS - Reusable Submit Button Widget
// ============================================================================
// Used across all forms: Check-Ins, Reflections, Workouts, Goals, etc.
// ============================================================================

import 'package:flutter/material.dart';

/// A reusable submit button with consistent styling and loading states
///
/// Features:
/// - Loading state with spinner
/// - Success/error animations
/// - Consistent styling
/// - Haptic feedback
/// - Disabled state handling
class SubmitButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Callback when pressed
  final Future<void> Function()? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Optional success message to show briefly
  final String? successMessage;

  /// Icon to show (optional)
  final IconData? icon;

  /// Button style (defaults to FilledButton)
  final ButtonStyle? style;

  /// Whether button should expand to full width
  final bool expanded;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.successMessage,
    this.icon,
    this.style,
    this.expanded = true,
  });

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _showSuccess = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePressed() async {
    if (_isProcessing || widget.isLoading || widget.onPressed == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      _controller.forward();
      await widget.onPressed!();

      // Show success animation if success message provided
      if (widget.successMessage != null && mounted) {
        setState(() {
          _showSuccess = true;
        });

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _showSuccess = false;
          });
        }
      }
    } catch (e) {
      // Error handling is done by parent
      rethrow;
    } finally {
      _controller.reverse();
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading || _isProcessing;

    Widget buttonChild;

    if (_showSuccess) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 20),
          const SizedBox(width: 8),
          Text(widget.successMessage!),
        ],
      );
    } else if (widget.isLoading || _isProcessing) {
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(widget.text),
        ],
      );
    }

    final button = ScaleTransition(
      scale: _scaleAnimation,
      child: FilledButton(
        onPressed: isDisabled ? null : _handlePressed,
        style: widget.style,
        child: buttonChild,
      ),
    );

    if (widget.expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// A secondary/outline submit button variant
class SubmitButtonOutlined extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  const SubmitButtonOutlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      expanded: expanded,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

/// A text button variant for cancel/secondary actions
class SubmitButtonText extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const SubmitButtonText({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
