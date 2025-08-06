import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  late MobileScannerController controller;
  bool isScanning = true;
  bool flashOn = false;
  late AnimationController _pulseController;
  late AnimationController _scanlineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scanlineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanlineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanlineController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanlineController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'QR Scanner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                flashOn ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Camera view
                MobileScanner(
                  controller: controller,
                  onDetect: _onQRDetect,
                ),
                
                // Custom overlay with animations
                Positioned.fill(
                  child: CustomPaint(
                    painter: QROverlayPainter(
                      pulseAnimation: _pulseAnimation,
                      scanlineAnimation: _scanlineAnimation,
                      isScanning: isScanning,
                    ),
                  ),
                ),
                
                // Scanning instructions
                Positioned(
                  top: MediaQuery.of(context).padding.top + 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Gym QR кодоо уншуулж оруулна уу',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom section
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    isDark ? const Color(0xFF1A1A1A) : Colors.grey[100]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isScanning ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE7409).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFE7409).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isScanning 
                                    ? FontAwesomeIcons.qrcode 
                                    : FontAwesomeIcons.check,
                                color: const Color(0xFFFE7409),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isScanning ? 'Scanning...' : 'Success!',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRDetect(BarcodeCapture barcodeCapture) {
    if (isScanning && barcodeCapture.barcodes.isNotEmpty) {
      final String? code = barcodeCapture.barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          isScanning = false;
        });
        
        HapticFeedback.lightImpact();
        _processQRCode(code);
      }
    }
  }

  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      flashOn = !flashOn;
    });
    HapticFeedback.selectionClick();
  }

  void _processQRCode(String code) {
    // Simulate gym entry processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showSuccessDialog(code);
      }
    });
  }

  void _showSuccessDialog(String qrCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFE7409).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFFFE7409),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gym-д амжилттай орлоо!',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'QR Code: ${qrCode.substring(0, qrCode.length > 20 ? 20 : qrCode.length)}...',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFE7409),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QROverlayPainter extends CustomPainter {
  final Animation<double> pulseAnimation;
  final Animation<double> scanlineAnimation;
  final bool isScanning;

  QROverlayPainter({
    required this.pulseAnimation,
    required this.scanlineAnimation,
    required this.isScanning,
  }) : super(
          repaint: Listenable.merge([pulseAnimation, scanlineAnimation]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    if (!isScanning) return;

    final center = Offset(size.width / 2, size.height / 2);
    const scanAreaSize = 280.0;
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw overlay background (darken everything except scan area)
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, overlayPaint);

    // Draw scan area border
    final borderPaint = Paint()
      ..color = const Color(0xFFFE7409)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
      borderPaint,
    );

    // Animated scanline
    final scanlinePaint = Paint()
      ..color = const Color(0xFFFE7409).withOpacity(0.8)
      ..strokeWidth = 2;

    final scanlineY = scanRect.top + (scanRect.height * scanlineAnimation.value);

    canvas.drawLine(
      Offset(scanRect.left + 20, scanlineY),
      Offset(scanRect.right - 20, scanlineY),
      scanlinePaint,
    );

    // Corner indicators
    final cornerPaint = Paint()
      ..color = const Color(0xFFFE7409)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 25.0;
    const cornerOffset = 10.0;
    
    // Top-left corner
    canvas.drawLine(
      Offset(scanRect.left - cornerOffset, scanRect.top - cornerOffset),
      Offset(scanRect.left - cornerOffset + cornerLength, scanRect.top - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left - cornerOffset, scanRect.top - cornerOffset),
      Offset(scanRect.left - cornerOffset, scanRect.top - cornerOffset + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanRect.right + cornerOffset, scanRect.top - cornerOffset),
      Offset(scanRect.right + cornerOffset - cornerLength, scanRect.top - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right + cornerOffset, scanRect.top - cornerOffset),
      Offset(scanRect.right + cornerOffset, scanRect.top - cornerOffset + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanRect.left - cornerOffset, scanRect.bottom + cornerOffset),
      Offset(scanRect.left - cornerOffset + cornerLength, scanRect.bottom + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left - cornerOffset, scanRect.bottom + cornerOffset),
      Offset(scanRect.left - cornerOffset, scanRect.bottom + cornerOffset - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanRect.right + cornerOffset, scanRect.bottom + cornerOffset),
      Offset(scanRect.right + cornerOffset - cornerLength, scanRect.bottom + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right + cornerOffset, scanRect.bottom + cornerOffset),
      Offset(scanRect.right + cornerOffset, scanRect.bottom + cornerOffset - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}