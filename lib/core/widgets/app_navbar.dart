import 'dart:typed_data';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_event.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:dentist_ms/features/settings/bloc/clinic_info_cubit.dart';
import 'package:dentist_ms/features/settings/bloc/clinic_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AppNavbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int patientsN;
  final int appointmentsN;
  final int billingsN;

  const AppNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.appointmentsN,
    required this.billingsN,
    required this.patientsN,
  });

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  bool _isCollapsed = false;
  final Map<String, Uint8List> _imageCache = {};

  /// Load profile image from Supabase Storage
  Future<Uint8List?> _loadProfileImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    // Check cache first
    if (_imageCache.containsKey(imageUrl)) {
      return _imageCache[imageUrl];
    }

    try {
      // Download image bytes from Supabase Storage
      final response = await Supabase.instance.client.storage
          .from('profile-images')
          .download(imageUrl);

      // Cache the image
      _imageCache[imageUrl] = response;
      return response;
    } catch (e) {
      print('Error loading profile image in navbar: $e');
      return null;
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2530),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ? ',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthSignOutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String title,
    String iconPath,
    int index, {
    String counter = "0",
  }) {
    final selected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: selected ? AppColors.selectedPage : null,
        child: ClipRect(
          child: Row(
            mainAxisAlignment: _isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                color: selected ? Colors.white : null,
              ),
              if (!_isCollapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1),
                    opacity: _isCollapsed ? 0.0 : 1.0,
                    child: Text(
                      title,
                      style: AppTextStyles.body1.copyWith(
                        color: selected ? Colors.white : null,
                      ),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                ),
                if (counter != "0")
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 1),
                    opacity: _isCollapsed ? 0.0 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected ? Colors.white : AppColors.azure,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        counter,
                        style: AppTextStyles.body1.copyWith(
                          color: selected ? Colors.white : AppColors.azure_2,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSettingsButton(AuthState authState) {
    final user = authState.user;
    final selected = widget.selectedIndex == 4;

    if (!authState.isAuthenticated || user == null) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => widget.onItemSelected(4),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _isCollapsed ? 12 : 16,
        ),
        decoration: selected
            ? BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.cardBlue),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: ClipRect(
          child: Row(
            mainAxisAlignment: _isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              // Avatar with profile image
              FutureBuilder<Uint8List?>(
                future: _loadProfileImage(user.profileImageUrl),
                builder: (context, snapshot) {
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF4F7EFF),
                    backgroundImage: snapshot.hasData && snapshot.data != null
                        ? MemoryImage(snapshot.data!)
                        : null,
                    child: snapshot.hasData && snapshot.data != null
                        ? null
                        : Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  );
                },
              ),

              if (!_isCollapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1),
                    opacity: _isCollapsed ? 0.0 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: AppTextStyles.body1.copyWith(
                            color: selected ? Colors.white : null,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                        Text(
                          user.role.name.toUpperCase(),
                          style: TextStyle(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout icon button
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  onPressed: _showSignOutDialog,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Déconnexion',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double expandedWidth;
    if (screenWidth >= 1400) {
      expandedWidth = 260;
    } else if (screenWidth >= 1200) {
      expandedWidth = 230;
    } else if (screenWidth >= 1000) {
      expandedWidth = 200;
    } else if (screenWidth >= 800) {
      expandedWidth = 180;
    } else {
      expandedWidth = 150;
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final List<Map<String, String>> navItems = [
          {"title": "Tableau de bord", "icon": "assets/icons/dashboard.svg"},
          {
            "title": "Patientes",
            "icon": "assets/icons/patients.svg",
            "counter": widget.patientsN.toString(),
          },
          {
            "title": "Rendez-vous",
            "icon": "assets/icons/appointments.svg",
            "counter": widget.appointmentsN.toString(),
          },
          {
            "title": "Facturation",
            "icon": "assets/icons/billing.svg",
            "counter": widget.billingsN.toString(),
          },
        ];

        final clinicCubit = context.read<ClinicInfoCubit?>();

        Widget buildShell(String clinicName) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _isCollapsed ? 80 : expandedWidth,
            decoration: AppColors.navBarBackground,
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: _isCollapsed
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: AppColors.azure_2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRect(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isCollapsed) ...[
                            Container(
                              decoration: AppColors.selectedPage.copyWith(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: SvgPicture.asset(
                                "assets/images/dms.svg",
                                width: 35,
                                height: 35,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 1),
                                opacity: _isCollapsed ? 0.0 : 1.0,
                                child: ClipRect(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clinicName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Clinic Management',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Container(
                            decoration: _isCollapsed
                                ? BoxDecoration(
                                    border: Border.all(color: AppColors.azure),
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                : null,
                            child: IconButton(
                              icon: AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: _isCollapsed ? 0.5 : 0,
                                child: const Icon(
                                  Icons.chevron_left,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isCollapsed = !_isCollapsed;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        ...List.generate(
                          navItems.length,
                          (index) => _buildNavItem(
                            navItems[index]["title"]!,
                            navItems[index]["icon"]!,
                            index,
                            counter: navItems[index]["counter"] ?? "0",
                          ),
                        ),
                        const Spacer(),

                        // Profile/Settings button at bottom
                        _buildProfileSettingsButton(authState),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (clinicCubit == null) {
          return buildShell('Dental clinic');
        }

        return BlocBuilder<ClinicInfoCubit, ClinicInfoState>(
          bloc: clinicCubit,
          builder: (context, clinicState) {
            final clinicName = clinicState.clinicInfo.clinicName.isEmpty
                ? 'Dental clinic'
                : clinicState.clinicInfo.clinicName;
            return buildShell(clinicName);
          },
        );
      },
    );
  }
}
