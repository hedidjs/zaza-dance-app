/// Model for content categories
class CategoryModel {
  final String id;
  final String nameHe;
  final String? nameEn;
  final String? descriptionHe;
  final String? descriptionEn;
  final String color;
  final String? icon;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.nameHe,
    this.nameEn,
    this.descriptionHe,
    this.descriptionEn,
    required this.color,
    this.icon,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameHe: json['name_he'] as String,
      nameEn: json['name_en'] as String?,
      descriptionHe: json['description_he'] as String?,
      descriptionEn: json['description_en'] as String?,
      color: json['color'] as String? ?? '#FF00FF',
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_he': nameHe,
      'name_en': nameEn,
      'description_he': descriptionHe,
      'description_en': descriptionEn,
      'color': color,
      'icon': icon,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? color,
    String? icon,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nameHe: nameHe ?? this.nameHe,
      nameEn: nameEn ?? this.nameEn,
      descriptionHe: descriptionHe ?? this.descriptionHe,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, nameHe: $nameHe, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}