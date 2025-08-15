class UpdateModel {
  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final String? imageUrl;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UpdateModel({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    this.imageUrl,
    required this.isPinned,
    required this.createdAt,
    this.updatedAt,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      imageUrl: json['image_url'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
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
      'content': content,
      'excerpt': excerpt,
      'image_url': imageUrl,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UpdateModel copyWith({
    String? title,
    String? content,
    String? excerpt,
    String? imageUrl,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return UpdateModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}