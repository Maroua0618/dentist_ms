import 'package:equatable/equatable.dart';
import 'app_user.dart';

class Permissions extends Equatable {
  final bool canViewAllPatients;
  final bool canCreatePatients;
  final bool canEditPatients;
  final bool canDeletePatients;
  final bool canViewAllAppointments;
  final bool canCreateAppointments;
  final bool canEditAppointments;
  final bool canDeleteAppointments;
  final bool canViewInvoices;
  final bool canCreateInvoices;
  final bool canEditInvoices;
  final bool canViewAuditLogs;
  final bool canManageUsers;

  const Permissions({
    this.canViewAllPatients = false,
    this.canCreatePatients = false,
    this. canEditPatients = false,
    this.canDeletePatients = false,
    this.canViewAllAppointments = false,
    this.canCreateAppointments = false,
    this.canEditAppointments = false,
    this.canDeleteAppointments = false,
    this.canViewInvoices = false,
    this.canCreateInvoices = false,
    this.canEditInvoices = false,
    this.canViewAuditLogs = false,
    this.canManageUsers = false,
  });

  factory Permissions.fromRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Permissions(
          canViewAllPatients: true,
          canCreatePatients: true,
          canEditPatients: true,
          canDeletePatients: true,
          canViewAllAppointments: true,
          canCreateAppointments: true,
          canEditAppointments: true,
          canDeleteAppointments: true,
          canViewInvoices: true,
          canCreateInvoices: true,
          canEditInvoices: true,
          canViewAuditLogs: true,
          canManageUsers: true,
        );
      case UserRole.receptionist:
        return const Permissions(
          canViewAllPatients: true,
          canCreatePatients: true,
          canEditPatients: true,
          canViewAllAppointments: true,
          canCreateAppointments: true,
          canEditAppointments: true,
          canDeleteAppointments: true,
          canViewInvoices: true,
          canCreateInvoices: true,
          canEditInvoices: true,
        );
      case UserRole.doctor:
        return const Permissions(
          canViewAllPatients:  false,
          canViewAllAppointments: false,
          canEditAppointments: true,
          canViewInvoices: true,
        );
    }
  }

  @override
  List<Object?> get props => [
        canViewAllPatients,
        canCreatePatients,
        canEditPatients,
        canDeletePatients,
        canViewAllAppointments,
        canCreateAppointments,
        canEditAppointments,
        canDeleteAppointments,
        canViewInvoices,
        canCreateInvoices,
        canEditInvoices,
        canViewAuditLogs,
        canManageUsers,
      ];
}