class UpdateModel {
  final String id;
  final String titleHe;
  final String? titleEn;
  final String contentHe;
  final String? contentEn;
  final String? excerptHe;
  final String? excerptEn;
  final String? imageUrl;
  final UpdateType updateType;
  final bool isPinned;
  final bool isFeatured;
  final String? authorName;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> tags;
  final DateTime publishDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UpdateModel({
    required this.id,
    required this.titleHe,
    this.titleEn,
    required this.contentHe,
    this.contentEn,
    this.excerptHe,
    this.excerptEn,
    this.imageUrl,
    required this.updateType,
    required this.isPinned,
    required this.isFeatured,
    this.authorName,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.tags,
    required this.publishDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishDate);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'לפני ${months} חודשים';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'לפני ${weeks} שבועות';
    } else if (difference.inDays > 0) {
      return 'לפני ${difference.inDays} ימים';
    } else if (difference.inHours > 0) {
      return 'לפני ${difference.inHours} שעות';
    } else if (difference.inMinutes > 0) {
      return 'לפני ${difference.inMinutes} דקות';
    } else {
      return 'הרגע';
    }
  }

  // Legacy getters for compatibility
  String get title => titleHe;
  String get content => contentHe;
  String get excerpt => excerptHe ?? '';
  String get author => authorName ?? '';
  bool get isNew => DateTime.now().difference(publishDate).inDays < 3;
  int get likeCount => likesCount;
  int get commentCount => commentsCount;

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      id: json['id'] as String,
      titleHe: json['title_he'] as String,
      titleEn: json['title_en'] as String?,
      contentHe: json['content_he'] as String,
      contentEn: json['content_en'] as String?,
      excerptHe: json['excerpt_he'] as String?,
      excerptEn: json['excerpt_en'] as String?,
      imageUrl: json['image_url'] as String?,
      updateType: UpdateType.fromString(json['update_type'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      authorName: json['author_name'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      publishDate: DateTime.parse(json['publish_date'] as String),
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
      'content_he': contentHe,
      'content_en': contentEn,
      'excerpt_he': excerptHe,
      'excerpt_en': excerptEn,
      'image_url': imageUrl,
      'update_type': updateType.value,
      'is_pinned': isPinned,
      'is_featured': isFeatured,
      'author_name': authorName,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'tags': tags,
      'publish_date': publishDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UpdateModel copyWith({
    String? id,
    String? titleHe,
    String? titleEn,
    String? contentHe,
    String? contentEn,
    String? excerptHe,
    String? excerptEn,
    String? imageUrl,
    UpdateType? updateType,
    bool? isPinned,
    bool? isFeatured,
    String? authorName,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? tags,
    DateTime? publishDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UpdateModel(
      id: id ?? this.id,
      titleHe: titleHe ?? this.titleHe,
      titleEn: titleEn ?? this.titleEn,
      contentHe: contentHe ?? this.contentHe,
      contentEn: contentEn ?? this.contentEn,
      excerptHe: excerptHe ?? this.excerptHe,
      excerptEn: excerptEn ?? this.excerptEn,
      imageUrl: imageUrl ?? this.imageUrl,
      updateType: updateType ?? this.updateType,
      isPinned: isPinned ?? this.isPinned,
      isFeatured: isFeatured ?? this.isFeatured,
      authorName: authorName ?? this.authorName,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      tags: tags ?? this.tags,
      publishDate: publishDate ?? this.publishDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UpdateModel(id: $id, titleHe: $titleHe, updateType: $updateType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum UpdateType {
  news('news', 'חדשות'),
  announcement('announcement', 'הודעה'),
  event('event', 'אירוע'),
  achievement('achievement', 'הישג'),
  tip('tip', 'טיפ');

  const UpdateType(this.value, this.displayName);

  final String value;
  final String displayName;

  static UpdateType fromString(String value) {
    return UpdateType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UpdateType.announcement,
    );
  }

  @override
  String toString() => value;
}