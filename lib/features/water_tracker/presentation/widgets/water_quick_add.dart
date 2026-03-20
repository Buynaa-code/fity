import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Түргэн нэмэх',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _QuickAddButton(
              icon: Icons.local_cafe_outlined,
              label: '150мл',
              subtitle: 'Аяга',
              amount: 150,
              color: const Color(0xFF8B4513),
              onTap: () => onAdd(150),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: 10),
            _QuickAddButton(
              icon: Icons.water_drop_outlined,
              label: '250мл',
              subtitle: 'Стакан',
              amount: 250,
              color: const Color(0xFF3498DB),
              onTap: () => onAdd(250),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: 10),
            _QuickAddButton(
              icon: Icons.local_drink_outlined,
              label: '500мл',
              subtitle: 'Лонх',
              amount: 500,
              color: const Color(0xFF2ECC71),
              onTap: () => onAdd(500),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: 10),
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
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(8),
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
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode
                            ? Colors.white
                            : widget.color.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 10,
                        color: widget.isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
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
                      ? (_isPressed ? Colors.grey.shade700 : Colors.grey.shade800)
                      : (_isPressed ? Colors.grey.shade200 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                    width: _isPressed ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: widget.isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Бусад',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Өөрөө',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 10,
                        color: widget.isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
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
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop,
                color: Color(0xFF3498DB),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Усны хэмжээ',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w700,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
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
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                  suffixText: 'мл',
                  suffixStyle: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    color: widget.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF3498DB),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
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
              const SizedBox(height: 16),
              // Quick presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [100, 200, 300, 400, 750, 1000].map((amount) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.text = amount.toString();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '${amount}мл',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
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
              style: TextStyle(
                fontFamily: 'Rubik',
                color: widget.isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
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
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Нэмэх',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
