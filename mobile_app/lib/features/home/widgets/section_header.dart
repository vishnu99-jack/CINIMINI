import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: AppTextStyles.sectionTitle,
            ),
          ),

          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text("See All"),
            ),
        ],
      ),
    );
  }
}