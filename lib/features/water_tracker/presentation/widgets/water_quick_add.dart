import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

class WaterQuickAdd extends StatelessWidget {
  final Function(int) onAdd;
  final bool isDarkMode;

  const WaterQuickAdd({
    super.key,
    required this.onAdd,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 18,
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Түргэн нэмэх',
              style: AppTypography.titleLarge.copyWith(
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _QuickAddButton(
              icon: Icons.local_cafe_outlined,
              label: '150мл',
              subtitle: 'Аяга',
              amount: 150,
              color: const Color(0xFF8B4513), // Coffee brown - unique to this context
              onTap: () => onAdd(150),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickAddButton(
              icon: Icons.water_drop_outlined,
              label: '250мл',
              subtitle: 'Стакан',
              amount: 250,
              color: AppColors.water,
              onTap: () => onAdd(250),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickAddButton(
              icon: Icons.local_drink_outlined,
              label: '500мл',
              subtitle: 'Лонх',
              amount: 500,
              color: AppColors.success,
              onTap: () => onAdd(500),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: AppSpacing.sm),
            _CustomAddButton(
              onAdd: onAdd,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final int amount;
  final Color color;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isPressed
                        ? [widget.color.withValues(alpha: 0.25), widget.color.withValues(alpha: 0.15)]
                        : [widget.color.withValues(alpha: 0.15), widget.color.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: _isPressed
                        ? widget.color.withValues(alpha: 0.5)
                        : widget.color.withValues(alpha: 0.3),
                    width: _isPressed ? 2 : 1,
                  ),
                  boxShadow: _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.label,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode
                            ? AppColors.darkTextPrimary
                            : widget.color.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CustomAddButton extends StatefulWidget {
  final Function(int) onAdd;
  final bool isDarkMode;

  const _CustomAddButton({
    required this.onAdd,
    required this.isDarkMode,
  });

  @override
  State<_CustomAddButton> createState() => _CustomAddButtonState();
}

class _CustomAddButtonState extends State<_CustomAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    HapticFeedback.lightImpact();
    _showCustomAmountDialog(context);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? (_isPressed ? AppColors.darkSurfaceVariant : AppColors.darkSurface)
                      : (_isPressed ? AppColors.surfaceVariant : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.border,
                    width: _isPressed ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Бусад',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Өөрөө',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDarkMode ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.water.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.water,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Усны хэмжээ',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: AppTypography.numberSmall.copyWith(
                  color: widget.isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: widget.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.disabled,
                  ),
                  suffixText: 'мл',
                  suffixStyle: AppTypography.bodyMedium.copyWith(
                    color: widget.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.water,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Хэмжээ оруулна уу';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null) {
                    return 'Тоо оруулна уу';
                  }
                  if (amount <= 0) {
                    return '0-с их байх ёстой';
                  }
                  if (amount > 5000) {
                    return '5000мл-с бага байх ёстой';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Quick presets
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [100, 200, 300, 400, 750, 1000].map((amount) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.text = amount.toString();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: widget.isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        '$amountмл',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: widget.isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Цуцлах',
              style: AppTypography.labelLarge.copyWith(
                color: widget.isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = int.parse(controller.text);
                HapticFeedback.mediumImpact();
                widget.onAdd(amount);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.water,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(
              'Нэмэх',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
