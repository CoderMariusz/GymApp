import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/features/settings/presentation/providers/settings_providers.dart';

/// Button to request data export
class ExportButton extends ConsumerStatefulWidget {
  const ExportButton({super.key});

  @override
  ConsumerState<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<ExportButton> {
  bool _isLoading = false;
  String? _requestId;
  DateTime? _lastRequestTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _canRequestExport() ? _handleExport : null,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_isLoading ? 'Requesting...' : 'Request Data Export'),
        ),
        if (_lastRequestTime != null) ...[
          const SizedBox(height: 8),
          Text(
            _getRateLimitMessage(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        if (_requestId != null) ...[
          const SizedBox(height: 16),
          _buildExportStatus(),
        ],
      ],
    );
  }

  bool _canRequestExport() {
    if (_isLoading) return false;
    if (_lastRequestTime == null) return true;

    final hoursSinceLastRequest =
        DateTime.now().difference(_lastRequestTime!).inHours;
    return hoursSinceLastRequest >= 1;
  }

  String _getRateLimitMessage() {
    final minutesLeft = 60 -
        DateTime.now().difference(_lastRequestTime!).inMinutes;

    if (minutesLeft > 0) {
      return 'You can request another export in $minutesLeft minutes (rate limit: 1 per hour)';
    }
    return 'You can request another export now';
  }

  Future<void> _handleExport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = ref.read(exportDataUseCaseProvider);
      final requestId = await useCase.call();

      setState(() {
        _requestId = requestId;
        _lastRequestTime = DateTime.now();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Export requested! You will receive an email when ready.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildExportStatus() {
    return FutureBuilder<String?>(
      future: ref.read(exportDataUseCaseProvider).checkStatus(_requestId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Checking status...'),
            ],
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Export Ready!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your data export is ready. Check your email for the download link (expires in 7 days).',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Export is being processed. You will receive an email when ready.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
