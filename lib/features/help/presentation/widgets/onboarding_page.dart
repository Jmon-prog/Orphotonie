// ============================================================
// Fichier : lib/features/help/presentation/widgets/onboarding_page.dart
// Description : Page individuelle de l'onboarding avec icône,
//               titre et description. Responsive. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../../data/help_content.dart';

/// Une page de l'onboarding (utilisée dans un PageView).
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.data,
  });

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final iconSize = isWide ? 120.0 : 80.0;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 64 : 32,
            vertical: 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize + 40,
                height: iconSize + 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
                child: Icon(
                  data.icon,
                  size: iconSize,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text(
                  data.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
