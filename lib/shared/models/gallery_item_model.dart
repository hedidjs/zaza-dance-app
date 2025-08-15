class GalleryItemModel {
  final String id;
  final String title;
  final String? description;
  final String mediaUrl;
  final String? thumbnailUrl;
  final MediaType mediaType;
  final bool isFeatured;
  final String? altText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GalleryItemModel({
    required this.id,
    required this.title,
    this.description,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.mediaType,
    required this.isFeatured,
    this.altText,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isVideo => mediaType == MediaType.video;
  bool get isImage => mediaType == MediaType.image;

  String get displayUrl => thumbnailUrl ?? mediaUrl;

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    return GalleryItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      mediaUrl: json['media_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediaType: MediaType.fromString(json['media_type'] as String),
      isFeatured: json['is_featured'] as bool? ?? false,
      altText: json['alt_text'] as String?,
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
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'media_type': mediaType.value,
      'is_featured': isFeatured,
      'alt_text': altText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  GalleryItemModel copyWith({
    String? title,
    String? description,
    String? mediaUrl,
    String? thumbnailUrl,
    MediaType? mediaType,
    bool? isFeatured,
    String? altText,
    DateTime? updatedAt,
  }) {
    return GalleryItemModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaType: mediaType ?? this.mediaType,
      isFeatured: isFeatured ?? this.isFeatured,
      altText: altText ?? this.altText,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum MediaType {
  image('image', 'תמונה'),
  video('video', 'וידאו');

  const MediaType(this.value, this.displayName);

  final String value;
  final String displayName;

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MediaType.image,
    );
  }
}