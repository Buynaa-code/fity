import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/services/checkin_service.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_spacing.dart';
import '../../../core/ui/theme/app_typography.dart';

class ReceptionistScannerScreen extends StatefulWidget {
  const ReceptionistScannerScreen({super.key});

  @override
  State<ReceptionistScannerScreen> createState() => _ReceptionistScannerScreenState();
}

class _ReceptionistScannerScreenState extends State<ReceptionistScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  Map<String, dynamic>? _lastScannedMember;
  bool _scanSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    String oderId = '';
    String userName = 'Гишүүн';

    try {
      final data = jsonDecode(rawValue) as Map<String, dynamic>;

      // Check QR version
      final version = data['v'] as int? ?? 1;
      oderId = data['u'] as String? ?? '';
      userName = data['n'] as String? ?? 'Гишүүн';

      if (oderId.isEmpty) {
        setState(() {
          _errorMessage = 'QR код буруу байна. Хэрэглэгчийн мэдээлэл олдсонгүй.';
          _isProcessing = false;
        });
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) setState(() => _errorMessage = null);
        return;
      }

      // Validate token expiration for v2 QR codes
      if (version >= 2) {
        final expTimestamp = data['exp'] as int?;
        if (expTimestamp != null) {
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(expTimestamp);
          if (DateTime.now().isAfter(expiresAt)) {
            setState(() {
              _errorMessage = 'QR кодын хугацаа дууссан байна.\nШинэ QR код үүсгэнэ үү.';
              _isProcessing = false;
            });
            HapticFeedback.heavyImpact();
            await Future.delayed(const Duration(seconds: 3));
            if (mounted) setState(() => _errorMessage = null);
            return;
          }
        }
      }

    } catch (_) {
      setState(() {
        _errorMessage = 'QR код таних боломжгүй.\nЗөв QR код уншуулна уу.';
        _isProcessing = false;
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _errorMessage = null);
      return;
    }

    // Check for duplicate check-in (already active session)
    final activeCheckIn = await CheckInService.instance.getActiveCheckInByUserId(oderId);
    if (activeCheckIn != null) {
      setState(() {
        _errorMessage = '$userName аль хэдийн check-in хийсэн байна.\nЭхлээд check-out хийнэ үү.';
        _isProcessing = false;
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _errorMessage = null);
      return;
    }

    // Perform check-in
    await CheckInService.instance.checkIn(oderId);

    setState(() {
      _lastScannedMember = {
        'userId': oderId,
        'userName': userName,
        'checkInTime': DateTime.now(),
      };
      _scanSuccess = true;
      _isProcessing = false;
    });

    HapticFeedback.heavyImpact();

    // Reset after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _scanSuccess = false;
        _lastScannedMember = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          if (_controller != null)
            MobileScanner(
              controller: _controller!,
              onDetect: _handleScan,
            ),

          // Overlay
          _buildOverlay(),

          // Top bar
          _buildTopBar(),

          // Bottom info
          _buildBottomInfo(),

          // Success overlay
          if (_scanSuccess) _buildSuccessOverlay(),

          // Error overlay
          if (_errorMessage != null) _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(
          borderColor: _scanSuccess
              ? AppColors.success
              : (_errorMessage != null ? AppColors.error : AppColors.primary),
          borderWidth: 3,
          overlayColor: Colors.black.withValues(alpha: 0.5),
          borderRadius: 20,
          cutOutSize: 280,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Text(
              'QR Скан',
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _controller?.toggleTorch();
              },
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QR кодыг хүрээнд байрлуулна уу',
                            style: AppTypography.titleSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Гишүүний QR код автоматаар уншигдана',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Check-in амжилттай!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _lastScannedMember?['userName'] ?? 'Гишүүн',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Тавтай морилно уу!',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Алдаа',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage ?? 'Тодорхойгүй алдаа',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double cutOutSize;

  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.overlayColor,
    required this.borderRadius,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw overlay
    canvas.drawPath(
      getOuterPath(rect),
      Paint()..color = overlayColor,
    );

    // Draw border
    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(
      borderRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Draw corner decorations
    final cornerLength = 30.0;
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 2
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top + cornerLength),
      Offset(cutOutRect.left, cutOutRect.top + borderRadius),
      paint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left + cornerLength, cutOutRect.top),
      Offset(cutOutRect.left + borderRadius, cutOutRect.top),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top + cornerLength),
      Offset(cutOutRect.right, cutOutRect.top + borderRadius),
      paint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right - cornerLength, cutOutRect.top),
      Offset(cutOutRect.right - borderRadius, cutOutRect.top),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom - cornerLength),
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
      paint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left + cornerLength, cutOutRect.bottom),
      Offset(cutOutRect.left + borderRadius, cutOutRect.bottom),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom - cornerLength),
      Offset(cutOutRect.right, cutOutRect.bottom - borderRadius),
      paint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right - cornerLength, cutOutRect.bottom),
      Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
