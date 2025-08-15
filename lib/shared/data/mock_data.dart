import '../models/gallery_model.dart';
import '../models/tutorial_model.dart';
import '../models/update_model.dart';

/// Mock data for development and testing
class MockData {
  static final List<Map<String, dynamic>> categories = [
    {
      'id': 'cat_1',
      'name': 'היפ הופ קלאסי',
      'description': 'תנועות בסיסיות וקלאסיות של היפ הופ',
      'color': '#FF00FF',
      'order': 1,
    },
    {
      'id': 'cat_2',
      'name': 'ברייקדאנס',
      'description': 'תנועות קרקע ואקרובטיות',
      'color': '#40E0D0',
      'order': 2,
    },
    {
      'id': 'cat_3',
      'name': 'פופינג',
      'description': 'תנועות פופינג ולוקינג',
      'color': '#9C27B0',
      'order': 3,
    },
  ];

  static final List<MockGalleryItem> galleryItems = [
    MockGalleryItem(
      id: 'gallery_1',
      title: 'ביצוע מדהים של מיה',
      description: 'מיה מבצעת רצף ברייקדאנס מושלם',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1547153760-18fc86324498?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      tags: ['ברייקדאנס', 'תלמידים', 'ביצוע'],
      isPopular: true,
      likes: 45,
      views: 234,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MockGalleryItem(
      id: 'gallery_2',
      title: 'סשן אימון קבוצתי',
      description: 'האימון השבועי של הקבוצה המתקדמת',
      imageUrl: 'https://images.unsplash.com/photo-1594736797933-d0201ba2fe65?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      thumbnailUrl: 'https://images.unsplash.com/photo-1594736797933-d0201ba2fe65?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      tags: ['קבוצתי', 'אימון'],
      isPopular: false,
      likes: 23,
      views: 127,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MockGalleryItem(
      id: 'gallery_3',
      title: 'תמונת הקבוצה',
      description: 'תמונה משותפת אחרי התחרות',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      thumbnailUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      tags: ['קבוצה', 'תחרות'],
      isPopular: true,
      likes: 67,
      views: 312,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static final List<MockTutorial> tutorials = [
    MockTutorial(
      id: 'tutorial_1',
      title: 'יסודות הברייקדאנס למתחילים',
      description: 'למד את התנועות הבסיסיות של ברייקדאנס',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      duration: 900, // 15 minutes
      difficultyLevel: DifficultyLevel.beginner,
      instructorName: 'רועי המדריך',
      likeCount: 89,
      viewCount: 445,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MockTutorial(
      id: 'tutorial_2',
      title: 'פופינג מתקדם',
      description: 'טכניקות מתקדמות בפופינג',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      duration: 1200, // 20 minutes
      difficultyLevel: DifficultyLevel.advanced,
      instructorName: 'שרון המדריכה',
      likeCount: 156,
      viewCount: 723,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    MockTutorial(
      id: 'tutorial_3',
      title: 'היפ הופ לילדים',
      description: 'מדריך מיוחד לילדים צעירים',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      duration: 600, // 10 minutes
      difficultyLevel: DifficultyLevel.beginner,
      instructorName: 'דני המדריך',
      likeCount: 234,
      viewCount: 1123,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  static final List<MockUpdate> updates = [
    MockUpdate(
      id: 'update_1',
      title: '🔥 תחרות ההיפ הופ השנתית!',
      content: 'אנחנו גאים להודיע על תחרות ההיפ הופ השנתית שלנו! התחרות תתקיים בחודש הבא ופתוחה לכל הרמות. פרסים מדהימים מחכים לזוכים!',
      excerpt: 'תחרות ההיפ הופ השנתית - הרשמה פתוחה!',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      updateType: UpdateType.announcement,
      isPinned: true,
      author: 'צוות זזה דאנס',
      likeCount: 123,
      commentCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockUpdate(
      id: 'update_2',
      title: '⭐ מיה זוכה במקום הראשון!',
      content: 'התלמידה שלנו מיה זכתה במקום הראשון בתחרות הארצית! אנחנו כל כך גאים בה ובהישג המדהים הזה. מיה מראה לנו שבעבודה קשה ומסירות אפשר להגיע לכל מקום!',
      excerpt: 'מיה מככבת בתחרות הארצית',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      updateType: UpdateType.achievement,
      isPinned: false,
      author: 'רועי המדריך',
      likeCount: 89,
      commentCount: 23,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MockUpdate(
      id: 'update_3',
      title: '💡 טיפ השבוע: שיפור הקצב',
      content: 'השבוע נלמד איך לשפר את הקצב שלנו בריקוד. הסוד הוא להקשיב למוזיקה באמת ולהרגיש אותה בגוף. תתרגלו עם מטרונום ותבחינו בשיפור!',
      excerpt: 'טיפים לשיפור הקצב בריקוד',
      imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      updateType: UpdateType.tip,
      isPinned: false,
      author: 'שרון המדריכה',
      likeCount: 67,
      commentCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];
}

class MockGalleryItem {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String> tags;
  final bool isPopular;
  final int likes;
  final int views;
  final DateTime createdAt;

  MockGalleryItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.thumbnailUrl,
    required this.tags,
    required this.isPopular,
    required this.likes,
    required this.views,
    required this.createdAt,
  });
}

class MockTutorial {
  final String id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int duration;
  final DifficultyLevel difficultyLevel;
  final String? instructorName;
  final int likeCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MockTutorial({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.difficultyLevel,
    this.instructorName,
    required this.likeCount,
    required this.viewCount,
    required this.createdAt,
    this.updatedAt,
  });
}

class MockUpdate {
  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final String? imageUrl;
  final UpdateType updateType;
  final bool isPinned;
  final String? author;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MockUpdate({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    this.imageUrl,
    required this.updateType,
    required this.isPinned,
    this.author,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.updatedAt,
  });
}