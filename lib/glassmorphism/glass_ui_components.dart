import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

/// Premium Glass AppBar - Frosted glass app bar with blur
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final GlassCardPreset? preset;
  final PreferredSizeWidget? bottom;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.preset,
    this.bottom,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.subtle;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;

    final effectiveBackgroundColor = isDarkMode
        ? GlassDesignSystem.darkGlass
        : GlassDesignSystem.lightGlass;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: AppBar(
          title: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: GlassDesignSystem.fontSizeL,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: centerTitle,
          backgroundColor: effectiveBackgroundColor.withValues(
            alpha: effectiveOpacity + 0.3,
          ),
          elevation: elevation ?? 0,
          leading: leading,
          actions: actions,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          bottom: bottom,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDarkMode ? Colors.white24 : Colors.black12)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Glass Bottom Navigation - Frosted glass navigation bar
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<GlassNavItem> items;
  final GlassCardPreset? preset;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.preset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.standard;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;

    final effectiveBackgroundColor = isDarkMode
        ? GlassDesignSystem.darkGlass
        : GlassDesignSystem.lightGlass;

    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(
        horizontal: GlassDesignSystem.spaceM,
        vertical: GlassDesignSystem.spaceS,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withValues(
                alpha: effectiveOpacity + 0.3,
              ),
              borderRadius: BorderRadius.circular(GlassDesignSystem.radiusXL),
              border: Border.all(
                color: (isDarkMode ? Colors.white24 : Colors.black12)
                    .withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: GlassShadows.glassShadowMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? GlassDesignSystem.emerald
                                : (isDarkMode
                                      ? Colors.white54
                                      : Colors.black54),
                            size: GlassDesignSystem.iconM,
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? GlassDesignSystem.emerald
                                  : (isDarkMode
                                        ? Colors.white54
                                        : Colors.black54),
                              fontSize: GlassDesignSystem.fontSizeXS,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final String label;

  const GlassNavItem({required this.icon, required this.label});
}

/// Premium Glass Dialog - Frosted glass dialog
class GlassDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<Widget>? actions;
  final Widget? customContent;
  final GlassCardPreset? preset;

  const GlassDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.customContent,
    this.preset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.all(GlassDesignSystem.spaceXL),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(GlassDesignSystem.radiusXL),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: GlassDesignSystem.deepForestGreen,
                  ),
                ),
                SizedBox(height: GlassDesignSystem.spaceS),
                if (content != null)
                  Text(
                    content!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                if (customContent != null) customContent!,
                if (actions != null) ...[
                  SizedBox(height: GlassDesignSystem.spaceL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Glass Progress - Frosted glass progress indicator
class GlassProgress extends StatelessWidget {
  final double value;
  final String? label;
  final GlassCardPreset? preset;
  final Color? progressColor;

  const GlassProgress({
    super.key,
    required this.value,
    this.label,
    this.preset,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.standard;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;
    final effectiveProgressColor = progressColor ?? GlassDesignSystem.emerald;

    final effectiveBackgroundColor = isDarkMode
        ? GlassDesignSystem.darkGlass
        : GlassDesignSystem.lightGlass;

    return ClipRRect(
      borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          padding: EdgeInsets.all(GlassDesignSystem.spaceM),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor.withValues(
              alpha: effectiveOpacity + 0.1,
            ),
            borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
            border: Border.all(
              color: (isDarkMode ? Colors.white24 : Colors.black12).withValues(
                alpha: 0.3,
              ),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: GlassDesignSystem.spaceS),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(GlassDesignSystem.radiusXS),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor:
                      (isDarkMode ? Colors.white12 : Colors.black12).withValues(
                        alpha: 0.3,
                      ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveProgressColor,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium Glass Chip - Frosted glass selection chips
class GlassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final GlassCardPreset? preset;
  final Color? selectedColor;

  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.preset,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.subtle;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;
    final effectiveSelectedColor = selectedColor ?? GlassDesignSystem.emerald;

    final effectiveBackgroundColor = isDarkMode
        ? GlassDesignSystem.darkGlass
        : GlassDesignSystem.lightGlass;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: GlassDesignSystem.spaceL,
              vertical: GlassDesignSystem.spaceS,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? effectiveSelectedColor.withValues(
                      alpha: effectiveOpacity + 0.3,
                    )
                  : effectiveBackgroundColor.withValues(
                      alpha: effectiveOpacity + 0.1,
                    ),
              borderRadius: BorderRadius.circular(GlassDesignSystem.radiusFull),
              border: Border.all(
                color: selected
                    ? effectiveSelectedColor.withValues(alpha: 0.5)
                    : (isDarkMode ? Colors.white24 : Colors.black12).withValues(
                        alpha: 0.3,
                      ),
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDarkMode
                          ? Colors.white70
                          : Colors.black.withValues(alpha: 0.7)),
                fontSize: GlassDesignSystem.fontSizeS,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Glass Toast - Frosted glass notification
class GlassToast {
  static void show({
    required BuildContext context,
    required String message,
    GlassToastType type = GlassToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: _GlassToastContent(message: message, type: type, onTap: onTap),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceM,
          vertical: GlassDesignSystem.spaceL,
        ),
      ),
    );
  }
}

class _GlassToastContent extends StatelessWidget {
  final String message;
  final GlassToastType type;
  final VoidCallback? onTap;

  const _GlassToastContent({
    required this.message,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = GlassDesignSystem.standard;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;

    final effectiveBackgroundColor = _getBackgroundColor(theme);
    final effectiveIcon = _getIcon();
    final effectiveIconColor = _getIconColor();

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusL),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: GlassDesignSystem.spaceL,
              vertical: GlassDesignSystem.spaceM,
            ),
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withValues(
                alpha: effectiveOpacity + 0.2,
              ),
              borderRadius: BorderRadius.circular(GlassDesignSystem.radiusL),
              border: Border.all(
                color: (isDarkMode ? Colors.white24 : Colors.black12)
                    .withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: GlassShadows.glassShadowSmall,
            ),
            child: Row(
              children: [
                Icon(
                  effectiveIcon,
                  color: effectiveIconColor,
                  size: GlassDesignSystem.iconM,
                ),
                SizedBox(width: GlassDesignSystem.spaceM),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: GlassDesignSystem.fontSizeM,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (type) {
      case GlassToastType.success:
        return GlassDesignSystem.emerald;
      case GlassToastType.error:
        return Colors.red;
      case GlassToastType.warning:
        return GlassDesignSystem.softGold;
      case GlassToastType.info:
      default:
        return theme.colorScheme.surface;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case GlassToastType.success:
        return Icons.check_circle;
      case GlassToastType.error:
        return Icons.error;
      case GlassToastType.warning:
        return Icons.warning;
      case GlassToastType.info:
      default:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case GlassToastType.success:
        return Colors.white;
      case GlassToastType.error:
        return Colors.white;
      case GlassToastType.warning:
        return Colors.white;
      case GlassToastType.info:
      default:
        return GlassDesignSystem.emerald;
    }
  }
}

enum GlassToastType { info, success, error, warning }
