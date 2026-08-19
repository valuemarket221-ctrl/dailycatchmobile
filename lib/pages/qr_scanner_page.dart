import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/payment_api_service.dart';

/// Écran de scan QR Code pour les partenaires
/// Permet aux partenaires de scanner le QR code du client pour valider la récupération
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key, this.order = const {}});

  final Map<String, dynamic> order;

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _hasScanned = false;
  String _scannedData = '';
  bool _isValid = false;
  bool _isProcessing = false;
  String _validationMessage = '';
  Map<String, dynamic> _validatedOrder = const {};
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final PaymentApiService _paymentApiService = PaymentApiService();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcodeCapture(BarcodeCapture capture) {
    if (_hasScanned || _isProcessing) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.trim().isEmpty) return;
    _validateQRCode(value);
  }

  Future<void> _validateQRCode(String data) async {
    _scannerController.stop();
    setState(() {
      _scannedData = data;
      _hasScanned = true;
      _isProcessing = true;
    });

    try {
      final parsed = _parsePickupPayload(data);
      await _paymentApiService.completePickup(
        orderId: parsed.orderId,
        pickupCode: parsed.pickupCode,
      );
      if (!mounted) return;
      setState(() {
        _isValid = true;
        _isProcessing = false;
        _validationMessage = 'Retrait validé côté serveur.';
        _validatedOrder = {
          ...widget.order,
          'orderId': parsed.orderId,
          'pickupCode': parsed.pickupCode,
        };
      });
    } on PaymentApiException catch (error) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _isValid = false;
        _isProcessing = false;
        _validationMessage = _pickupErrorMessage(error);
      });
    } on FormatException {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _isValid = false;
        _isProcessing = false;
        _validationMessage = 'Format du QR code invalide.';
      });
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _isValid = false;
        _isProcessing = false;
        _validationMessage = 'Validation impossible pour le moment.';
      });
    }
  }

  String _pickupErrorMessage(PaymentApiException error) {
    if (error.statusCode == 403) {
      return 'Compte non autorisé à valider un retrait.';
    }
    if (error.statusCode == 409) {
      return 'Commande déjà retirée, annulée ou pas encore prête.';
    }
    if (error.message == 'invalid_pickup_code') {
      return 'Code de retrait incorrect.';
    }
    if (error.message == 'order_not_found') {
      return 'Commande introuvable.';
    }
    return 'QR code invalide, expiré ou backend indisponible.';
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _scannedData = '';
      _isValid = false;
      _isProcessing = false;
      _validationMessage = '';
      _validatedOrder = const {};
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scanner QR Code',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Lampe',
            icon: const Icon(Icons.flashlight_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.blueBic.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.blueBic),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scannez le QR Code du client pour valider le retrait du panier',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.blueBic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zone de scan
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _hasScanned
                                ? (_isValid ? Colors.green : Colors.red)
                                : AppColors.blueBic,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child:
                        _hasScanned
                            ? _buildScanResult()
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: MobileScanner(
                                controller: _scannerController,
                                onDetect: _handleBarcodeCapture,
                                errorBuilder:
                                    (context, error) =>
                                        _buildCameraError(error),
                              ),
                            ),
                  ),
                ),

                // Guides de scan
                if (!_hasScanned)
                  Positioned.fill(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ScanOverlayPainter(),
                    ),
                  ),
              ],
            ),
          ),

          // Boutons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (!_hasScanned) ...[
                  Text(
                    'Positionnez le QR Code dans le cadre',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed:
                        () => context.go(
                          '/partner/manual-code',
                          extra: widget.order,
                        ),
                    child: Text(
                      'Saisir le code manuellement',
                      style: GoogleFonts.poppins(
                        color: AppColors.blueBic,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ] else ...[
                  // Bouton re-scanner
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Scanner un autre',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (_isValid) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            () => context.go(
                              '/partner/pickup-validated',
                              extra:
                                  _validatedOrder.isEmpty
                                      ? widget.order
                                      : _validatedOrder,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueBic,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Voir la confirmation',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraError(MobileScannerException error) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Caméra indisponible',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Autorisez l’accès caméra pour scanner les QR codes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isValid ? Icons.check_circle : Icons.cancel,
          size: 80,
          color: _isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          _isValid ? 'Validé!' : 'Erreur',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isValid ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _validationMessage,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        if (_isValid) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _scannedData,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }

  _PickupPayload _parsePickupPayload(String data) {
    final normalized = data.trim();
    final parts = normalized.split('|');
    if (parts.length >= 2) {
      return _PickupPayload(orderId: parts[0], pickupCode: parts[1]);
    }
    final uri = Uri.tryParse(normalized);
    if (uri != null) {
      final orderId = uri.queryParameters['orderId'];
      final pickupCode = uri.queryParameters['pickupCode'];
      if (orderId != null && pickupCode != null) {
        return _PickupPayload(orderId: orderId, pickupCode: pickupCode);
      }
    }
    throw FormatException('invalid_pickup_payload');
  }
}

class _PickupPayload {
  const _PickupPayload({required this.orderId, required this.pickupCode});

  final String orderId;
  final String pickupCode;
}

/// Painter pour le overlay de scan
class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerSize = 40.0;
    final strokeWidth = 4.0;
    final cornerPaint =
        Paint()
          ..color = AppColors.blueBic.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    // Zone de scan au centre
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Dessine les coins
    // Coin haut-gauche
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top + cornerSize),
      Offset(scanRect.left, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top),
      Offset(scanRect.left + cornerSize, scanRect.top),
      cornerPaint,
    );

    // Coin haut-droit
    canvas.drawLine(
      Offset(scanRect.right - cornerSize, scanRect.top),
      Offset(scanRect.right, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.top),
      Offset(scanRect.right, scanRect.top + cornerSize),
      cornerPaint,
    );

    // Coin bas-droit
    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom - cornerSize),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom),
      Offset(scanRect.right - cornerSize, scanRect.bottom),
      cornerPaint,
    );

    // Coin bas-gauche
    canvas.drawLine(
      Offset(scanRect.left + cornerSize, scanRect.bottom),
      Offset(scanRect.left, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom),
      Offset(scanRect.left, scanRect.bottom - cornerSize),
      cornerPaint,
    );

    // Ligne de scan animée (simulée)
    final lineY =
        scanRect.top +
        50 +
        (DateTime.now().millisecond % 2000) / 2000 * (scanRect.height - 100);
    canvas.drawLine(
      Offset(scanRect.left + 10, lineY),
      Offset(scanRect.right - 10, lineY),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
