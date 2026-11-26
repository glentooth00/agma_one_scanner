import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../app/theme.dart';
import '../../services/scanner_service.dart';
import 'member_details_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController _controller;

  bool _isProcessing = false;
  bool _isCameraPaused = false;

  @override
  void initState() {
    super.initState();

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing || !mounted) return;

    final barcode = capture.barcodes.firstOrNull;
    final membershipId = barcode?.rawValue?.trim();

    if (membershipId == null || membershipId.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isCameraPaused = true;
    });

    try {
      await _controller.stop();

      final member = await ScannerService.getMember(membershipId);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDetailsScreen(member: member),
        ),
      );
    } on ScannerServiceException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to process this QR code. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isCameraPaused = false;
        });

        try {
          await _controller.start();
        } catch (_) {
          // Camera may no longer be available if the screen is closing.
        }
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primary,
        ),
      );
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to toggle the flashlight.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'QR Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: _toggleTorch,
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
              child: Column(
                children: [
                  const Text(
                    'Scan Member QR Code',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Position the member QR code inside the frame to retrieve their registration.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _handleDetection,
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ScannerFramePainter(),
                        ),
                      ),
                      if (_isCameraPaused)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Retrieving member information...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.sageLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: AppTheme.sage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to scan',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Scan the QR code printed on the member card.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.success,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42);

    final frameWidth = size.width * 0.72;
    final frameHeight = frameWidth;
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, frameWidth, frameHeight),
      const Radius.circular(20),
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final framePath = Path()..addRRect(frameRect);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        backgroundPath,
        framePath,
      ),
      overlayPaint,
    );

    final cornerPaint = Paint()
      ..color = AppTheme.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    final corners = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + 20)
      ..quadraticBezierTo(left, top, left + 20, top)
      ..lineTo(left + cornerLength, top)
      ..moveTo(left + frameWidth - cornerLength, top)
      ..lineTo(left + frameWidth - 20, top)
      ..quadraticBezierTo(
        left + frameWidth,
        top,
        left + frameWidth,
        top + 20,
      )
      ..lineTo(left + frameWidth, top + cornerLength)
      ..moveTo(left, top + frameHeight - cornerLength)
      ..lineTo(left, top + frameHeight - 20)
      ..quadraticBezierTo(
        left,
        top + frameHeight,
        left + 20,
        top + frameHeight,
      )
      ..lineTo(left + cornerLength, top + frameHeight)
      ..moveTo(
        left + frameWidth - cornerLength,
        top + frameHeight,
      )
      ..lineTo(
        left + frameWidth - 20,
        top + frameHeight,
      )
      ..quadraticBezierTo(
        left + frameWidth,
        top + frameHeight,
        left + frameWidth,
        top + frameHeight - 20,
      )
      ..lineTo(
        left + frameWidth,
        top + frameHeight - cornerLength,
      );

    canvas.drawPath(corners, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}