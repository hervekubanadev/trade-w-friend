import 'package:flutter/material.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NumPad extends StatelessWidget {
  final int pinLength;
  final String currentPin;
  final Function(String) onDigitPress;
  final VoidCallback onDeletePress;
  final bool isLoading;

  const NumPad({
    super.key,
    required this.pinLength,
    required this.currentPin,
    required this.onDigitPress,
    required this.onDeletePress,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            final isFilled = index < currentPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        // Keypad
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) {
              return _KeypadButton(
                label: digit,
                onPressed: isLoading ? null : () => onDigitPress(digit),
              );
            }),
            const SizedBox.shrink(),
            _KeypadButton(
              label: '0',
              onPressed: isLoading ? null : () => onDigitPress('0'),
            ),
            _KeypadButton(
              icon: LucideIcons.delete,
              onPressed: isLoading ? null : onDeletePress,
              isDelete: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDelete;

  const _KeypadButton({
    this.label,
    this.icon,
    this.onPressed,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDelete
                ? Colors.transparent
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
            boxShadow: isDelete || isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          alignment: Alignment.center,
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Icon(
                  icon,
                  size: 24,
                  color: isDelete ? Colors.grey : null,
                ),
        ),
      ),
    );
  }
}
