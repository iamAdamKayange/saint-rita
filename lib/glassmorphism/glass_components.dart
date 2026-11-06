import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

/// Premium Glass Card - Frosted glass with variable transparency and blur
class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassCardPreset? preset;
  final double? customBlur;
  final double? customOpacity;
  final double? customBorderOpacity;
  final double? customElevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isInteractive;

  const GlassCard({
    super.key,
    required this.child,
    this.preset,
    this.customBlur,
    this.customOpacity,
    this.customBorderOpacity,
    this.customElevation,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use preset or custom values
    final effectivePreset = preset ?? GlassDesignSystem.standard;
    final effectiveBlur = customBlur ?? effectivePreset.blur;
    final effectiveOpacity = customOpacity ?? effectivePreset.opacity;
    final effectiveBorderOpacity =
        customBorderOpacity ?? effectivePreset.borderOpacity;
    final effectiveElevation = customElevation ?? effectivePreset.elevation;
    final effectiveBorderRadius = borderRadius ?? GlassDesignSystem.radiusL;

    // Colors based on theme
    final effectiveBackgroundColor =
        backgroundColor ??
        (isDarkMode
            ? GlassDesignSystem.darkGlass
            : GlassDesignSystem.lightGlass);
    final effectiveBorderColor =
        borderColor ?? (isDarkMode ? Colors.white24 : Colors.black12);

    Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          padding: padding ?? EdgeInsets.all(GlassDesignSystem.spaceL),
          margin: margin,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor.withValues(alpha: effectiveOpacity),
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: Border.all(
              color: effectiveBorderColor.withValues(
                alpha: effectiveBorderOpacity,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: GlassDesignSystem.glassShadowOpacity,
                ),
                blurRadius: effectiveElevation * 2,
                offset: Offset(0, effectiveElevation / 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (isInteractive && onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: cardContent,
        ),
      );
    } else if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}

/// Premium Glass Button - Frosted glass with elegant interactions
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GlassCardPreset? preset;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isOutlined;
  final bool isLoading;
  final Widget? icon;
  final bool isFullWidth;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.preset,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.standard;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;
    final effectiveHeight = height ?? 56.0;
    final effectiveBorderRadius = GlassDesignSystem.radiusM;

    final effectiveBackgroundColor =
        backgroundColor ??
        (isOutlined ? Colors.transparent : GlassDesignSystem.emerald);
    final effectiveTextColor =
        textColor ??
        (isOutlined
            ? (isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen)
            : Colors.white);
    final effectiveBorderColor = borderColor ?? GlassDesignSystem.emerald;

    Widget buttonContent = ClipRRect(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Material(
          color: effectiveBackgroundColor.withValues(
            alpha: isOutlined ? effectiveOpacity : effectiveOpacity + 0.2,
          ),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            child: Container(
              height: effectiveHeight,
              width: width ?? (isFullWidth ? double.infinity : null),
              padding: EdgeInsets.symmetric(
                horizontal: GlassDesignSystem.spaceXL,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                border: isOutlined
                    ? Border.all(color: effectiveBorderColor, width: 1.5)
                    : null,
                boxShadow: isOutlined ? null : GlassShadows.glassShadowSmall,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveTextColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            icon!,
                            SizedBox(width: GlassDesignSystem.spaceS),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              color: effectiveTextColor,
                              fontSize: GlassDesignSystem.fontSizeM,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonContent);
    }

    if (width != null) {
      return SizedBox(width: width, child: buttonContent);
    }

    return buttonContent;
  }
}

/// Premium Glass Input - Frosted glass text fields
class GlassInput extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final GlassCardPreset? preset;

  const GlassInput({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.textCapitalization,
    this.preset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.standard;
    final effectiveBlur = effectivePreset.blur;
    final effectiveOpacity = effectivePreset.opacity;
    final effectiveBorderRadius = GlassDesignSystem.radiusM;

    final effectiveBorderColor = isDarkMode ? Colors.white24 : Colors.black12;
    final effectiveFillColor = isDarkMode
        ? GlassDesignSystem.darkGlass
        : GlassDesignSystem.lightGlass;

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          height: maxLines == 1 ? 56.0 : null,
          decoration: BoxDecoration(
            color: effectiveFillColor.withValues(alpha: effectiveOpacity + 0.1),
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: Border.all(
              color: effectiveBorderColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            maxLines: maxLines,
            maxLength: maxLength,
            enabled: enabled,
            textInputAction: textInputAction,
            focusNode: focusNode,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: GlassDesignSystem.fontSizeM,
            ),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: GlassDesignSystem.spaceL,
                vertical: GlassDesignSystem.spaceM,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(
                  color: GlassDesignSystem.emerald,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: GlassDesignSystem.fontSizeS,
              ),
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black38,
                fontSize: GlassDesignSystem.fontSizeM,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Glass Container - Versatile glass wrapper
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassCardPreset? preset;
  final double? customBlur;
  final double? customOpacity;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final AlignmentGeometry? alignment;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  const GlassContainer({
    super.key,
    required this.child,
    this.preset,
    this.customBlur,
    this.customOpacity,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.alignment,
    this.width,
    this.height,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectivePreset = preset ?? GlassDesignSystem.standard;
    final effectiveBlur = customBlur ?? effectivePreset.blur;
    final effectiveOpacity = customOpacity ?? effectivePreset.opacity;
    final effectiveBorderRadius = borderRadius ?? GlassDesignSystem.radiusL;

    final effectiveBackgroundColor =
        backgroundColor ??
        (isDarkMode
            ? GlassDesignSystem.darkGlass
            : GlassDesignSystem.lightGlass);
    final effectiveBorderColor =
        borderColor ?? (isDarkMode ? Colors.white24 : Colors.black12);

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withValues(
                alpha: effectiveOpacity,
              ),
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: Border.all(
                color: effectiveBorderColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
