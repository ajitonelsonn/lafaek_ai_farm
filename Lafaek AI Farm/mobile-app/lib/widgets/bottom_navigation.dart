import 'package:flutter/material.dart';

import '../core/app_assets.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

class _NavItem {
  const _NavItem(this.label, this.asset);

  /// Resolved per build so the bar follows the chosen language.
  final String Function(S) label;
  final String asset;
}

const List<_NavItem> _items = [
  _NavItem(_homeLabel, AppAssets.icHome),
  _NavItem(_scanLabel, AppAssets.icScan),
  _NavItem(_assistantLabel, AppAssets.icAssistant),
  _NavItem(_farmLabel, AppAssets.icFarm),
  _NavItem(_moreLabel, AppAssets.icMore),
];

String _homeLabel(S s) => s.navHome;
String _scanLabel(S s) => s.navScan;
String _assistantLabel(S s) => s.navAssistant;
String _farmLabel(S s) => s.navFarm;
String _moreLabel(S s) => s.navMore;

/// Persistent five-destination bottom bar with a floating rounded look.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A14212B),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: bottomInset > 0 ? bottomInset : 12,
        left: 4,
        right: 4,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: _NavButton(
                item: _items[i],
                label: _items[i].label(S.of(context)),
                selected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 48,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? AppColors.lightGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                // The artwork has fixed colours, so the unselected state is
                // expressed with opacity rather than a tint.
                child: AppIcon(
                  item.asset,
                  size: 26,
                  opacity: selected ? 1 : 0.55,
                  semanticLabel: label,
                ),
              ),
              const SizedBox(height: 4),
              // Scale down rather than truncate so "AI Assistant" always
              // reads in full on 360dp phones.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
