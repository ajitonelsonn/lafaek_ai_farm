import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Labelled text field used by the simple forms (Add Crop, Add Location…).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.suffix,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final String? suffix;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.body,
          decoration: InputDecoration(hintText: hint, suffixText: suffix),
        ),
      ],
    );
  }
}

/// Horizontal single-select chip row, e.g. crop type.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    this.iconOf,
    this.enabledOf,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;

  /// Lets a caller grey out options that are not usable right now — an
  /// online-only crop while the phone has no signal, for instance.
  final bool Function(T)? enabledOf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              _Choice(
                label: labelOf(o),
                icon: iconOf?.call(o),
                selected: o == selected,
                enabled: enabledOf?.call(o) ?? true,
                onTap: () => onSelected(o),
              ),
          ],
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: !enabled
          ? AppColors.surfaceMuted
          : selected
              ? AppColors.primary
              : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
                color: !enabled
                    ? AppColors.border
                    : selected
                        ? AppColors.primary
                        : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.primary),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: AppTextStyles.bodyStrong.copyWith(
                    fontSize: 14,
                    color: !enabled
                        ? AppColors.textSecondary
                        : selected
                            ? Colors.white
                            : AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grouped settings list section with a title and rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(letterSpacing: 0.8)),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.only(left: 68),
                    child: Divider(),
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A row inside a [SettingsGroup].
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.icon,
    this.asset,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.color = AppColors.primary,
    this.tint = AppColors.lightGreen,
  }) : assert(icon != null || asset != null, 'give the row an icon or an asset');

  final IconData? icon;

  /// Illustrated icon from `assets/images/icons/`; takes precedence over
  /// [icon] when both are given.
  final String? asset;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              // The art has its own pale square; draw it close to the tile
              // edge so the two do not read as a frame.
              child: asset != null
                  ? AppIcon(asset!, size: 37)
                  : Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.secondary,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
