import 'category_model.dart';

class TutorialModel {
  final String id;
  final String titleHe;
  final String? titleEn;
  final String? descriptionHe;
  final String? descriptionEn;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final DifficultyLevel? difficultyLevel;
  final String? categoryId;
  final CategoryModel? category;
  final String? instructorName;
  final List<String> tags;
  final bool isFeatured;
  final int likesCount;
  final int viewsCount;
  final int downloadsCount;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TutorialModel({
    required this.id,
    required this.titleHe,
    this.titleEn,
    this.descriptionHe,
    this.descriptionEn,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.difficultyLevel,
    this.categoryId,
    this.category,
    this.instructorName,
    required this.tags,
    required this.isFeatured,
    required this.likesCount,
    required this.viewsCount,
    required this.downloadsCount,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedDuration {
    if (durationSeconds == null) return '';
    
    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;
    final seconds = durationSeconds! % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get difficultyText {
    return difficultyLevel?.displayName ?? '';
  }

  // Legacy getters for compatibility
  String get title => titleHe;
  String get description => descriptionHe ?? '';
  int get duration => durationSeconds ?? 0;
  String get categoryName => category?.nameHe ?? '';
  String get instructor => instructorName ?? '';

  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      id: json['id'] as String,
      titleHe: json['title_he'] as String,
      titleEn: json['title_en'] as String?,
      descriptionHe: json['description_he'] as String?,
      descriptionEn: json['description_en'] as String?,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      difficultyLevel: json['difficulty_level'] != null 
          ? DifficultyLevel.fromString(json['difficulty_level'] as String)
          : null,
      categoryId: json['category_id'] as String?,
      category: json['categories'] != null 
          ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      instructorName: json['instructor_name'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFeatured: json['is_featured'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_he': titleHe,
      'title_en': titleEn,
      'description_he': descriptionHe,
      'description_en': descriptionEn,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'difficulty_level': difficultyLevel?.value,
      'category_id': categoryId,
      'instructor_name': instructorName,
      'tags': tags,
      'is_featured': isFeatured,
      'likes_count': likesCount,
      'views_count': viewsCount,
      'downloads_count': downloadsCount,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TutorialModel copyWith({
    String? id,
    String? titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    String? videoUrl,
    String? thumbnailUrl,
    int? durationSeconds,
    DifficultyLevel? difficultyLevel,
    String? categoryId,
    CategoryModel? category,
    String? instructorName,
    List<String>? tags,
    bool? isFeatured,
    int? likesCount,
    int? viewsCount,
    int? downloadsCount,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TutorialModel(
      id: id ?? this.id,
      titleHe: titleHe ?? this.titleHe,
      titleEn: titleEn ?? this.titleEn,
      descriptionHe: descriptionHe ?? this.descriptionHe,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      instructorName: instructorName ?? this.instructorName,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      downloadsCount: downloadsCount ?? this.downloadsCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TutorialModel(id: $id, titleHe: $titleHe, instructor: $instructorName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorialModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum DifficultyLevel {
  beginner('beginner', 'מתחילים'),
  intermediate('intermediate', 'בינוני'),
  advanced('advanced', 'מתקדמים');

  const DifficultyLevel(this.value, this.displayName);

  final String value;
  final String displayName;

  static DifficultyLevel fromString(String value) {
    return DifficultyLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => DifficultyLevel.beginner,
    );
  }

  @override
  String toString() => value;
}