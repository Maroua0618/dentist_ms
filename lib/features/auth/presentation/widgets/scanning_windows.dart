import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Windows-compatible mock face scanning widget for testing
class FaceScanningOverlayWindows extends StatefulWidget {
  final VoidCallback onClose;
  final Function(List<double> faceEmbedding, double confidence)
  onFaceRecognized;

  const FaceScanningOverlayWindows({
    super.key,
    required this.onClose,
    required this.onFaceRecognized,
  });

  @override
  State<FaceScanningOverlayWindows> createState() =>
      _FaceScanningOverlayWindowsState();
}

class _FaceScanningOverlayWindowsState extends State<FaceScanningOverlayWindows>
    with TickerProviderStateMixin {
  String _statusMessage = 'Initialisation...';
  Color _statusColor = Colors.blue;
  int _scanProgress = 0;

  late AnimationController _pulseController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startMockScan();
  }

  Future<void> _startMockScan() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 1: Face detection
    setState(() {
      _statusMessage = 'Visage détecté';
      _statusColor = Colors.green;
      _scanProgress = 1;
    });
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 2: Blink detection
    setState(() {
      _statusMessage = 'Clignez des yeux';
      _statusColor = Colors.blue;
      _scanProgress = 1;
    });
    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _statusMessage = 'Clignement détecté ✓';
      _statusColor = Colors.green;
      _scanProgress = 2;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 3: Head turn
    setState(() {
      _statusMessage = 'Tournez la tête à gauche';
      _statusColor = Colors.blue;
      _scanProgress = 2;
    });
    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _statusMessage = 'Mouvement détecté ✓';
      _statusColor = Colors.green;
      _scanProgress = 3;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 4: Analyzing
    setState(() {
      _statusMessage = 'Analyse du visage...';
      _statusColor = Colors.blue;
    });
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 5: Success
    setState(() {
      _statusMessage = 'Visage reconnu ✓';
      _statusColor = Colors.green;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock embedding (512 dimensions)
    final mockEmbedding = List.generate(512, (i) => math.Random().nextDouble());
    widget.onFaceRecognized(mockEmbedding, 0.95);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Dimmed Background
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withValues(alpha: 0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Dialog Content
        Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
                      child: Column(
                        children: [
                          _buildMockCamera(),
                          const SizedBox(height: 24),
                          _buildStatusIndicator(),
                          const SizedBox(height: 16),
                          _buildChallengeProgress(),
                          const SizedBox(height: 16),
                          _buildWindowsNotice(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.face, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Reconnaissance Faciale (Demo)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMockCamera() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 350,
        color: const Color(0xFF0F172B),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    const Color(0xFF0F172B),
                  ],
                ),
              ),
            ),

            // Mock face oval
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200 + (_pulseController.value * 10),
                    height: 260 + (_pulseController.value * 13),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _statusColor.withValues(
                          alpha: 0.5 + (_pulseController.value * 0.3),
                        ),
                        width: 3,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Scanning line
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Positioned(
                  top: _scanController.value * 350,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Face icon
            Center(
              child: Icon(
                Icons.face,
                size: 120,
                color: _statusColor.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _statusColor == Colors.green ? Icons.check_circle : Icons.info,
            color: _statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isPassed = index < _scanProgress;
        final isCurrent = index == _scanProgress && _scanProgress < 3;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: isPassed
                ? Colors.green
                : isCurrent
                ? Colors.blue
                : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildWindowsNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode démo Windows - Utilisez un appareil mobile pour la vraie reconnaissance faciale',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
