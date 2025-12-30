import 'package:equatable/equatable.dart';

class Treatment extends Equatable {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final double? basePrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Treatment({
    this.id,
    this.code,
    this.name,
    this.description,
    this.basePrice,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory to parse from Supabase JSON (handles snake_case and numeric types safely)
  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      basePrice: json['base_price'] is num
          ? (json['base_price'] as num).toDouble()
          : json['base_price'] != null
              ? double.tryParse(json['base_price'].toString())
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Convert to JSON for insert/update in Supabase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'code': code,
      'name': name,
      'description': description,
      'base_price': basePrice,
    };

    // Only include id when updating an existing treatment
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  /// Nice display name (used in dropdowns, logs, etc.)
  String get displayName => name ?? code ?? 'Unnamed Treatment';

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        basePrice,
        createdAt,
        updatedAt,
      ];

  /// Optional: for clean debugging
  @override
  String toString() => displayName;
}