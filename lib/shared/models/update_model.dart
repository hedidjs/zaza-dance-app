class UpdateModel {
  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final String? imageUrl;
  final String? author;
  final UpdateType updateType;
  final bool isPinned;
  final bool isNew;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UpdateModel({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    this.imageUrl,
    this.author,
    required this.updateType,
    required this.isPinned,
    required this.isNew,
    required this.likeCount,
    required this.commentCount,
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
      author: json['author'] as String?,
      updateType: UpdateType.fromString(json['update_type'] as String? ?? 'announcement'),
      isPinned: json['is_pinned'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
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
      'author': author,
      'update_type': updateType.value,
      'is_pinned': isPinned,
      'is_new': isNew,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UpdateModel copyWith({
    String? title,
    String? content,
    String? excerpt,
    String? imageUrl,
    String? author,
    UpdateType? updateType,
    bool? isPinned,
    bool? isNew,
    int? likeCount,
    int? commentCount,
    DateTime? updatedAt,
  }) {
    return UpdateModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      updateType: updateType ?? this.updateType,
      isPinned: isPinned ?? this.isPinned,
      isNew: isNew ?? this.isNew,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UpdateType {
  announcement('announcement', 'הודעה'),
  studentSpotlight('student_spotlight', 'הישג תלמיד'),
  instructorTip('instructor_tip', 'טיפ מדריך'),
  event('event', 'אירוע');

  const UpdateType(this.value, this.displayName);

  final String value;
  final String displayName;

  static UpdateType fromString(String value) {
    return UpdateType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UpdateType.announcement,
    );
  }
}