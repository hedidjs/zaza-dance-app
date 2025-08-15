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

  String get durationText {
    if (durationMinutes == null) return '';
    final minutes = durationMinutes!;
    if (minutes < 60) {
      return '${minutes} דקות';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours} שעות';
      } else {
        return '${hours} שעות ${remainingMinutes} דקות';
      }
    }
  }

  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      instructorId: json['instructor_id'] as String,
      instructorName: json['instructor_name'] as String?,
      difficultyLevel: DifficultyLevel.fromString(
        json['difficulty_level'] as String? ?? 'beginner',
      ),
      durationMinutes: json['duration_minutes'] as int?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'difficulty_level': difficultyLevel.value,
      'duration_minutes': durationMinutes,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'is_premium': isPremium,
      'view_count': viewCount,
      'like_count': likeCount,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TutorialModel copyWith({
    String? title,
    String? description,
    DifficultyLevel? difficultyLevel,
    int? durationMinutes,
    String? videoUrl,
    String? thumbnailUrl,
    bool? isPremium,
    int? viewCount,
    int? likeCount,
    bool? isPublished,
    DateTime? updatedAt,
  }) {
    return TutorialModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorId: instructorId,
      instructorName: instructorName,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum DifficultyLevel {
  beginner('beginner', 'מתחיל'),
  intermediate('intermediate', 'בינוני'),
  advanced('advanced', 'מתקדם');

  const DifficultyLevel(this.value, this.displayName);

  final String value;
  final String displayName;

  static DifficultyLevel fromString(String value) {
    return DifficultyLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => DifficultyLevel.beginner,
    );
  }
}