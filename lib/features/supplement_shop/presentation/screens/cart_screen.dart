import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/branding/brand_config.dart';
import '../../bloc/cart_bloc.dart';
import '../../bloc/cart_event.dart';
import '../../bloc/cart_state.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final CartBloc cartBloc;

  const CartScreen({
    super.key,
    required this.cartBloc,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cartBloc: widget.cartBloc),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Сагс хоослох'),
        content: const Text('Сагсыг хоослохдоо итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Үгүй',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.cartBloc.add(const CartCleared());
              Navigator.pop(context);
            },
            child: const Text(
              'Тийм',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showUndoSnackbar(CartItem removedItem) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.product.name} устгагдлаа'),
        action: SnackBarAction(
          label: 'Буцаах',
          textColor: BrandColors.primary,
          onPressed: () {
            widget.cartBloc.add(const CartItemUndoRemoved());
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BrandColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cartBloc,
      child: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          // Show undo snackbar when item is removed
          if (state.lastRemovedItem != null) {
            _showUndoSnackbar(state.lastRemovedItem!);
          }
          // Show error snackbar
          if (state.status == CartStatus.error && state.errorMessage != null) {
            _showErrorSnackbar(state.errorMessage!);
          }
        },
        child: Scaffold(
          backgroundColor: BrandColors.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        if (state.isEmpty) {
                          return _buildEmptyCart();
                        }
                        return _buildCartItems(state);
                      },
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrandColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: BrandShadows.small,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Миний сагс',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${state.itemCount} бүтээгдэхүүн',
                      style: TextStyle(
                        fontSize: 14,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Continue shopping button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BrandColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: BrandColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Нэмэх',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox();
              return GestureDetector(
                onTap: _clearCart,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrandColors.errorSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: BrandColors.error,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrandColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: BrandColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Сагс хоосон байна',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Бүтээгдэхүүн нэмж эхлээрэй',
            style: TextStyle(
              fontSize: 14,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Дэлгүүр рүү буцах'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.primary,
              foregroundColor: BrandColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cart.items.length,
      itemBuilder: (context, index) {
        final item = state.cart.items[index];
        return _CartItemCard(
          item: item,
          onIncrement: () {
            widget.cartBloc.add(CartItemIncremented(productId: item.product.id));
          },
          onDecrement: () {
            if (item.quantity > 1) {
              widget.cartBloc.add(CartItemDecremented(productId: item.product.id));
            } else {
              widget.cartBloc.add(CartItemRemoved(productId: item.product.id));
            }
          },
          onRemove: () {
            widget.cartBloc.add(CartItemRemoved(productId: item.product.id));
          },
          onQuantityChanged: (quantity) {
            widget.cartBloc.add(CartItemQuantityUpdated(
              productId: item.product.id,
              quantity: quantity,
            ));
          },
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.isEmpty) return const SizedBox();

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: BrandColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Estimated delivery
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: BrandColors.successSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                      size: 18, color: BrandColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Хүргэлт: 1-3 өдөр',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: BrandColors.success,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Үнэгүй',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Нийт бүтээгдэхүүн', '${state.itemCount} ширхэг'),
              const SizedBox(height: 8),
              const Divider(height: 16),
              _buildSummaryRow(
                'Нийт дүн',
                state.formattedTotalPrice,
                isBold: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary,
                    foregroundColor: BrandColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Захиалга өгөх',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? BrandColors.textPrimary : BrandColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold
                ? BrandColors.primary
                : isHighlighted
                    ? BrandColors.success
                    : BrandColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onRemove();
        return false; // Don't dismiss, let bloc handle it for undo
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: BrandColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Устгах', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BrandColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BrandShadows.small,
        ),
        child: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            _buildQuantityControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Image.network(
              item.product.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: BrandColors.surfaceVariant,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: BrandColors.disabled,
                  ),
                );
              },
            ),
          ),
        ),
        // Stock warning badge
        if (item.quantity >= item.product.stockQuantity)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: BrandColors.warning,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'MAX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: BrandColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            item.product.category.displayName,
            style: TextStyle(
              fontSize: 11,
              color: BrandColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              item.formattedTotalPrice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BrandColors.primary,
              ),
            ),
            if (item.quantity > 1) ...[
              const SizedBox(width: 8),
              Text(
                '(₮${item.product.price.toStringAsFixed(0)} x ${item.quantity})',
                style: TextStyle(
                  fontSize: 11,
                  color: BrandColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Column(
      children: [
        // Remove button
        GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: 18,
              color: BrandColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Horizontal quantity controls (improved UX)
        Container(
          decoration: BoxDecoration(
            color: BrandColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: onDecrement,
                isEnabled: true,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  item.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: onIncrement,
                isEnabled: item.quantity < item.product.stockQuantity,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? BrandColors.textPrimary : BrandColors.disabled,
        ),
      ),
    );
  }
}
