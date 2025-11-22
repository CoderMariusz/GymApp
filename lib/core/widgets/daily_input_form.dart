// ============================================================================
// LifeOS - Reusable Daily Input Form Widget
// ============================================================================
// Used in: Morning Check-In, Evening Reflection, Workout Logging, Quick Log
// Token Savings: ~60% (reused 4x times)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Configuration for a single form field in the daily input form
class FormFieldConfig {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;

  const FormFieldConfig({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
  });
}

/// Reusable form widget for daily inputs across Life Coach and Fitness modules
///
/// Features:
/// - Multiple text fields with validation
/// - Time picker integration
/// - Mood/energy slider
/// - Tags/categories selection
/// - Submit button with loading state
/// - Form key for external validation
class DailyInputForm extends StatefulWidget {
  /// Form fields configuration
  final List<FormFieldConfig> fields;

  /// Whether to show time picker
  final bool showTimePicker;

  /// Initial time value (defaults to now)
  final TimeOfDay? initialTime;

  /// Whether to show mood/energy slider
  final bool showMoodSlider;

  /// Mood slider label (e.g., "Mood", "Energy", "Motivation")
  final String? moodLabel;

  /// Initial mood value (1-10)
  final int? initialMood;

  /// Whether to show tags/categories
  final bool showTags;

  /// Available tags
  final List<String>? availableTags;

  /// Initially selected tags
  final List<String>? initialTags;

  /// Submit button text
  final String submitText;

  /// Callback when form is submitted with valid data
  /// Returns Map with field labels as keys and values
  /// Also includes 'time', 'mood', 'tags' if enabled
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  /// Optional cancel button callback
  final VoidCallback? onCancel;

  const DailyInputForm({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.showTimePicker = false,
    this.initialTime,
    this.showMoodSlider = false,
    this.moodLabel,
    this.initialMood,
    this.showTags = false,
    this.availableTags,
    this.initialTags,
    this.submitText = 'Submit',
    this.onCancel,
  });

  @override
  State<DailyInputForm> createState() => _DailyInputFormState();
}

class _DailyInputFormState extends State<DailyInputForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  late TimeOfDay _selectedTime;
  late int _moodValue;
  late Set<String> _selectedTags;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers for each field
    for (final field in widget.fields) {
      _controllers[field.label] = TextEditingController();
    }

    // Initialize time
    _selectedTime = widget.initialTime ?? TimeOfDay.now();

    // Initialize mood
    _moodValue = widget.initialMood ?? 5;

    // Initialize tags
    _selectedTags = widget.initialTags?.toSet() ?? {};
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final data = <String, dynamic>{};

      // Collect field values
      for (final field in widget.fields) {
        data[field.label] = _controllers[field.label]!.text;
      }

      // Add time if enabled
      if (widget.showTimePicker) {
        data['time'] = _selectedTime;
      }

      // Add mood if enabled
      if (widget.showMoodSlider) {
        data['mood'] = _moodValue;
      }

      // Add tags if enabled
      if (widget.showTags) {
        data['tags'] = _selectedTags.toList();
      }

      await widget.onSubmit(data);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time Picker
            if (widget.showTimePicker) ...[
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectTime(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Text Fields
            ...widget.fields.map((field) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _controllers[field.label],
                decoration: InputDecoration(
                  labelText: field.label,
                  hintText: field.hint,
                  suffixIcon: field.suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: field.keyboardType,
                maxLines: field.maxLines,
                maxLength: field.maxLength,
                validator: field.validator,
                enabled: field.enabled,
              ),
            )),

            // Mood/Energy Slider
            if (widget.showMoodSlider) ...[
              const SizedBox(height: 8),
              Text(
                widget.moodLabel ?? 'Mood',
                style: theme.textTheme.titleSmall,
              ),
              Row(
                children: [
                  const Text('😔'),
                  Expanded(
                    child: Slider(
                      value: _moodValue.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _moodValue.toString(),
                      onChanged: (value) {
                        setState(() {
                          _moodValue = value.round();
                        });
                      },
                    ),
                  ),
                  const Text('😄'),
                  const SizedBox(width: 8),
                  Text(
                    _moodValue.toString(),
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Tags/Categories
            if (widget.showTags && widget.availableTags != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tags',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableTags!.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Submit Button
            FilledButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitText),
            ),

            // Cancel Button
            if (widget.onCancel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isSubmitting ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
