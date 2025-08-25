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
    try {
      return GalleryModel(
        id: json['id']?.toString() ?? '',
        titleHe: json['title_he']?.toString() ?? json['title']?.toString() ?? '',
        titleEn: json['title_en']?.toString(),
        descriptionHe: json['description_he']?.toString() ?? json['description']?.toString(),
        descriptionEn: json['description_en']?.toString(),
        mediaUrl: json['media_url']?.toString() ?? '',
        thumbnailUrl: json['thumbnail_url']?.toString(),
        mediaType: MediaType.fromString(json['media_type']?.toString() ?? 'image'),
        categoryId: json['category_id']?.toString(),
        category: json['categories'] != null 
            ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
            : null,
        tags: json['tags'] != null 
            ? List<String>.from(json['tags'] as List)
            : [],
        isFeatured: json['is_featured'] as bool? ?? false,
        likesCount: json['likes_count'] as int? ?? 0,
        viewsCount: json['views_count'] as int? ?? 0,
        sortOrder: json['sort_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse GalleryModel from JSON: $e');
    }
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
      'media_type': mediaType.value,
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

  // Additional convenience getters for compatibility
  String get title => titleHe;
  String get description => descriptionHe ?? '';
  String? get altText => descriptionHe; // For accessibility
  String get displayUrl => thumbnailUrl ?? mediaUrl;
  bool get isVideo => mediaType.isVideo;
  bool get isImage => mediaType.isImage;
  String get categoryName => category?.nameHe ?? '';
}

/// Media type enum for gallery items
enum MediaType {
  image('image', 'תמונה'),
  video('video', 'וידאו');

  const MediaType(this.value, this.displayName);

  final String value;
  final String displayName;

  static MediaType fromString(String value) {
    final normalizedValue = value.toLowerCase().trim();
    switch (normalizedValue) {
      case 'image':
      case 'photo':
      case 'picture':
        return MediaType.image;
      case 'video':
      case 'movie':
      case 'clip':
        return MediaType.video;
      default:
        return MediaType.image;
    }
  }

  @override
  String toString() => value;

  // Helper getters
  bool get isImage => this == MediaType.image;
  bool get isVideo => this == MediaType.video;
}