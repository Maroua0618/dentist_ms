import 'package:dentist_ms/features/settings/models/clinicInfo.dart';
import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

Widget clinic(BuildContext context, double width, double height, ClinicControllers clinicControllers) {  

  final clinicInfo = ClinicInfo.defaultValues();
  final controllers = clinicInfo.toControllers();
  
  final readOnlyFields = {
    'clinicName': true,           
    'registrationNumber': true,   
    'email': true,               
    'phone': true,               
    'address': true,             
    'about': true,             
  };
      
  return Column(
    children: [
      Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Informations sur la clinique",
                style: Theme.of(context).textTheme.titleLarge!,
              ),
              SizedBox(height: height * 0.03),
              
              // Responsive Row for clinic name and registration number
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Vertical layout for small screens
                    return Column(
                      children: [
                        _buildFieldVertical(
                          'Nom de la clinique', 
                          controllers['clinicName']!, 
                          height, 
                          readOnlyFields['clinicName']!,
                        ),
                        SizedBox(height: height * 0.02),
                        _buildFieldVertical(
                          "Numéro d'enregistrement", 
                          controllers['registrationNumber']!, 
                          height, 
                          readOnlyFields['registrationNumber']!,
                          TextInputType.number,
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
                            'Nom de la clinique', 
                            controllers['clinicName']!, 
                            height, 
                            readOnlyFields['clinicName']!,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: _buildFieldHorizontal(
                            "Numéro d'enregistrement", 
                            controllers['registrationNumber']!, 
                            height, 
                            readOnlyFields['registrationNumber']!,
                            TextInputType.number,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              
              SizedBox(height: height * 0.02),
              
              // Responsive Row for email and phone
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Vertical layout for small screens
                    return Column(
                      children: [
                        _buildFieldVertical(
                          'Email', 
                          controllers['email']!, 
                          height, 
                          readOnlyFields['email']!,
                          TextInputType.emailAddress,
                        ),
                        SizedBox(height: height * 0.02),
                        _buildFieldVertical(
                          'Téléphone', 
                          controllers['phone']!, 
                          height, 
                          readOnlyFields['phone']!,
                          TextInputType.phone,
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
                            'Email', 
                            controllers['email']!, 
                            height, 
                            readOnlyFields['email']!,
                            TextInputType.emailAddress,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: _buildFieldHorizontal(
                            'Téléphone', 
                            controllers['phone']!, 
                            height, 
                            readOnlyFields['phone']!,
                            TextInputType.phone,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              
              SizedBox(height: height * 0.02),
              
              // Address field (always full width)
              _buildFullWidthField(
                'Adresse', 
                controllers['address']!, 
                height * 0.065, 
                height, 
                readOnlyFields['address']!,
              ),
              
              SizedBox(height: height * 0.02),
              
              // About field (always full width)
              _buildFullWidthField(
                'À propos de la clinique', 
                controllers['about']!, 
                height * 0.15, 
                height, 
                readOnlyFields['about']!,
                maxLines: 5,
              ),
              
              SizedBox(height: height * 0.04),
              
              // Save button (always full width) - Only show if some fields are editable
              if (readOnlyFields.containsValue(false)) // Only show if there are editable fields
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic here
                      final updatedClinicInfo = ClinicInfo(
                        clinicName: controllers['clinicName']!.text,
                        registrationNumber: controllers['registrationNumber']!.text,
                        email: controllers['email']!.text,
                        phone: controllers['phone']!.text,
                        address: controllers['address']!.text,
                        about: controllers['about']!.text,
                      );
                      
                      // You can do something with updatedClinicInfo
                      print('Saved: $updatedClinicInfo');
                    }, 
                    child: Text("Enregistrer les modifications"),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

class ClinicControllers {
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
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

Widget _buildFieldHorizontal(
  String label, 
  TextEditingController controller, 
  double height, 
  bool isReadOnly,
  [TextInputType keyboardType = TextInputType.text]
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: height * 0.01),
      SizedBox(
        height: height * 0.065,
        child: TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(          
            filled: isReadOnly,
            fillColor: Colors.grey[100],
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    ],
  );
}
Widget _buildFieldVertical(
  String label, 
  TextEditingController controller, 
  double height, 
  bool isReadOnly,
  [TextInputType keyboardType = TextInputType.text]
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: height * 0.01),
      SizedBox(
        height: height * 0.065,
        child: TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: isReadOnly,
            fillColor: Colors.grey[100],
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    ],
  );
}
Widget _buildFullWidthField(
  String label, 
  TextEditingController controller, 
  double fieldHeight, 
  double screenHeight, 
  bool isReadOnly,
  {int maxLines = 1}
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: screenHeight * 0.01),
      SizedBox(
        height: fieldHeight,
        child: TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: isReadOnly,
            fillColor: Colors.grey[100],
          ),
        ),
      ),
    ],
  );
}
