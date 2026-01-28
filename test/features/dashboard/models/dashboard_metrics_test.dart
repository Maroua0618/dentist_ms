import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/dashboard/models/dashboard_metrics.dart';

void main() {
  group('DashboardMetrics Model Tests', () {
    // Test data setup
    final validMetricsJson = {
      'total_revenue': 150000.0,
      'total_patients': 250,
      'completed_appointments': 180,
      'total_appointments': 200,
      'average_revenue_per_patient': 600.0,
      'revenue_trend': 'up',
      'patients_trend': 'up',
      'appointments_trend': 'stable',
    };

    test('should create DashboardMetrics from valid JSON', () {
      // Act
      final metrics = DashboardMetrics.fromJson(validMetricsJson);

      // Assert
      expect(metrics.totalRevenue, 150000.0);
      expect(metrics.totalPatients, 250);
      expect(metrics.completedAppointments, 180);
      expect(metrics.totalAppointments, 200);
      expect(metrics.averageRevenuePerPatient, 600.0);
      expect(metrics.revenueTrend, 'up');
      expect(metrics.patientsTrend, 'up');
      expect(metrics.appointmentsTrend, 'stable');
    });

    test('should handle JSON with missing optional fields', () {
      // Arrange
      final minimalJson = {
        'total_revenue': 50000.0,
        'total_patients': 100,
        'completed_appointments': 75,
        'average_revenue_per_patient': 500.0,
      };

      // Act
      final metrics = DashboardMetrics.fromJson(minimalJson);

      // Assert
      expect(metrics.totalRevenue, 50000.0);
      expect(metrics.totalPatients, 100);
      expect(metrics.completedAppointments, 75);
      expect(
        metrics.totalAppointments,
        75,
      ); // Defaults to completedAppointments
      expect(metrics.averageRevenuePerPatient, 500.0);
      expect(metrics.revenueTrend, isNull);
      expect(metrics.patientsTrend, isNull);
      expect(metrics.appointmentsTrend, isNull);
    });

    test('should use completedAppointments when totalAppointments is null', () {
      // Arrange
      final jsonWithNullTotal = {
        'total_revenue': 30000.0,
        'total_patients': 60,
        'completed_appointments': 50,
        'average_revenue_per_patient': 500.0,
      };

      // Act
      final metrics = DashboardMetrics.fromJson(jsonWithNullTotal);

      // Assert
      expect(metrics.completedAppointments, 50);
      expect(metrics.totalAppointments, 50); // Should equal completed
    });

    test('should handle numeric values correctly', () {
      // Arrange - Test with integer and double values
      final jsonWithIntegers = {
        'total_revenue': 100000, // Integer
        'total_patients': 150,
        'completed_appointments': 120,
        'total_appointments': 130,
        'average_revenue_per_patient': 666, // Integer
      };

      // Act
      final metrics = DashboardMetrics.fromJson(jsonWithIntegers);

      // Assert
      expect(metrics.totalRevenue, 100000.0);
      expect(metrics.averageRevenuePerPatient, 666.0);
    });

    test('should handle null/missing values with defaults', () {
      // Arrange - Empty JSON
      final emptyJson = <String, dynamic>{};

      // Act
      final metrics = DashboardMetrics.fromJson(emptyJson);

      // Assert
      expect(metrics.totalRevenue, 0.0);
      expect(metrics.totalPatients, 0);
      expect(metrics.completedAppointments, 0);
      expect(metrics.totalAppointments, 0);
      expect(metrics.averageRevenuePerPatient, 0.0);
      expect(metrics.revenueTrend, isNull);
      expect(metrics.patientsTrend, isNull);
      expect(metrics.appointmentsTrend, isNull);
    });

    test('should serialize DashboardMetrics to JSON correctly', () {
      // Arrange
      const metrics = DashboardMetrics(
        totalRevenue: 200000.0,
        totalPatients: 300,
        completedAppointments: 250,
        totalAppointments: 280,
        averageRevenuePerPatient: 666.67,
        revenueTrend: 'up',
        patientsTrend: 'up',
        appointmentsTrend: 'down',
      );

      // Act
      final json = metrics.toJson();

      // Assert
      expect(json['total_revenue'], 200000.0);
      expect(json['total_patients'], 300);
      expect(json['completed_appointments'], 250);
      expect(json['total_appointments'], 280);
      expect(json['average_revenue_per_patient'], 666.67);
      expect(json['revenue_trend'], 'up');
      expect(json['patients_trend'], 'up');
      expect(json['appointments_trend'], 'down');
    });

    test('should handle various trend values', () {
      // Arrange & Act
      final upTrend = DashboardMetrics.fromJson({
        'total_revenue': 1000.0,
        'total_patients': 10,
        'completed_appointments': 8,
        'average_revenue_per_patient': 100.0,
        'revenue_trend': 'up',
        'patients_trend': 'up',
        'appointments_trend': 'up',
      });

      final downTrend = DashboardMetrics.fromJson({
        'total_revenue': 1000.0,
        'total_patients': 10,
        'completed_appointments': 8,
        'average_revenue_per_patient': 100.0,
        'revenue_trend': 'down',
        'patients_trend': 'down',
        'appointments_trend': 'down',
      });

      final stableTrend = DashboardMetrics.fromJson({
        'total_revenue': 1000.0,
        'total_patients': 10,
        'completed_appointments': 8,
        'average_revenue_per_patient': 100.0,
        'revenue_trend': 'stable',
        'patients_trend': 'stable',
        'appointments_trend': 'stable',
      });

      // Assert
      expect(upTrend.revenueTrend, 'up');
      expect(upTrend.patientsTrend, 'up');
      expect(upTrend.appointmentsTrend, 'up');

      expect(downTrend.revenueTrend, 'down');
      expect(downTrend.patientsTrend, 'down');
      expect(downTrend.appointmentsTrend, 'down');

      expect(stableTrend.revenueTrend, 'stable');
      expect(stableTrend.patientsTrend, 'stable');
      expect(stableTrend.appointmentsTrend, 'stable');
    });

    test('should support equality comparison', () {
      // Arrange
      const metrics1 = DashboardMetrics(
        totalRevenue: 100000.0,
        totalPatients: 200,
        completedAppointments: 150,
        totalAppointments: 170,
        averageRevenuePerPatient: 500.0,
        revenueTrend: 'up',
      );

      const metrics2 = DashboardMetrics(
        totalRevenue: 100000.0,
        totalPatients: 200,
        completedAppointments: 150,
        totalAppointments: 170,
        averageRevenuePerPatient: 500.0,
        revenueTrend: 'up',
      );

      const metrics3 = DashboardMetrics(
        totalRevenue: 200000.0, // Different revenue
        totalPatients: 200,
        completedAppointments: 150,
        totalAppointments: 170,
        averageRevenuePerPatient: 500.0,
        revenueTrend: 'up',
      );

      // Act & Assert
      expect(metrics1, equals(metrics2));
      expect(metrics1, isNot(equals(metrics3)));
    });

    test('should handle large revenue values', () {
      // Arrange
      final largeRevenueJson = {
        'total_revenue': 9999999.99,
        'total_patients': 10000,
        'completed_appointments': 8000,
        'average_revenue_per_patient': 999.99,
      };

      // Act
      final metrics = DashboardMetrics.fromJson(largeRevenueJson);

      // Assert
      expect(metrics.totalRevenue, 9999999.99);
      expect(metrics.totalPatients, 10000);
      expect(metrics.averageRevenuePerPatient, 999.99);
    });

    test('should handle zero values correctly', () {
      // Arrange
      final zeroValuesJson = {
        'total_revenue': 0.0,
        'total_patients': 0,
        'completed_appointments': 0,
        'total_appointments': 0,
        'average_revenue_per_patient': 0.0,
      };

      // Act
      final metrics = DashboardMetrics.fromJson(zeroValuesJson);

      // Assert
      expect(metrics.totalRevenue, 0.0);
      expect(metrics.totalPatients, 0);
      expect(metrics.completedAppointments, 0);
      expect(metrics.totalAppointments, 0);
      expect(metrics.averageRevenuePerPatient, 0.0);
    });

    test('should round-trip JSON conversion correctly', () {
      // Arrange
      const original = DashboardMetrics(
        totalRevenue: 175000.50,
        totalPatients: 275,
        completedAppointments: 220,
        totalAppointments: 245,
        averageRevenuePerPatient: 636.37,
        revenueTrend: 'up',
        patientsTrend: 'stable',
        appointmentsTrend: 'down',
      );

      // Act
      final json = original.toJson();
      final restored = DashboardMetrics.fromJson(json);

      // Assert
      expect(restored, equals(original));
    });

    test('should create metrics with explicit totalAppointments parameter', () {
      // Arrange & Act
      const metrics = DashboardMetrics(
        totalRevenue: 50000.0,
        totalPatients: 100,
        completedAppointments: 80,
        totalAppointments: 90,
        averageRevenuePerPatient: 500.0,
      );

      // Assert
      expect(metrics.completedAppointments, 80);
      expect(metrics.totalAppointments, 90);
    });

    test('should handle negative trend values', () {
      // Arrange - Although unusual, the model should handle any string
      final customTrendJson = {
        'total_revenue': 50000.0,
        'total_patients': 100,
        'completed_appointments': 75,
        'average_revenue_per_patient': 500.0,
        'revenue_trend': 'negative_growth',
        'patients_trend': 'declining',
        'appointments_trend': 'fluctuating',
      };

      // Act
      final metrics = DashboardMetrics.fromJson(customTrendJson);

      // Assert
      expect(metrics.revenueTrend, 'negative_growth');
      expect(metrics.patientsTrend, 'declining');
      expect(metrics.appointmentsTrend, 'fluctuating');
    });
  });
}
