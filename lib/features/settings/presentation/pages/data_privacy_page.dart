import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/features/settings/presentation/providers/settings_providers.dart';
import 'package:lifeos/features/settings/presentation/widgets/export_button.dart';
import 'package:lifeos/features/settings/presentation/widgets/delete_account_section.dart';

/// Data Privacy page for GDPR compliance
class DataPrivacyPage extends ConsumerWidget {
  const DataPrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPendingDeletion = ref.watch(hasPendingDeletionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Text(
            'Manage Your Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy matters. Export or delete your data at any time.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Data Export Section
          _buildSection(
            title: 'Export Your Data',
            description:
                'Download all your data in JSON and CSV formats. Includes workouts, mood logs, goals, meditations, and journal entries.',
            child: const ExportButton(),
          ),

          const Divider(height: 48),

          // Account Deletion Section
          hasPendingDeletion.when(
            data: (hasPending) {
              if (hasPending) {
                return _buildPendingDeletionWarning(context, ref);
              }
              return _buildSection(
                title: 'Delete Your Account',
                description:
                    'Permanently delete your account and all associated data. This action cannot be undone.',
                child: const DeleteAccountSection(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildSection(
              title: 'Delete Your Account',
              description:
                  'Permanently delete your account and all associated data. This action cannot be undone.',
              child: const DeleteAccountSection(),
            ),
          ),

          const SizedBox(height: 32),

          // GDPR Information
          _buildGdprInfo(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildPendingDeletionWarning(BuildContext context, WidgetRef ref) {
    final scheduledDate = ref.watch(deletionScheduledDateProvider);

    return scheduledDate.when(
      data: (date) {
        final daysLeft = date?.difference(DateTime.now()).inDays ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Account Deletion Scheduled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your account is scheduled for deletion in $daysLeft days.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Deletion'),
                      content: const Text(
                        'Are you sure you want to cancel account deletion?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes, Cancel Deletion'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    try {
                      final useCase = ref.read(cancelDeletionUseCaseProvider);
                      await useCase();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account deletion cancelled'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }

                      ref.invalidate(hasPendingDeletionProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Cancel Deletion'),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildGdprInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'Your Rights (GDPR)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Right to data portability (Article 20)\n'
            '• Right to erasure (Article 17)\n'
            '• Export links expire in 7 days\n'
            '• Account deletion has a 7-day grace period\n'
            '• Deleted data purged from backups after 30 days',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
