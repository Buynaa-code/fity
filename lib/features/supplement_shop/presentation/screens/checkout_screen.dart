import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/branding/brand_config.dart';
import '../../bloc/cart_bloc.dart';
import '../../bloc/cart_event.dart';
import '../../bloc/cart_state.dart';
import '../../domain/entities/order.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartBloc cartBloc;

  const CheckoutScreen({
    super.key,
    required this.cartBloc,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  bool _agreedToTerms = false;
  bool _isProcessing = false;

  // Field focus and validation states
  final Map<String, bool> _fieldTouched = {};
  final Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    // Mark all fields as touched
    setState(() {
      _fieldTouched['fullName'] = true;
      _fieldTouched['phone'] = true;
      _fieldTouched['district'] = true;
      _fieldTouched['address'] = true;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Бүх талбарыг зөв бөглөнө үү'),
          backgroundColor: BrandColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Үйлчилгээний нөхцөлийг зөвшөөрнө үү'),
          backgroundColor: BrandColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final shippingAddress = ShippingAddress(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      district: _districtController.text.trim(),
    );

    widget.cartBloc.add(CartCheckoutRequested(
      shippingAddress: shippingAddress,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
    ));
  }

  String? _validateOnBlur(String fieldName, String? value) {
    if (!(_fieldTouched[fieldName] ?? false)) return null;

    switch (fieldName) {
      case 'fullName':
        if (value == null || value.trim().isEmpty) {
          return 'Овог нэр оруулна уу';
        }
        if (value.trim().length < 2) {
          return 'Овог нэр хэт богино байна';
        }
        return null;
      case 'phone':
        if (value == null || value.trim().isEmpty) {
          return 'Утасны дугаар оруулна уу';
        }
        final phoneRegex = RegExp(r'^[0-9]{8}$');
        if (!phoneRegex.hasMatch(value.trim())) {
          return '8 оронтой утасны дугаар оруулна уу';
        }
        return null;
      case 'district':
        if (value == null || value.trim().isEmpty) {
          return 'Дүүрэг оруулна уу';
        }
        return null;
      case 'address':
        if (value == null || value.trim().isEmpty) {
          return 'Хаяг оруулна уу';
        }
        if (value.trim().length < 10) {
          return 'Хаягийг дэлгэрэнгүй бичнэ үү';
        }
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cartBloc,
      child: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.checkoutSuccess && state.lastOrder != null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => OrderSuccessScreen(order: state.lastOrder!),
              ),
              (route) => route.isFirst,
            );
          } else if (state.status == CartStatus.error) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Алдаа гарлаа'),
                backgroundColor: BrandColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: BrandColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step indicator
                          _buildStepIndicator(),
                          const SizedBox(height: 24),

                          // Customer info section
                          _buildSectionTitle('Хүлээн авагчийн мэдээлэл', Icons.person_outline),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _fullNameController,
                            fieldName: 'fullName',
                            label: 'Овог нэр',
                            hint: 'Овог нэрээ оруулна уу',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            fieldName: 'phone',
                            label: 'Утасны дугаар',
                            hint: '99001122',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            maxLength: 8,
                          ),
                          const SizedBox(height: 24),

                          // Address section
                          _buildSectionTitle('Хүргэлтийн хаяг', Icons.location_on_outlined),
                          const SizedBox(height: 16),
                          _buildDistrictDropdown(),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _addressController,
                            fieldName: 'address',
                            label: 'Дэлгэрэнгүй хаяг',
                            hint: 'Хороо, байр, орц, тоот...',
                            icon: Icons.home_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),

                          // Payment method section
                          _buildSectionTitle('Төлбөрийн хэлбэр', Icons.payment_outlined),
                          const SizedBox(height: 16),
                          _buildPaymentMethods(),
                          const SizedBox(height: 24),

                          // Notes section
                          _buildSectionTitle('Нэмэлт тэмдэглэл', Icons.note_outlined),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _notesController,
                            fieldName: 'notes',
                            label: 'Тэмдэглэл (заавал биш)',
                            hint: 'Хүргэлттэй холбоотой тэмдэглэл...',
                            icon: Icons.edit_note_outlined,
                            maxLines: 3,
                            isRequired: false,
                          ),
                          const SizedBox(height: 24),

                          // Order summary
                          _buildOrderSummary(),
                          const SizedBox(height: 16),

                          // Terms checkbox
                          _buildTermsCheckbox(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
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
          const Text(
            'Захиалга баталгаажуулах',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BrandShadows.small,
      ),
      child: Row(
        children: [
          _buildStep(1, 'Сагс', true, true),
          _buildStepLine(true),
          _buildStep(2, 'Мэдээлэл', true, false),
          _buildStepLine(false),
          _buildStep(3, 'Дууссан', false, false),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? BrandColors.success
                : isActive
                    ? BrandColors.primary
                    : BrandColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : BrandColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? BrandColors.textPrimary : BrandColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? BrandColors.success : BrandColors.surfaceVariant,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: BrandColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String fieldName,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    bool isRequired = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BrandShadows.small,
        border: _fieldErrors[fieldName] != null
            ? Border.all(color: BrandColors.error, width: 1)
            : null,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: (value) {
          if (_fieldTouched[fieldName] ?? false) {
            setState(() {
              _fieldErrors[fieldName] = _validateOnBlur(fieldName, value);
            });
          }
        },
        onTap: () {
          setState(() {
            _fieldTouched[fieldName] = true;
          });
        },
        validator: isRequired
            ? (value) => _validateOnBlur(fieldName, value)
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: BrandColors.primary),
          suffixIcon: _fieldErrors[fieldName] != null
              ? Icon(Icons.error_outline, color: BrandColors.error)
              : (_fieldTouched[fieldName] ?? false) && controller.text.isNotEmpty
                  ? Icon(Icons.check_circle, color: BrandColors.success)
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: BrandColors.surface,
          contentPadding: const EdgeInsets.all(16),
          errorText: _fieldErrors[fieldName],
          errorStyle: TextStyle(color: BrandColors.error, height: 0.8),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    final districts = [
      'Баянгол',
      'Баянзүрх',
      'Сонгинохайрхан',
      'Сүхбаатар',
      'Хан-Уул',
      'Чингэлтэй',
      'Налайх',
      'Багануур',
      'Багахангай',
    ];

    return Container(
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BrandShadows.small,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _districtController.text.isEmpty ? null : _districtController.text,
        decoration: InputDecoration(
          labelText: 'Дүүрэг',
          prefixIcon: Icon(Icons.location_city_outlined, color: BrandColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: BrandColors.surface,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: districts.map((district) {
          return DropdownMenuItem(value: district, child: Text(district));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _districtController.text = value ?? '';
            _fieldTouched['district'] = true;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Дүүрэг сонгоно уу';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        children: [
          _buildPaymentOption('cash', 'Бэлнээр', Icons.money, 'Хүргэлтийн үед төлөх'),
          const Divider(height: 16),
          _buildPaymentOption('qpay', 'QPay', Icons.qr_code, 'QR код уншуулах'),
          const Divider(height: 16),
          _buildPaymentOption('card', 'Картаар', Icons.credit_card, 'Дансаар шилжүүлэх'),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon, String description) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: BrandColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? BrandColors.primary : BrandColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : BrandColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? BrandColors.primary : BrandColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (v) {
                setState(() {
                  _selectedPaymentMethod = v ?? 'cash';
                });
              },
              activeColor: BrandColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrandColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: BrandShadows.small,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 20, color: BrandColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Захиалгын дэлгэрэнгүй',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...state.cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.network(
                              item.product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: BrandColors.surfaceVariant,
                                  child: const Icon(Icons.image, size: 20),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${item.quantity} x ${item.product.formattedPrice}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BrandColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.formattedTotalPrice,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
              const Divider(),
              const SizedBox(height: 8),
              _buildSummaryRow('Бүтээгдэхүүн', state.formattedTotalPrice),
              const SizedBox(height: 8),
              _buildSummaryRow('Хүргэлт', 'Үнэгүй', isGreen: true),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildSummaryRow('Нийт', state.formattedTotalPrice, isBold: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _agreedToTerms ? BrandColors.successSurface : BrandColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: _agreedToTerms
            ? Border.all(color: BrandColors.success.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            activeColor: BrandColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _agreedToTerms = !_agreedToTerms;
                });
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: BrandColors.textPrimary),
                  children: [
                    const TextSpan(text: 'Би '),
                    TextSpan(
                      text: 'үйлчилгээний нөхцөл',
                      style: TextStyle(
                        color: BrandColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: '-ийг хүлээн зөвшөөрч байна'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isGreen = false}) {
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
                : isGreen
                    ? BrandColors.success
                    : BrandColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
          // Show estimated delivery
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: BrandColors.infoSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: BrandColors.info),
                const SizedBox(width: 8),
                Text(
                  'Таны захиалга 1-3 хоногт хүргэгдэнэ',
                  style: TextStyle(fontSize: 12, color: BrandColors.info),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.primary,
                foregroundColor: BrandColors.textOnPrimary,
                disabledBackgroundColor: BrandColors.primary.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Захиалга баталгаажуулах',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
