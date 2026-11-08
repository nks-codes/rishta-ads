import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/constants.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.softPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                AppConstants.poweredBy,
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
