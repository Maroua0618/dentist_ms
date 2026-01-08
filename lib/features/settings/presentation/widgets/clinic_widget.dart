import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

// class to hold all the controllers
class ClinicControllers {
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final Map<String, List<TextEditingController>> workingHoursControllers = {};

  // Method to update controllers with data
  void updateControllersFromClinicData({
    String? clinicName,
    String? registrationNumber,
    String? email,
    String? phone,
    String? address,
    String? about,
    Map<String, List<String>>? workingHours,
  }) {
    // Remove the _initialized check to allow updates
    if (clinicName != null) {
      clinicNameController.text = clinicName;
    }
    if (registrationNumber != null) {
      registrationNumberController.text = registrationNumber;
    }
    if (email != null) {
      emailController.text = email;
    }
    if (phone != null) {
      phoneController.text = phone;
    }
    if (address != null) {
      addressController.text = address;
    }
    if (about != null) {
      aboutController.text = about;
    }
    // Initialize working hours controllers with data if provided
    if (workingHours != null) {
      workingHours.forEach((day, times) {
        if (workingHoursControllers.containsKey(day)) {
          if (times.length >= 2) {
            workingHoursControllers[day]![0].text = times[0];
            workingHoursControllers[day]![1].text = times[1];
          }
        }
      });
    }
  }

  void dispose() {
    clinicNameController.dispose();
    registrationNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    aboutController.dispose();

    // Dispose working hours controllers
    workingHoursControllers.forEach((key, controllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    });
  }
}

// widget to display informations
Widget clinic(
  BuildContext context,
  double width,
  double height,
  ClinicControllers controllers,
) {
  List<String> daysList = [
    "Samedi",
    "Dimanche",
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
  ];

  // Initialize working hours controllers if not already done
  if (controllers.workingHoursControllers.isEmpty) {
    for (var day in daysList) {
      controllers.workingHoursControllers[day] = [
        TextEditingController(),
        TextEditingController(),
      ];
    }

    // You can call this method to populate with initial data
    // For example, from your database or default values:
    controllers.updateControllersFromClinicData(
      clinicName: 'Nom de la clinique par défaut',
      registrationNumber: '12345',
      email: 'clinique@example.com',
      phone: '+1234567890',
      address: 'Adresse par défaut',
      about: 'Description de la clinique',
      workingHours: {
        'Lundi': ['08:00', '17:00'],
        'Mardi': ['08:00', '17:00'],
        'Mercredi': ['08:00', '17:00'],
        'Jeudi': ['08:00', '17:00'],
        'Vendredi': ['08:00', '17:00'],
        'Samedi': ['09:00', '13:00'],
        'Dimanche': ['Fermé', 'Fermé'],
      },
    );
  }

  return Card(
    color: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.03,
          horizontal: width * 0.04,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  "Informations sur la clinique",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Divider(color: Colors.grey.shade300, thickness: 1),
            SizedBox(height: height * 0.04),

            // Responsive Row for clinic name and registration number
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Vertical layout for small screens
                  return Column(
                    children: [
                      _buildFieldVertical(
                        context,
                        'Nom de la clinique',
                        controllers.clinicNameController,
                        height,
                        keyboardType: TextInputType.text,
                        icon: Icons.business_center,
                      ),
                      SizedBox(height: height * 0.03),
                      _buildFieldVertical(
                        context,
                        "Numéro d'enregistrement",
                        controllers.registrationNumberController,
                        height,
                        keyboardType: TextInputType.number,
                        icon: Icons.confirmation_number,
                      ),
                    ],
                  );
                } else {
                  // Horizontal layout for larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFieldHorizontal(
                          context,
                          'Nom de la clinique',
                          controllers.clinicNameController,
                          height,
                          icon: Icons.business_center,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: _buildFieldHorizontal(
                          context,
                          "Numéro d'enregistrement",
                          controllers.registrationNumberController,
                          height,
                          keyboardType: TextInputType.number,
                          icon: Icons.confirmation_number,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            SizedBox(height: height * 0.03),

            // Responsive Row for email and phone
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Vertical layout for small screens
                  return Column(
                    children: [
                      _buildFieldVertical(
                        context,
                        'Email',
                        controllers.emailController,
                        height,
                        keyboardType: TextInputType.text,
                        icon: Icons.email,
                      ),
                      SizedBox(height: height * 0.03),
                      _buildFieldVertical(
                        context,
                        'Téléphone',
                        controllers.phoneController,
                        height,
                        keyboardType: TextInputType.number,
                        icon: Icons.phone,
                      ),
                    ],
                  );
                } else {
                  // Horizontal layout for larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFieldHorizontal(
                          context,
                          'Email',
                          controllers.emailController,
                          height,
                          icon: Icons.email,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: _buildFieldHorizontal(
                          context,
                          'Téléphone',
                          controllers.phoneController,
                          height,
                          keyboardType: TextInputType.number,
                          icon: Icons.phone,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            SizedBox(height: height * 0.03),

            // Address field (always full width)
            _buildFullWidthField(
              context,
              'Address',
              controllers.addressController,
              height * 0.08,
              height,
              icon: Icons.location_on,
            ),

            SizedBox(height: height * 0.03),

            // About field (always full width)
            _buildFullWidthField(
              context,
              'À propos de la clinique',
              controllers.aboutController,
              height * 0.18,
              height,
              maxLines: 5,
              icon: Icons.info,
            ),

            SizedBox(height: height * 0.06),

            // Save button (always full width)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // You can access the values like this:
                  print(
                    'Clinic Name: ${controllers.clinicNameController.text}',
                  );
                  print('Email: ${controllers.emailController.text}');
                  print('Phone: ${controllers.phoneController.text}');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: height * 0.025),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "Enregistrer les modifications",
                  style: AppTextStyles.bodyWhite.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper methods for building responsive fields
Widget _buildFieldHorizontal(
  BuildContext context,
  String label,
  TextEditingController controller,
  double height, {
  TextInputType keyboardType = TextInputType.text,
  IconData? icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.subtitle1.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      SizedBox(height: height * 0.015),
      SizedBox(
        height: height * 0.08,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(icon, color: Theme.of(context).primaryColor)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}

Widget _buildFieldVertical(
  BuildContext context,
  String label,
  TextEditingController controller,
  double height, {
  TextInputType keyboardType = TextInputType.text,
  IconData? icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.subtitle1.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      SizedBox(height: height * 0.015),
      SizedBox(
        height: height * 0.08,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(icon, color: Theme.of(context).primaryColor)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}

Widget _buildFullWidthField(
  BuildContext context,
  String label,
  TextEditingController controller,
  double fieldHeight,
  double screenHeight, {
  int maxLines = 1,
  IconData? icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.subtitle1.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      SizedBox(height: screenHeight * 0.015),
      SizedBox(
        height: fieldHeight,
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(icon, color: Theme.of(context).primaryColor)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}
