import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_event.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/recognized.dart';
import 'package:dentist_ms/features/auth/presentation/widgets/scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _showScanningDialog = false;
  bool _showRecognizedDialog = false;

  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Error messages
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
    _resetEmailController.dispose();
    super.dispose();
  }

  void _startFacialRecognition() {
    setState(() => _showScanningDialog = true);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showScanningDialog = false;
          _showRecognizedDialog = true;
        });
      }
    });
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

    final email = _emailController.text. trim();
    final password = _passwordController.text.trim();

    // Validate fields
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
      setState(() => _passwordError = 'Le mot de passe doit contenir au moins 6 caractères');
      hasError = true;
    }

    if (hasError) return;

    // Dispatch sign in event
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
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
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
    String? resetEmailError;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2530),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Réinitialiser le mot de passe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entrez votre email pour recevoir un lien de réinitialisation',
                style: TextStyle(
                  color: Colors.white. withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _resetEmailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'votre. email@example.com',
                  hintStyle: TextStyle(color: Colors.white. withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF2A3441),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.white. withOpacity(0.5),
                  ),
                  errorText: resetEmailError,
                  errorStyle: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide. none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: resetEmailError != null 
                          ? const Color(0xFFDC2626) 
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:  resetEmailError != null 
                          ? const Color(0xFFDC2626) 
                          : const Color(0xFF4F7EFF),
                      width:  2,
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (resetEmailError != null) {
                    setDialogState(() => resetEmailError = null);
                  }
                },
              ),
            ],
          ),
          actions:  [
            TextButton(
              onPressed: () {
                _resetEmailController.clear();
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.white. withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final email = _resetEmailController.text.trim();
                
                if (email.isEmpty) {
                  setDialogState(() => resetEmailError = 'Veuillez entrer votre email');
                  return;
                }
                if (!_isValidEmail(email)) {
                  setDialogState(() => resetEmailError = 'Email invalide');
                  return;
                }

                context.read<AuthBloc>().add(AuthResetPasswordRequested(email));
                Navigator.pop(dialogContext);
                _resetEmailController.clear();
                _showSuccessSnackBar(
                    'Email de réinitialisation envoyé !  Vérifiez votre boîte de réception.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7EFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboardShell);
        } else if (state.status == AuthStatus.error) {
          // Parse error and set appropriate field error
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
              child:  isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 5, child: _buildLeftSection()),
                        Expanded(flex: 4, child: _buildRightSection()),
                      ],
                    )
                  : _buildRightSection(),
            ),

            // Scanning Dialog
            if (_showScanningDialog)
              FaceScanningOverlay(
                onClose: () => setState(() => _showScanningDialog = false),
              ),

            // Recognized Dialog
            if (_showRecognizedDialog)
              FaceRecognitionOverlay(
                onClose:  () {
                  setState(() => _showRecognizedDialog = false);
                },
                onContinue: () {
                  setState(() => _showRecognizedDialog = false);
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.dashboardShell);
                },
                onTryAgain: () {
                  setState(() {
                    _showRecognizedDialog = false;
                    _showScanningDialog = true;
                  });
                },
              ),

            // Loading Overlay
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus. loading) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment:  MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F7EFF),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Connexion en cours...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox. shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              const SizedBox(height: 20),
              // Logo
              Row(
                children: [
                  Container(
                    decoration: AppColors.selectedPage. copyWith(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/icons/pfp.svg",
                      width: 35,
                      height: 35,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Khelil's dental center",
                    style: TextStyle(
                      color: Colors. white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Heading
              const Text(
                'Next-Generation Dental\nPractice Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              // Description
              const Text(
                'Streamline your practice with AI-powered patient management,\nseamless scheduling, and advanced analytics.',
                style: TextStyle(
                  color: Colors. white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // Feature Cards
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: "assets/icons/security.svg",
                      title: 'Secure',
                      subtitle: 'HIPAA Compliant',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: "assets/icons/flash.svg",
                      title: 'Fast',
                      subtitle: 'Cloud-Based',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/security.svg",
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF00B8DB),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Protected by enterprise-grade encryption',
                    style: TextStyle(
                      color: Colors. white. withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white. withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width:  28,
            height: 28,
            colorFilter: const ColorFilter.mode(
              Color(0xFF00B8DB),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors. white. withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2530),
            borderRadius:  BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabBar(),
              const SizedBox(height: 24),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children:  [_buildFacialRecognitionTab(), _buildPasswordTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3441),
        borderRadius:  BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 40,
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius:  BorderRadius.circular(10),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors. white.withOpacity(0.5),
          onTap: (_) => _clearErrors(), // Clear errors when switching tabs
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/facial.svg",
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Face ID',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/lock.svg",
                    width: 16,
                    height:  16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacialRecognitionTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:  [
        Column(
          children: [
            const Text(
              'Connexion sécurisée',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez la reconnaissance faciale pour un accès\ninstantané et sécurisé',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4F7EFF).withOpacity(0.2),
                const Color(0xFF9D6CFF).withOpacity(0.2),
              ],
              begin:  Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4F7EFF), width: 3),
              ),
              child:  const Center(
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  size: 45,
                  color: Color(0xFF4F7EFF),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildGradientButton(
          text: 'Démarrer la reconnaissance faciale',
          onPressed: _startFacialRecognition,
        ),
      ],
    );
  }

  Widget _buildPasswordTab() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
            style: TextStyle(fontSize: 13, color: Colors. white.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height:  24),

          // General error message
          if (_generalError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration:  BoxDecoration(
                color:  const Color(0xFFDC2626).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFDC2626).withOpacity(0.3),
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
                      _generalError! ,
                      style: const TextStyle(
                        color:  Color(0xFFDC2626),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberForgot(),
          const Spacer(),
          _buildGradientButton(
            text:  'Se connecter',
            onPressed:  _handleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color:  Colors.white, fontSize: 14),
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          decoration:  InputDecoration(
            prefixIcon: Icon(
              Icons.email_outlined,
              color: _emailError != null 
                  ? const Color(0xFFDC2626) 
                  : Colors.white.withOpacity(0.5),
              size: 18,
            ),
            hintText: 'dr. smith@dentalai.com',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF2A3441),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius. circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:  BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null 
                    ? const Color(0xFFDC2626) 
                    : Colors.white. withOpacity(0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:  BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null 
                    ? const Color(0xFFDC2626) 
                    : const Color(0xFF4F7EFF),
                width: 2,
              ),
            ),
          ),
        ),
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color:  Color(0xFFDC2626),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _emailError! ,
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
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: _passwordError != null 
                  ? const Color(0xFFDC2626) 
                  : Colors.white.withOpacity(0.5),
              size: 18,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.5),
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
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF2A3441),
            contentPadding: const EdgeInsets. symmetric(
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
                color: _passwordError != null 
                    ? const Color(0xFFDC2626) 
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius. circular(12),
              borderSide: BorderSide(
                color: _passwordError != null 
                    ? const Color(0xFFDC2626) 
                    : const Color(0xFF4F7EFF),
                width: 2,
              ),
            ),
          ),
        ),
        if (_passwordError != null)
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
                  _passwordError!,
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
      children:  [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child:  Checkbox(
                value: rememberMe,
                onChanged: (val) {
                  setState(() => rememberMe = val ??  false);
                },
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4F7EFF);
                  }
                  return Colors.transparent;
                }),
                side: BorderSide(color: Colors.white. withOpacity(0.3)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Souviens-toi de moi',
              style: TextStyle(
                color: Colors. white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _showResetPasswordDialog,
          style: TextButton. styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size. zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Mot de passe oublié? ',
            style: TextStyle(color: Color(0xFF4F7EFF), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius:  BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child:  Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}