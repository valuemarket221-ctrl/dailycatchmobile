import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Écran de scan QR Code pour les partenaires
/// Permet aux partenaires de scanner le QR code du client pour valider la récupération
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _hasScanned = false;
  String _scannedData = '';
  bool _isValid = false;
  String _validationMessage = '';

  // Simulation de validation
  Future<void> _validateQRCode(String data) async {
    setState(() {
      _scannedData = data;
      _hasScanned = true;
    });

    // Simulation de validation
    await Future.delayed(const Duration(seconds: 1));

    // Vérifie le format du QR code
    if (data.startsWith('RES') && data.contains('DailyCatch')) {
      setState(() {
        _isValid = true;
        _validationMessage = 'Réservation validée avec succès!';
      });
    } else {
      setState(() {
        _isValid = false;
        _validationMessage = 'QR code invalide ou expiré';
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _scannedData = '';
      _isValid = false;
      _validationMessage = '';
    });
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
          IconButton(icon: const Icon(Icons.flashlight_on), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.blueBic.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.blueBic),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scannez le QR Code du client pour valider la récupération du produit',
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
                // Zone de scan simulée
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
                            : _buildScanPlaceholder(),
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
                  // Bouton scanner simulation
                  ElevatedButton.icon(
                    onPressed: () {
                      // Simule un scan
                      _validateQRCode('RES001|DailyCatch|4.50');
                    },
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.black,
                    ),
                    label: Text(
                      'Simuler un scan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellowColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Positionnez le QR Code dans le cadre',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_2,
          size: 80,
          color: AppColors.blueBic.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Icon(
          Icons.center_focus_strong,
          size: 40,
          color: AppColors.blueBic.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blueBic,
          ),
        ),
      ],
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
