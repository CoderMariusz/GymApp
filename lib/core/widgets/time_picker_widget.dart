// ============================================================================
// LifeOS - Reusable Time Picker Widget
// ============================================================================
// Used in: Workout Logging, Quick Log, Morning Check-In, Evening Reflection
// ============================================================================

import 'package:flutter/material.dart';

/// A reusable time picker widget with consistent styling
///
/// Features:
/// - Single tap to open time picker
/// - Displays selected time
/// - Validation support
/// - Customizable label and icon
class TimePickerWidget extends StatelessWidget {
  /// Selected time value
  final TimeOfDay? time;

  /// Callback when time is selected
  final ValueChanged<TimeOfDay> onTimeSelected;

  /// Label text
  final String label;

  /// Optional helper text
  final String? helperText;

  /// Icon to display
  final IconData icon;

  /// Whether field is required
  final bool required;

  /// Custom validator
  final String? Function(TimeOfDay?)? validator;

  const TimePickerWidget({
    super.key,
    required this.time,
    required this.onTimeSelected,
    this.label = 'Time',
    this.helperText,
    this.icon = Icons.access_time,
    this.required = false,
    this.validator,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  String? _validate() {
    if (required && time == null) {
      return 'Please select a time';
    }
    if (validator != null) {
      return validator!(time);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = _validate();
    final hasError = error != null;

    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          helperText: helperText,
          errorText: hasError ? error : null,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
        ),
        child: Text(
          time?.format(context) ?? 'Select time',
          style: TextStyle(
            color: time == null
                ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

/// A duration picker widget for rest timers, workout duration, etc.
///
/// Features:
/// - Minutes and seconds selection
/// - Presets for common durations
/// - Validation support
class DurationPickerWidget extends StatefulWidget {
  /// Selected duration
  final Duration? duration;

  /// Callback when duration is selected
  final ValueChanged<Duration> onDurationSelected;

  /// Label text
  final String label;

  /// Preset durations (in seconds)
  final List<int>? presets;

  /// Whether field is required
  final bool required;

  const DurationPickerWidget({
    super.key,
    required this.duration,
    required this.onDurationSelected,
    this.label = 'Duration',
    this.presets = const [30, 60, 90, 120, 180],
    this.required = false,
  });

  @override
  State<DurationPickerWidget> createState() => _DurationPickerWidgetState();
}

class _DurationPickerWidgetState extends State<DurationPickerWidget> {
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.duration ?? Duration.zero;
  }

  Future<void> _showDurationPicker() async {
    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => _DurationPickerDialog(
        initialDuration: _selectedDuration,
        presets: widget.presets,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDuration = result;
      });
      widget.onDurationSelected(result);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return 'Select duration';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    if (minutes > 0 && seconds > 0) {
      return '${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _showDurationPicker,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.required ? '${widget.label} *' : widget.label,
          prefixIcon: const Icon(Icons.timer),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _formatDuration(_selectedDuration),
          style: TextStyle(
            color: _selectedDuration == Duration.zero
                ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;
  final List<int>? presets;

  const _DurationPickerDialog({
    required this.initialDuration,
    this.presets,
  });

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialDuration.inMinutes;
    _seconds = widget.initialDuration.inSeconds.remainder(60);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Select Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Presets
          if (widget.presets != null && widget.presets!.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: widget.presets!.map((seconds) {
                final duration = Duration(seconds: seconds);
                final isSelected = (_minutes * 60 + _seconds) == seconds;

                return ChoiceChip(
                  label: Text(
                    duration.inMinutes > 0
                        ? '${duration.inMinutes}m'
                        : '${duration.inSeconds}s',
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _minutes = duration.inMinutes;
                        _seconds = duration.inSeconds.remainder(60);
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const Divider(height: 32),
          ],

          // Custom duration picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minutes
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        if (_minutes < 99) _minutes++;
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _minutes.toString().padLeft(2, '0'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      setState(() {
                        if (_minutes > 0) _minutes--;
                      });
                    },
                  ),
                  Text('Minutes', style: theme.textTheme.bodySmall),
                ],
              ),

              const SizedBox(width: 16),
              Text(':', style: theme.textTheme.headlineSmall),
              const SizedBox(width: 16),

              // Seconds
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _seconds = (_seconds + 15) % 60;
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _seconds.toString().padLeft(2, '0'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      setState(() {
                        _seconds = (_seconds - 15) % 60;
                        if (_seconds < 0) _seconds += 60;
                      });
                    },
                  ),
                  Text('Seconds', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final duration = Duration(
              minutes: _minutes,
              seconds: _seconds,
            );
            Navigator.of(context).pop(duration);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
