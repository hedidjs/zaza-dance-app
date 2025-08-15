import 'category_model.dart';

/// Model for gallery items (images and videos)
class GalleryModel {
  final String id;
  final String titleHe;
  final String? titleEn;
  final String? descriptionHe;
  final String? descriptionEn;
  final String mediaUrl;
  final String? thumbnailUrl;
  final MediaType mediaType;
  final String? categoryId;
  final CategoryModel? category;
  final List<String> tags;
  final bool isFeatured;
  final int likesCount;
  final int viewsCount;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GalleryModel({
    required this.id,
    required this.titleHe,
    this.titleEn,
    this.descriptionHe,
    this.descriptionEn,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.mediaType,
    this.categoryId,
    this.category,
    required this.tags,
    required this.isFeatured,
    required this.likesCount,
    required this.viewsCount,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] as String,
      titleHe: json['title_he'] as String,
      titleEn: json['title_en'] as String?,
      descriptionHe: json['description_he'] as String?,
      descriptionEn: json['description_en'] as String?,
      mediaUrl: json['media_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediaType: MediaType.fromString(json['media_type'] as String),
      categoryId: json['category_id'] as String?,
      category: json['categories'] != null 
          ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFeatured: json['is_featured'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
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
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'media_type': mediaType.toString(),
      'category_id': categoryId,
      'tags': tags,
      'is_featured': isFeatured,
      'likes_count': likesCount,
      'views_count': viewsCount,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GalleryModel copyWith({
    String? id,
    String? titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    String? mediaUrl,
    String? thumbnailUrl,
    MediaType? mediaType,
    String? categoryId,
    CategoryModel? category,
    List<String>? tags,
    bool? isFeatured,
    int? likesCount,
    int? viewsCount,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GalleryModel(
      id: id ?? this.id,
      titleHe: titleHe ?? this.titleHe,
      titleEn: titleEn ?? this.titleEn,
      descriptionHe: descriptionHe ?? this.descriptionHe,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaType: mediaType ?? this.mediaType,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GalleryModel(id: $id, titleHe: $titleHe, mediaType: $mediaType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GalleryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Media type enum for gallery items
enum MediaType {
  image,
  video;

  static MediaType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.image;
    }
  }

  @override
  String toString() {
    switch (this) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
    }
  }
}