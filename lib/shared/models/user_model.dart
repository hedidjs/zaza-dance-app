class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final UserRole role;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? bio;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.bio,
    this.isActive = true,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email.split('@').first;
  }

  // Getters for role checking
  bool get isAdmin => role == UserRole.admin;
  bool get isInstructor => role == UserRole.instructor;
  bool get isParent => role == UserRole.parent;
  bool get isStudent => role == UserRole.student;

  // Additional properties for compatibility
  String get displayName => fullName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safe role parsing with fallback
      String? roleValue = json['role']?.toString();
      UserRole userRole = UserRole.student; // Default fallback
      
      if (roleValue != null && roleValue.isNotEmpty) {
        try {
          userRole = UserRole.fromString(roleValue);
        } catch (e) {
          userRole = UserRole.student;
        }
      }
      
      // Handle both old and new schema formats
      String? firstName;
      String? lastName;
      
      // Check for display_name first (new schema)
      String? displayName = json['display_name']?.toString();
      if (displayName != null && displayName.isNotEmpty) {
        // If display_name exists, use it as firstName
        firstName = displayName;
      } else {
        // Fall back to old first_name/last_name format
        firstName = json['first_name']?.toString();
        lastName = json['last_name']?.toString();
      }
      
      // Handle birth_date vs date_of_birth
      DateTime? dateOfBirth;
      if (json['birth_date'] != null) {
        dateOfBirth = DateTime.tryParse(json['birth_date'].toString());
      } else if (json['date_of_birth'] != null) {
        dateOfBirth = DateTime.tryParse(json['date_of_birth'].toString());
      }

      return UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: firstName,
        lastName: lastName,
        avatarUrl: json['avatar_url']?.toString() ?? json['profile_image_url']?.toString(),
        role: userRole,
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        dateOfBirth: dateOfBirth,
        bio: json['bio']?.toString(),
        isActive: json['is_active'] == true || json['is_active'] == null, // Default to true
        metadata: json['metadata'] as Map<String, dynamic>?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      // Return a minimal valid user model
      return UserModel(
        id: json['id']?.toString() ?? 'unknown',
        email: json['email']?.toString() ?? 'unknown@zazadance.com',
        role: UserRole.student,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': firstName, // Use display_name for new schema
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'role': role.value,
      'phone': phone,
      'address': address,
      'birth_date': dateOfBirth?.toIso8601String(),
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    UserRole? role,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? bio,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: $role, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum UserRole {
  student('student', 'תלמיד'),
  parent('parent', 'הורה'),
  instructor('instructor', 'מדריך'),
  admin('admin', 'מנהל');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    final normalizedValue = value.toLowerCase().trim();
    
    // Try exact match first
    for (final role in UserRole.values) {
      if (role.value.toLowerCase() == normalizedValue) {
        return role;
      }
    }
    
    // Try partial matches for common variations
    switch (normalizedValue) {
      case 'admin':
      case 'administrator':
      case 'manager':
      case 'מנהל':
        return UserRole.admin;
      case 'instructor':
      case 'teacher':
      case 'מדריך':
      case 'מורה':
        return UserRole.instructor;
      case 'parent':
      case 'guardian':
      case 'הורה':
        return UserRole.parent;
      case 'student':
      case 'תלמיד':
      case 'child':
      default:
        return UserRole.student;
    }
  }
}