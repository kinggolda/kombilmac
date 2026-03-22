import 'package:flutter/material.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadii.lg);
    final color = backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;

    return Material(
      color: color,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(theme.brightness == Brightness.dark
                    ? 0.22
                    : 0.04),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

