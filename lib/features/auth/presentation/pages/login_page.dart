import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_event.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/login_facial_tab.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/login_left_section.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/login_password_form.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/login_tab_bar.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/reset_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboardShell);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172B),
                    Color(0xFF1D293D),
                    Color(0xFF0F172B),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: isDesktop
                  ? const Row(
                      children: [
                        Expanded(flex: 5, child: LoginLeftSection()),
                        Expanded(flex: 4, child: _RightSection()),
                      ],
                    )
                  : const _RightSection(),
            ),

            // Loading Overlay
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.loading) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F7EFF),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Connexion en cours...',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RightSection extends StatefulWidget {
  const _RightSection();

  @override
  State<_RightSection> createState() => _RightSectionState();
}

class _RightSectionState extends State<_RightSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
  }

  void _handleSignIn() {
    _clearErrors();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool hasError = false;

    if (email.isEmpty) {
      setState(() => _emailError = 'Veuillez entrer votre email');
      hasError = true;
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Adresse email invalide');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Veuillez entrer votre mot de passe');
      hasError = true;
    } else if (password.length < 6) {
      setState(
        () => _passwordError =
            'Le mot de passe doit contenir au moins 6 caractères',
      );
      hasError = true;
    }

    if (hasError) return;

    context.read<AuthBloc>().add(AuthSignInRequested(email, password));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ResetPasswordDialog(
        onResetPassword: (email) {
          context.read<AuthBloc>().add(AuthResetPasswordRequested(email));
          _showSuccessSnackBar(
            'Email de réinitialisation envoyé ! Vérifiez votre boîte de réception.',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          final errorMsg = state.errorMessage ?? 'Erreur de connexion';

          setState(() {
            if (errorMsg.toLowerCase().contains('email') ||
                errorMsg.toLowerCase().contains('user') ||
                errorMsg.toLowerCase().contains('not found')) {
              _emailError = 'Email non trouvé';
              _generalError = null;
            } else if (errorMsg.toLowerCase().contains('password') ||
                errorMsg.toLowerCase().contains('invalid')) {
              _passwordError = 'Mot de passe incorrect';
              _generalError = null;
            } else {
              _generalError = errorMsg;
            }
          });
        }
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2530),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoginTabBar(
                  controller: _tabController,
                  onTabChange: _clearErrors,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const LoginFacialTab(),
                      LoginPasswordForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailError: _emailError,
                        passwordError: _passwordError,
                        generalError: _generalError,
                        onEmailChanged: () {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                        onPasswordChanged: () {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                        onSignIn: _handleSignIn,
                        onForgotPassword: _showResetPasswordDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
