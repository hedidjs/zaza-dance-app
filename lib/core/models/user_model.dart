import 'package:equatable/equatable.dart';
import '../constants/app_constants.dart';

/// User model for authentication and profile management
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final String role;
  final String? profileImageUrl;
  final DateTime? birthDate;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.address,
    this.role = AppConstants.roleStudent,
    this.profileImageUrl,
    this.birthDate,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Creates a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String? ?? AppConstants.roleStudent,
      profileImageUrl: json['profile_image_url'] as String?,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'role': role,
      'profile_image_url': profileImageUrl,
      'birth_date': birthDate?.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Creates a copy of this user with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? role,
    String? profileImageUrl,
    DateTime? birthDate,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      birthDate: birthDate ?? this.birthDate,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Checks if user has a specific role
  bool hasRole(String roleToCheck) => role == roleToCheck;

  /// Checks if user is an admin
  bool get isAdmin => hasRole(AppConstants.roleAdmin);

  /// Checks if user is an instructor
  bool get isInstructor => hasRole(AppConstants.roleInstructor);

  /// Checks if user is a parent
  bool get isParent => hasRole(AppConstants.roleParent);

  /// Checks if user is a student
  bool get isStudent => hasRole(AppConstants.roleStudent);

  /// Gets display name (full name or email if name not available)
  String get displayName => fullName?.isNotEmpty == true ? fullName! : email;

  /// Gets first name from full name
  String? get firstName {
    if (fullName?.isNotEmpty != true) return null;
    final parts = fullName!.split(' ');
    return parts.isNotEmpty ? parts.first : null;
  }

  /// Alias for phoneNumber for compatibility
  String? get phone => phoneNumber;

  /// Gets bio from metadata
  String? get bio => metadata?['bio'] as String?;

  /// Checks if profile is complete (has required fields)
  bool get isProfileComplete {
    return fullName?.isNotEmpty == true && 
           phoneNumber?.isNotEmpty == true;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        address,
        role,
        profileImageUrl,
        birthDate,
        isEmailVerified,
        isPhoneVerified,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }
}