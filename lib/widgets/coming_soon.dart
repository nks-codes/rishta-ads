import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Temporary placeholder for tabs that are built in the next batch.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'This screen is built in the next step.',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
