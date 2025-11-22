import 'package:flutter/material.dart';

/// Rest timer widget for tracking rest between sets
class RestTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;
  final VoidCallback? onStop;

  const RestTimerWidget({
    super.key,
    required this.duration,
    required this.onComplete,
    this.onStop,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remaining = Duration(
          seconds: (widget.duration.inSeconds * (1 - _controller.value)).round(),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 4,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rest Timer',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(remaining),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.isAnimating)
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        _controller.stop();
                      },
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        _controller.forward();
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      _controller.stop();
                      widget.onStop?.call() ?? widget.onComplete();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
