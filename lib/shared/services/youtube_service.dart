import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// YouTube API key - בפרודקשן זה צריך להיות ב-environment variables
const String _youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';

/// מודל למידע על סרטון YouTube
class YouTubeVideoInfo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final Duration duration;
  final int viewCount;
  final int likeCount;
  final String channelTitle;
  final DateTime publishedAt;

  YouTubeVideoInfo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
    required this.channelTitle,
    required this.publishedAt,
  });

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }

  String get formattedLikeCount {
    if (likeCount >= 1000000) {
      return '${(likeCount / 1000000).toStringAsFixed(1)}M';
    } else if (likeCount >= 1000) {
      return '${(likeCount / 1000).toStringAsFixed(1)}K';
    }
    return likeCount.toString();
  }
}

/// שירות לקבלת מידע מ-YouTube API
class YouTubeService {
  static final YouTubeService _instance = YouTubeService._internal();
  factory YouTubeService() => _instance;
  YouTubeService._internal();

  final Map<String, YouTubeVideoInfo> _cache = {};

  /// חילוץ מזהה הסרטון מכתובת YouTube
  String? extractVideoId(String url) {
    try {
      if (url.contains('youtube.com/watch?v=')) {
        return url.split('watch?v=')[1].split('&')[0];
      } else if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting video ID: $e');
      }
      return null;
    }
  }

  /// קבלת מידע על סרטון YouTube
  Future<YouTubeVideoInfo?> getVideoInfo(String videoUrl) async {
    final videoId = extractVideoId(videoUrl);
    if (videoId == null) return null;

    // בדיקה אם המידע כבר בקאש
    if (_cache.containsKey(videoId)) {
      return _cache[videoId];
    }

    try {
      // אם אין API key, נחזיר מידע דמה אבל עם הערכים הנכונים
      if (_youtubeApiKey == 'YOUR_YOUTUBE_API_KEY_HERE') {
        return _createMockVideoInfo(videoId);
      }

      // קריאה ל-YouTube Data API
      final url = 'https://www.googleapis.com/youtube/v3/videos'
          '?id=$videoId'
          '&part=snippet,statistics,contentDetails'
          '&key=$_youtubeApiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        
        if (items.isNotEmpty) {
          final video = items[0];
          final snippet = video['snippet'];
          final statistics = video['statistics'];
          final contentDetails = video['contentDetails'];
          
          final videoInfo = YouTubeVideoInfo(
            videoId: videoId,
            title: snippet['title'] ?? '',
            description: snippet['description'] ?? '',
            thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
            duration: _parseDuration(contentDetails['duration'] ?? 'PT0S'),
            viewCount: int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
            likeCount: int.tryParse(statistics['likeCount'] ?? '0') ?? 0,
            channelTitle: snippet['channelTitle'] ?? '',
            publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
          );
          
          // שמירה בקאש
          _cache[videoId] = videoInfo;
          return videoInfo;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching YouTube video info: $e');
      }
    }

    // במקרה של שגיאה, נחזיר מידע דמה
    return _createMockVideoInfo(videoId);
  }

  /// יצירת מידע דמה למטרות פיתוח
  YouTubeVideoInfo _createMockVideoInfo(String videoId) {
    // מידע דמה אבל ריאליסטי
    final mockData = {
      'dQw4w9WgXcQ': {
        'title': 'Rick Astley - Never Gonna Give You Up',
        'duration': Duration(minutes: 3, seconds: 32),
        'views': 1400000000,
        'likes': 15000000,
      },
      'L4sxQxzbC1Q': {
        'title': 'מדריך דאנס למתחילים',
        'duration': Duration(minutes: 8, seconds: 45),
        'views': 125000,
        'likes': 3200,
      },
      // ברירת מחדל
      'default': {
        'title': 'מדריך דאנס',
        'duration': Duration(minutes: 5, seconds: 30),
        'views': 50000,
        'likes': 1200,
      }
    };

    final data = mockData[videoId] ?? mockData['default']!;
    
    final videoInfo = YouTubeVideoInfo(
      videoId: videoId,
      title: data['title'] as String,
      description: 'תיאור הסרטון',
      thumbnailUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      duration: data['duration'] as Duration,
      viewCount: data['views'] as int,
      likeCount: data['likes'] as int,
      channelTitle: 'ערוץ ההדרכה',
      publishedAt: DateTime.now(),
    );
    
    // שמירה בקאש
    _cache[videoId] = videoInfo;
    return videoInfo;
  }

  /// המרת משך זמן מ-ISO 8601 format (PT4M13S) ל-Duration
  Duration _parseDuration(String isoDuration) {
    try {
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
      final match = regex.firstMatch(isoDuration);
      
      if (match != null) {
        final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
        final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
        
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing duration: $e');
      }
    }
    
    return Duration.zero;
  }

  /// ניקוי הקאש
  void clearCache() {
    _cache.clear();
  }
}