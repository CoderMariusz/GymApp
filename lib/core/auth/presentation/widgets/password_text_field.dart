import 'package:flutter/material.dart';

/// Password text field widget with show/hide toggle
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final String labelText;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool showRequirements;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.errorText,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.onChanged,
    this.showRequirements = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            errorText: widget.errorText,
          ),
        ),
        if (widget.showRequirements) ...[
          const SizedBox(height: 8),
          Text(
            'Password requirements:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          _PasswordRequirement(
            text: 'At least 8 characters',
            isMet: widget.controller.text.length >= 8,
          ),
          _PasswordRequirement(
            text: 'One uppercase letter',
            isMet: widget.controller.text.contains(RegExp(r'[A-Z]')),
          ),
          _PasswordRequirement(
            text: 'One number',
            isMet: widget.controller.text.contains(RegExp(r'[0-9]')),
          ),
          _PasswordRequirement(
            text: 'One special character',
            isMet: widget.controller.text
                .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
          ),
        ],
      ],
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isMet ? Colors.green : Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
