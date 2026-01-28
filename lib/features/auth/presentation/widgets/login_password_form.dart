import 'package:dentist_ms/features/auth/presentation/widgets/login_gradient_button.dart';
import 'package:flutter/material.dart';

class LoginPasswordForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onSignIn;
  final VoidCallback onForgotPassword;

  const LoginPasswordForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.emailError,
    this.passwordError,
    this.generalError,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSignIn,
    required this.onForgotPassword,
  });

  @override
  State<LoginPasswordForm> createState() => _LoginPasswordFormState();
}

class _LoginPasswordFormState extends State<LoginPasswordForm> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Icon(Icons.lock_outline, size: 40, color: Color(0xFF00B8DB)),
            const SizedBox(height: 8),
            const Text(
              'Content de te revoir',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saisissez vos identifiants pour accéder à votre compte',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        // General error message
        if (widget.generalError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.generalError!,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Column(
          children: [
            _buildEmailField(),
            const SizedBox(height: 30),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildRememberForgot(),
          ],
        ),

        LoginGradientButton(text: 'Se connecter', onPressed: widget.onSignIn),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (_) => widget.onEmailChanged(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email_outlined,
              color: widget.emailError != null
                  ? const Color(0xFFDC2626)
                  : Colors.white.withValues(alpha: 0.5),
              size: 18,
            ),
            hintText: 'dr. smith@dentalai.com',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF2A3441),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.emailError != null
                    ? const Color(0xFFDC2626)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.emailError != null
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF4F7EFF),
                width: 2,
              ),
            ),
          ),
        ),
        if (widget.emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.emailError!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (_) => widget.onPasswordChanged(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: widget.passwordError != null
                  ? const Color(0xFFDC2626)
                  : Colors.white.withValues(alpha: 0.5),
              size: 18,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            hintText: 'Mot de passe',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF2A3441),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.passwordError != null
                    ? const Color(0xFFDC2626)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.passwordError != null
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF4F7EFF),
                width: 2,
              ),
            ),
          ),
        ),
        if (widget.passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.passwordError!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) {
                  setState(() => _rememberMe = val ?? false);
                },
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4F7EFF);
                  }
                  return Colors.transparent;
                }),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Souviens-toi de moi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: widget.onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Mot de passe oublié?',
            style: TextStyle(color: Color(0xFF4F7EFF), fontSize: 12),
          ),
        ),
      ],
    );
  }
}
