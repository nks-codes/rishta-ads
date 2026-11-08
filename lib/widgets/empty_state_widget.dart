import 'package:flutter/material.dart';

import '../app/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.message, this.onReset});

  final String message;

  /// When provided, a "Reset Filters" button is shown.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.text),
          ),
          if (onReset != null) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Reset Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
