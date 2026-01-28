library;

/// Integration Test Keys
///
/// Centralized key definitions for reliable widget finding in integration tests.
/// These keys should be added to the actual app widgets for testing.

class TestKeys {
  // ============ Authentication Keys ============
  static const String loginEmailField = 'login_email_field';
  static const String loginPasswordField = 'login_password_field';
  static const String loginSubmitButton = 'login_submit_button';
  static const String loginTabBar = 'login_tab_bar';
  static const String loginPasswordTab = 'login_password_tab';
  static const String loginFacialTab = 'login_facial_tab';
  static const String logoutButton = 'logout_button';
  static const String forgotPasswordButton = 'forgot_password_button';

  // ============ Navigation Keys ============
  static const String navDashboard = 'nav_dashboard';
  static const String navPatients = 'nav_patients';
  static const String navAppointments = 'nav_appointments';
  static const String navBilling = 'nav_billing';
  static const String navSettings = 'nav_settings';
  static const String appNavbar = 'app_navbar';

  // ============ Dashboard Keys ============
  static const String dashboardPage = 'dashboard_page';
  static const String dashboardRevenueCard = 'dashboard_revenue_card';
  static const String dashboardPatientsCard = 'dashboard_patients_card';
  static const String dashboardAppointmentsCard = 'dashboard_appointments_card';
  static const String dashboardRevenueChart = 'dashboard_revenue_chart';

  // ============ Patient Keys ============
  static const String patientsPage = 'patients_page';
  static const String patientsList = 'patients_list';
  static const String patientSearchBar = 'patient_search_bar';
  static const String patientFilterButton = 'patient_filter_button';
  static const String addPatientButton = 'add_patient_button';
  static const String addPatientDialog = 'add_patient_dialog';
  static const String patientNameField = 'patient_name_field';
  static const String patientEmailField = 'patient_email_field';
  static const String patientPhoneField = 'patient_phone_field';
  static const String patientAddressField = 'patient_address_field';
  static const String patientGenderDropdown = 'patient_gender_dropdown';
  static const String patientDateOfBirthField = 'patient_dob_field';
  static const String patientBloodTypeDropdown = 'patient_blood_type_dropdown';
  static const String patientAllergiesField = 'patient_allergies_field';
  static const String patientInsuranceField = 'patient_insurance_field';
  static const String savePatientButton = 'save_patient_button';
  static const String cancelPatientButton = 'cancel_patient_button';
  static const String deletePatientButton = 'delete_patient_button';
  static const String confirmDeleteButton = 'confirm_delete_button';
  static const String editPatientButton = 'edit_patient_button';

  // ============ Appointment Keys ============
  static const String appointmentsPage = 'appointments_page';
  static const String appointmentCalendar = 'appointment_calendar';
  static const String appointmentsList = 'appointments_list';
  static const String scheduleAppointmentButton = 'schedule_appointment_button';
  static const String scheduleAppointmentDialog = 'schedule_appointment_dialog';
  static const String appointmentPatientDropdown =
      'appointment_patient_dropdown';
  static const String appointmentDoctorDropdown = 'appointment_doctor_dropdown';
  static const String appointmentDatePicker = 'appointment_date_picker';
  static const String appointmentTimePicker = 'appointment_time_picker';
  static const String appointmentTreatmentDropdown =
      'appointment_treatment_dropdown';
  static const String appointmentNotesField = 'appointment_notes_field';
  static const String saveAppointmentButton = 'save_appointment_button';
  static const String cancelAppointmentButton = 'cancel_appointment_button';
  static const String appointmentCard = 'appointment_card';
  static const String rescheduleAppointmentButton =
      'reschedule_appointment_button';

  // ============ Billing Keys ============
  static const String billingsPage = 'billings_page';
  static const String invoicesList = 'invoices_list';
  static const String createInvoiceButton = 'create_invoice_button';
  static const String createInvoiceDialog = 'create_invoice_dialog';
  static const String invoicePatientDropdown = 'invoice_patient_dropdown';
  static const String invoiceTreatmentDropdown = 'invoice_treatment_dropdown';
  static const String invoiceAmountField = 'invoice_amount_field';
  static const String invoiceDatePicker = 'invoice_date_picker';
  static const String invoiceNotesField = 'invoice_notes_field';
  static const String saveInvoiceButton = 'save_invoice_button';
  static const String addPaymentButton = 'add_payment_button';
  static const String addPaymentDialog = 'add_payment_dialog';
  static const String paymentAmountField = 'payment_amount_field';
  static const String paymentMethodDropdown = 'payment_method_dropdown';
  static const String paymentDatePicker = 'payment_date_picker';
  static const String savePaymentButton = 'save_payment_button';
  static const String invoiceCard = 'invoice_card';
  static const String viewInvoiceDetailsButton = 'view_invoice_details_button';

  // ============ Settings Keys ============
  static const String settingsPage = 'settings_page';
  static const String settingsProfileTab = 'settings_profile_tab';
  static const String settingsClinicTab = 'settings_clinic_tab';
  static const String settingsSecurityTab = 'settings_security_tab';
  static const String settingsSaveButton = 'settings_save_button';

  // ============ Common UI Keys ============
  static const String dialogCloseButton = 'dialog_close_button';
  static const String confirmButton = 'confirm_button';
  static const String cancelButton = 'cancel_button';
  static const String loadingIndicator = 'loading_indicator';
  static const String errorMessage = 'error_message';
  static const String successMessage = 'success_message';
  static const String searchField = 'search_field';
  static const String filterDialog = 'filter_dialog';
  static const String applyFilterButton = 'apply_filter_button';
  static const String clearFilterButton = 'clear_filter_button';

  // ============ Form Validation Keys ============
  static const String validationError = 'validation_error';
  static const String requiredFieldError = 'required_field_error';
}
