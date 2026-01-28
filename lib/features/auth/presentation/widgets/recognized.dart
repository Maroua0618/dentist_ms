import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dentist_ms/core/models/app_user.dart';

/// Dialog widget for Face Recognition success or failure
class FaceRecognitionOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onContinue;
  final VoidCallback? onTryAgain;
  final AppUser? recognizedUser;
  final double? confidence;
  final bool isSuccess;
  final String? errorMessage;

  const FaceRecognitionOverlay({
    super.key,
    required this.onClose,
    this.onContinue,
    this.onTryAgain,
    this.recognizedUser,
    this.confidence,
    this.isSuccess = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Dimmed Background with Blur
        GestureDetector(
          onTap: onClose,
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
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                      child: Column(
                        children: [
                          _buildStatusIcon(),
                          const SizedBox(height: 20),
                          if (isSuccess) ...[
                            _buildProfileSection(),
                            const SizedBox(height: 16),
                            _buildUserInfo(),
                            const SizedBox(height: 16),
                            _buildConfidenceBadge(),
                          ] else ...[
                            _buildErrorMessage(),
                          ],
                          const SizedBox(height: 24),
                          _buildActionButtons(),
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
          colors: isSuccess
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
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
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isSuccess ? 'Reconnaisance Réussie' : 'Échec',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSuccess
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFFEF4444).withValues(alpha: 0.2),
            ),
            child: Icon(
              isSuccess ? Icons.face : Icons.face_retouching_off,
              size: 50,
              color: isSuccess
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection() {
    if (recognizedUser == null) return const SizedBox.shrink();

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade800,
          backgroundImage: recognizedUser!.profileImageUrl != null
              ? NetworkImage(recognizedUser!.profileImageUrl!)
              : null,
          child: recognizedUser!.profileImageUrl == null
              ? Text(
                  recognizedUser!.firstName[0] + recognizedUser!.lastName[0],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    if (recognizedUser == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          '${recognizedUser!.firstName} ${recognizedUser!.lastName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            recognizedUser!.role.toString().split('.').last.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBadge() {
    if (confidence == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            'Confiance: ${(confidence! * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Column(
      children: [
        Text(
          errorMessage ?? 'Visage non reconnu',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Veuillez réessayer ou utiliser une autre méthode de connexion.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (isSuccess) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continuer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTryAgain,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Réessayer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
