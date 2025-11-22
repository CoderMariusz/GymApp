import 'package:flutter/material.dart';

/// OAuth button widget
class OAuthButton extends StatelessWidget {
  final String provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const OAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = provider.toLowerCase() == 'google';
    final isApple = provider.toLowerCase() == 'apple';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isApple ? Colors.black : Colors.white,
          foregroundColor: isApple ? Colors.white : Colors.black87,
          elevation: 1,
          side: BorderSide(
            color: isApple ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGoogle)
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 24);
                      },
                    ),
                  if (isApple) const Icon(Icons.apple, size: 24),
                  const SizedBox(width: 12),
                  Text('Continue with $provider'),
                ],
              ),
      ),
    );
  }
}
