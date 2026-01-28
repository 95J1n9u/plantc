import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeType {
  success,
  warning,
  error,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
  });

  Color get backgroundColor {
    switch (type) {
      case BadgeType.success:
        return AppTheme.success.withOpacity(0.15);
      case BadgeType.warning:
        return AppTheme.warning.withOpacity(0.15);
      case BadgeType.error:
        return AppTheme.error.withOpacity(0.15);
      case BadgeType.info:
        return AppTheme.info.withOpacity(0.15);
      case BadgeType.neutral:
        return AppTheme.secondary.withOpacity(0.15);
    }
  }

  Color get textColor {
    switch (type) {
      case BadgeType.success:
        return AppTheme.success;
      case BadgeType.warning:
        return AppTheme.warning;
      case BadgeType.error:
        return AppTheme.error;
      case BadgeType.info:
        return AppTheme.info;
      case BadgeType.neutral:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
