import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/admin_stats_model.dart';

/// שירות אנליטיקה מקיף עבור מנהלי זזה דאנס
/// Comprehensive analytics service for Zaza Dance administrators
class AdminAnalyticsService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
  // Cache for frequently accessed data (5 minutes TTL)
  static final Map<String, _CacheItem> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 5);

  // =============================================
  // CORE DASHBOARD STATISTICS
  // =============================================

  /// קבלת סטטיסטיקות דשבורד ראשיות
  /// Get main dashboard statistics
  static Future<AdminStatsModel> getDashboardStats() async {
    const cacheKey = 'dashboard_stats';
    
    // Check cache first
    if (_cache.containsKey(cacheKey) && !_cache[cacheKey]!.isExpired) {
      return _cache[cacheKey]!.data as AdminStatsModel;
    }

    try {
      // Parallel execution for better performance
      final futures = await Future.wait([
        _getTotalUsers(),
        _getActiveUsers(),
        _getTotalTutorials(),
        _getTutorialViews(),
        _getGalleryImages(),
        _getPublishedUpdates(),
        _getCompletionRate(),
        _getNewSignups(),
        _getUsersByRole(),
        _getDailyUsage(),
        _getPopularTutorials(),
      ]);

      final stats = AdminStatsModel(
        totalUsers: futures[0] as int,
        activeUsers: futures[1] as int,
        totalTutorials: futures[2] as int,
        tutorialViews: futures[3] as int,
        galleryImages: futures[4] as int,
        publishedUpdates: futures[5] as int,
        completionRate: futures[6] as double,
        newSignups: futures[7] as int,
        usersByRole: futures[8] as Map<String, int>,
        dailyUsage: futures[9] as List<DailyUsageStats>,
        popularTutorials: futures[10] as List<PopularTutorial>,
      );

      // Cache the result
      _cache[cacheKey] = _CacheItem(stats, DateTime.now());
      
      return stats;
    } catch (e) {
      throw Exception('שגיאה בטעינת סטטיסטיקות דשבורד: $e');
    }
  }

  // =============================================
  // USER ANALYTICS
  // =============================================

  /// אנליטיקת משתמשים - צמיחה, פעילות ומעורבות
  /// User analytics - growth, activity, and engagement
  static Future<Map<String, dynamic>> getUserAnalytics({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final futures = await Future.wait([
        _getUserGrowth(dateFrom, dateTo),
        _getUserActivity(dateFrom, dateTo),
        _getUserEngagement(dateFrom, dateTo),
        _getUserDemographics(),
        _getUserRetentionRates(dateFrom, dateTo),
      ]);

      return {
        'growth': futures[0],
        'activity': futures[1],
        'engagement': futures[2],
        'demographics': futures[3],
        'retention': futures[4],
        'period': {
          'from': dateFrom.toIso8601String(),
          'to': dateTo.toIso8601String(),
        }
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת אנליטיקת משתמשים: $e');
    }
  }

  /// ניתוח שימור משתמשים
  /// User retention analysis
  static Future<Map<String, dynamic>> getUserRetention(String period) async {
    try {
      String interval;
      String dateFormat;
      
      switch (period.toLowerCase()) {
        case 'daily':
          interval = '1 day';
          dateFormat = 'YYYY-MM-DD';
          break;
        case 'weekly':
          interval = '7 days';
          dateFormat = 'YYYY-WW';
          break;
        case 'monthly':
          interval = '1 month';
          dateFormat = 'YYYY-MM';
          break;
        default:
          throw ArgumentError('תקופה לא תקינה: $period');
      }

      // Complex retention query using SQL
      final response = await _client.rpc('calculate_user_retention', params: {
        'retention_period': interval,
        'date_format': dateFormat,
      });

      return {
        'period': period,
        'retention_data': response,
        'calculated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('שגיאה בחישוב שימור משתמשים: $e');
    }
  }

  // =============================================
  // TUTORIAL ANALYTICS
  // =============================================

  /// אנליטיקת מדריכים - צפיות, השלמות ותוכן פופולרי
  /// Tutorial analytics - views, completions, popular content
  static Future<Map<String, dynamic>> getTutorialAnalytics({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final response = await _client.rpc('get_tutorial_analytics', params: {
        'start_date': dateFrom.toIso8601String(),
        'end_date': dateTo.toIso8601String(),
      });

      return {
        'total_views': response['total_views'] ?? 0,
        'total_completions': response['total_completions'] ?? 0,
        'avg_completion_rate': response['avg_completion_rate'] ?? 0.0,
        'popular_tutorials': response['popular_tutorials'] ?? [],
        'view_trends': response['view_trends'] ?? [],
        'completion_trends': response['completion_trends'] ?? [],
        'category_performance': response['category_performance'] ?? {},
        'difficulty_performance': response['difficulty_performance'] ?? {},
        'instructor_performance': response['instructor_performance'] ?? [],
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת אנליטיקת מדריכים: $e');
    }
  }

  // =============================================
  // GALLERY ANALYTICS
  // =============================================

  /// אנליטיקת גלריה - צפיות ותוכן פופולרי
  /// Gallery analytics - views and popular content
  static Future<Map<String, dynamic>> getGalleryAnalytics({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final response = await _client.rpc('get_gallery_analytics', params: {
        'start_date': dateFrom.toIso8601String(),
        'end_date': dateTo.toIso8601String(),
      });

      return {
        'total_views': response['total_views'] ?? 0,
        'total_likes': response['total_likes'] ?? 0,
        'popular_items': response['popular_items'] ?? [],
        'media_type_breakdown': response['media_type_breakdown'] ?? {},
        'category_performance': response['category_performance'] ?? {},
        'upload_trends': response['upload_trends'] ?? [],
        'engagement_rate': response['engagement_rate'] ?? 0.0,
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת אנליטיקת גלריה: $e');
    }
  }

  // =============================================
  // UPDATE ANALYTICS
  // =============================================

  /// אנליטיקת עדכונים - צפיות ומעורבות
  /// Update analytics - views and engagement
  static Future<Map<String, dynamic>> getUpdateAnalytics({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final response = await _client.rpc('get_update_analytics', params: {
        'start_date': dateFrom.toIso8601String(),
        'end_date': dateTo.toIso8601String(),
      });

      return {
        'total_views': response['total_views'] ?? 0,
        'total_updates': response['total_updates'] ?? 0,
        'avg_views_per_update': response['avg_views_per_update'] ?? 0.0,
        'popular_updates': response['popular_updates'] ?? [],
        'type_performance': response['type_performance'] ?? {},
        'engagement_metrics': response['engagement_metrics'] ?? {},
        'click_through_rates': response['click_through_rates'] ?? [],
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת אנליטיקת עדכונים: $e');
    }
  }

  // =============================================
  // PERFORMANCE METRICS
  // =============================================

  /// מדדי ביצועים - זמני טעינה ושגיאות
  /// Performance metrics - load times and errors
  static Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final response = await _client.rpc('get_performance_metrics');

      return {
        'avg_load_time': response['avg_load_time'] ?? 0.0,
        'error_rate': response['error_rate'] ?? 0.0,
        'crash_rate': response['crash_rate'] ?? 0.0,
        'api_response_times': response['api_response_times'] ?? {},
        'slow_queries': response['slow_queries'] ?? [],
        'error_breakdown': response['error_breakdown'] ?? {},
        'performance_trends': response['performance_trends'] ?? [],
        'device_performance': response['device_performance'] ?? {},
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת מדדי ביצועים: $e');
    }
  }

  // =============================================
  // REAL-TIME STATISTICS
  // =============================================

  /// סטטיסטיקות בזמן אמת
  /// Real-time statistics
  static Future<Map<String, dynamic>> getRealtimeStats() async {
    try {
      final response = await _client.rpc('get_realtime_stats');

      return {
        'active_users': response['active_users'] ?? 0,
        'current_sessions': response['current_sessions'] ?? 0,
        'live_activities': response['live_activities'] ?? [],
        'trending_content': response['trending_content'] ?? [],
        'recent_signups': response['recent_signups'] ?? 0,
        'live_errors': response['live_errors'] ?? [],
        'server_status': response['server_status'] ?? 'healthy',
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת סטטיסטיקות בזמן אמת: $e');
    }
  }

  /// מעקב בזמן אמת עם subscription
  /// Real-time tracking with subscription
  static Stream<Map<String, dynamic>> getRealtimeStatsStream() {
    return _client
        .from('realtime_analytics')
        .stream(primaryKey: ['id'])
        .map((data) => {
              'timestamp': DateTime.now().toIso8601String(),
              'data': data,
            });
  }

  // =============================================
  // CONTENT POPULARITY
  // =============================================

  /// דירוג תוכן פופולרי
  /// Popular content ranking
  static Future<List<Map<String, dynamic>>> getContentPopularity({
    required String contentType,
    int limit = 10,
  }) async {
    try {
      final response = await _client.rpc('get_content_popularity', params: {
        'content_type_filter': contentType,
        'result_limit': limit,
      });

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      throw Exception('שגיאה בטעינת תוכן פופולרי: $e');
    }
  }

  // =============================================
  // ENGAGEMENT METRICS
  // =============================================

  /// מדדי מעורבות - לייקים, שיתופים, תגובות
  /// Engagement metrics - likes, shares, comments
  static Future<Map<String, dynamic>> getEngagementMetrics({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final response = await _client.rpc('get_engagement_metrics', params: {
        'start_date': dateFrom.toIso8601String(),
        'end_date': dateTo.toIso8601String(),
      });

      return {
        'total_likes': response['total_likes'] ?? 0,
        'total_shares': response['total_shares'] ?? 0,
        'total_comments': response['total_comments'] ?? 0,
        'engagement_rate': response['engagement_rate'] ?? 0.0,
        'content_engagement': response['content_engagement'] ?? [],
        'user_engagement': response['user_engagement'] ?? [],
        'engagement_trends': response['engagement_trends'] ?? [],
        'most_engaging_content': response['most_engaging_content'] ?? [],
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת מדדי מעורבות: $e');
    }
  }

  // =============================================
  // DEVICE ANALYTICS
  // =============================================

  /// אנליטיקת מכשירים
  /// Device analytics
  static Future<Map<String, dynamic>> getDeviceAnalytics() async {
    try {
      final response = await _client.rpc('get_device_analytics');

      return {
        'device_types': response['device_types'] ?? {},
        'os_versions': response['os_versions'] ?? {},
        'screen_sizes': response['screen_sizes'] ?? {},
        'app_versions': response['app_versions'] ?? {},
        'browser_types': response['browser_types'] ?? {},
        'connection_types': response['connection_types'] ?? {},
        'device_performance': response['device_performance'] ?? {},
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת אנליטיקת מכשירים: $e');
    }
  }

  // =============================================
  // GEOGRAPHIC ANALYTICS
  // =============================================

  /// אנליטיקה גיאוגרפית
  /// Geographic analytics
  static Future<Map<String, dynamic>> getGeographicAnalytics() async {
    try {
      final response = await _client.rpc('get_geographic_analytics');

      return {
        'countries': response['countries'] ?? {},
        'cities': response['cities'] ?? {},
        'regions': response['regions'] ?? {},
        'timezone_distribution': response['timezone_distribution'] ?? {},
        'language_preferences': response['language_preferences'] ?? {},
        'geographic_trends': response['geographic_trends'] ?? [],
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת אנליטיקה גיאוגרפית: $e');
    }
  }

  // =============================================
  // CONVERSION FUNNELS
  // =============================================

  /// ניתוח משפכי המרה
  /// Conversion funnel analysis
  static Future<Map<String, dynamic>> getConversionFunnels() async {
    try {
      final response = await _client.rpc('get_conversion_funnels');

      return {
        'registration_funnel': response['registration_funnel'] ?? [],
        'tutorial_completion_funnel': response['tutorial_completion_funnel'] ?? [],
        'engagement_funnel': response['engagement_funnel'] ?? [],
        'retention_funnel': response['retention_funnel'] ?? [],
        'conversion_rates': response['conversion_rates'] ?? {},
        'drop_off_points': response['drop_off_points'] ?? [],
      };
    } catch (e) {
      throw Exception('שגיאה בטעינת משפכי המרה: $e');
    }
  }

  // =============================================
  // DATA EXPORT
  // =============================================

  /// ייצוא נתונים
  /// Export analytics data
  static Future<String> exportAnalyticsData({
    required DateTime dateFrom,
    required DateTime dateTo,
    required String format, // 'csv' or 'json'
    List<String>? metrics,
  }) async {
    try {
      final response = await _client.rpc('export_analytics_data', params: {
        'start_date': dateFrom.toIso8601String(),
        'end_date': dateTo.toIso8601String(),
        'export_format': format.toLowerCase(),
        'selected_metrics': metrics,
      });

      if (format.toLowerCase() == 'csv') {
        return _convertToCSV(response);
      } else {
        return jsonEncode(response);
      }
    } catch (e) {
      throw Exception('שגיאה בייצוא נתונים: $e');
    }
  }

  // =============================================
  // CUSTOM METRICS
  // =============================================

  /// מדדים מותאמים אישית
  /// Custom analytics queries
  static Future<dynamic> getCustomMetrics({
    required String metricName,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _client.rpc('get_custom_metrics', params: {
        'metric_name': metricName,
        'filters': filters ?? {},
      });

      return response;
    } catch (e) {
      throw Exception('שגיאה בטעינת מדדים מותאמים: $e');
    }
  }

  // =============================================
  // HELPER METHODS
  // =============================================

  /// מספר המשתמשים הכולל
  static Future<int> _getTotalUsers() async {
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select('id')
        .eq('is_active', true)
        .count();
    return response.count;
  }

  /// משתמשים פעילים (30 ימים)
  static Future<int> _getActiveUsers() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final response = await _client
        .from(SupabaseConfig.analyticsTable)
        .select('user_id')
        .gte('created_at', thirtyDaysAgo.toIso8601String())
        .not('user_id', 'is', null)
        .count();
    return response.count;
  }

  /// מספר המדריכים הכולל
  static Future<int> _getTotalTutorials() async {
    final response = await _client
        .from(SupabaseConfig.tutorialsTable)
        .select('id')
        .eq('is_published', true)
        .count();
    return response.count;
  }

  /// צפיות במדריכים (30 ימים)
  static Future<int> _getTutorialViews() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final response = await _client
        .from(SupabaseConfig.analyticsTable)
        .select('id')
        .eq('event_type', 'tutorial_view')
        .gte('created_at', thirtyDaysAgo.toIso8601String())
        .count();
    return response.count;
  }

  /// מספר תמונות בגלריה
  static Future<int> _getGalleryImages() async {
    final response = await _client
        .from(SupabaseConfig.galleryItemsTable)
        .select('id')
        .eq('is_published', true)
        .count();
    return response.count;
  }

  /// עדכונים שפורסמו
  static Future<int> _getPublishedUpdates() async {
    final response = await _client
        .from(SupabaseConfig.updatesTable)
        .select('id')
        .eq('is_active', true)
        .count();
    return response.count;
  }

  /// שיעור השלמת מדריכים
  static Future<double> _getCompletionRate() async {
    final response = await _client.rpc('calculate_completion_rate');
    return (response ?? 0.0).toDouble();
  }

  /// הרשמות חדשות (7 ימים)
  static Future<int> _getNewSignups() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select('id')
        .gte('created_at', sevenDaysAgo.toIso8601String())
        .count();
    return response.count;
  }

  /// התפלגות משתמשים לפי תפקיד
  static Future<Map<String, int>> _getUsersByRole() async {
    final response = await _client.rpc('get_users_by_role');
    return Map<String, int>.from(response ?? {});
  }

  /// שימוש יומי (7 ימים)
  static Future<List<DailyUsageStats>> _getDailyUsage() async {
    final response = await _client.rpc('get_daily_usage_stats');
    return (response as List? ?? [])
        .map((json) => DailyUsageStats.fromJson(json))
        .toList();
  }

  /// מדריכים פופולריים
  static Future<List<PopularTutorial>> _getPopularTutorials() async {
    final response = await _client.rpc('get_popular_tutorials');
    return (response as List? ?? [])
        .map((json) => PopularTutorial.fromJson(json))
        .toList();
  }

  /// צמיחת משתמשים
  static Future<Map<String, dynamic>> _getUserGrowth(
      DateTime from, DateTime to) async {
    final response = await _client.rpc('get_user_growth', params: {
      'start_date': from.toIso8601String(),
      'end_date': to.toIso8601String(),
    });
    return Map<String, dynamic>.from(response ?? {});
  }

  /// פעילות משתמשים
  static Future<Map<String, dynamic>> _getUserActivity(
      DateTime from, DateTime to) async {
    final response = await _client.rpc('get_user_activity', params: {
      'start_date': from.toIso8601String(),
      'end_date': to.toIso8601String(),
    });
    return Map<String, dynamic>.from(response ?? {});
  }

  /// מעורבות משתמשים
  static Future<Map<String, dynamic>> _getUserEngagement(
      DateTime from, DateTime to) async {
    final response = await _client.rpc('get_user_engagement', params: {
      'start_date': from.toIso8601String(),
      'end_date': to.toIso8601String(),
    });
    return Map<String, dynamic>.from(response ?? {});
  }

  /// דמוגרפיה
  static Future<Map<String, dynamic>> _getUserDemographics() async {
    final response = await _client.rpc('get_user_demographics');
    return Map<String, dynamic>.from(response ?? {});
  }

  /// שיעורי שימור
  static Future<Map<String, dynamic>> _getUserRetentionRates(
      DateTime from, DateTime to) async {
    final response = await _client.rpc('get_user_retention_rates', params: {
      'start_date': from.toIso8601String(),
      'end_date': to.toIso8601String(),
    });
    return Map<String, dynamic>.from(response ?? {});
  }

  /// המרה ל-CSV
  static String _convertToCSV(dynamic data) {
    if (data is! List) return '';
    
    if (data.isEmpty) return '';
    
    final headers = (data.first as Map<String, dynamic>).keys.toList();
    final csvLines = <String>[headers.join(',')];
    
    for (final row in data) {
      final values = headers.map((header) {
        final value = row[header]?.toString() ?? '';
        // Escape quotes and wrap in quotes if contains comma
        return value.contains(',') ? '"${value.replaceAll('"', '""')}"' : value;
      }).toList();
      csvLines.add(values.join(','));
    }
    
    return csvLines.join('\n');
  }

  /// קבלת סטטיסטיקות תוכן עבור פאנל ניהול התוכן
  /// Get content statistics for content management panel
  static Future<Map<String, dynamic>> getContentStatistics() async {
    try {
      // Get real statistics from database
      final futures = await Future.wait([
        _getTotalTutorials(),
        _getTutorialViews(),
        _getGalleryImages(),
        _getPublishedUpdates(),
      ]);

      return {
        'total_tutorials': futures[0],
        'tutorials_this_week': await _getTutorialsThisWeek(),
        'tutorial_views': futures[1],
        'tutorial_likes': await _getTutorialLikes(),
        'gallery_images': futures[2],
        'gallery_videos': await _getGalleryVideos(),
        'gallery_items_today': await _getGalleryItemsToday(),
        'storage_used': await _getStorageUsed(),
        'total_updates': futures[3],
        'active_updates': futures[3], // Same as total for now
        'updates_this_week': await _getUpdatesThisWeek(),
        'update_views': await _getUpdateViews(),
      };
    } catch (e) {
      throw Exception('Failed to load content statistics from database');
    }
  }

  /// ניקוי cache
  static void clearCache() {
    _cache.clear();
  }

  /// ניקוי cache פג תוקף
  static void _cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, item) => item.isExpired);
  }

  /// מדריכים שנוספו השבוע
  static Future<int> _getTutorialsThisWeek() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final response = await _client
        .from(SupabaseConfig.tutorialsTable)
        .select('id')
        .eq('is_published', true)
        .gte('created_at', sevenDaysAgo.toIso8601String())
        .count();
    return response.count;
  }

  /// סך לייקים של מדריכים
  static Future<int> _getTutorialLikes() async {
    final response = await _client
        .from(SupabaseConfig.likesTable)
        .select('id')
        .eq('content_type', 'tutorial')
        .count();
    return response.count;
  }

  /// סרטונים בגלריה
  static Future<int> _getGalleryVideos() async {
    final response = await _client
        .from(SupabaseConfig.galleryItemsTable)
        .select('id')
        .eq('is_published', true)
        .eq('media_type', 'video')
        .count();
    return response.count;
  }

  /// פריטי גלריה שנוספו היום
  static Future<int> _getGalleryItemsToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final response = await _client
        .from(SupabaseConfig.galleryItemsTable)
        .select('id')
        .eq('is_published', true)
        .gte('created_at', startOfDay.toIso8601String())
        .count();
    return response.count;
  }

  /// שטח אחסון בשימוש (במגה-בתים)
  static Future<double> _getStorageUsed() async {
    try {
      // חישוב גודל האחסון מכל הטבלאות הרלוונטיות
      final response = await _client.rpc('calculate_storage_usage');
      return (response ?? 0.0).toDouble();
    } catch (e) {
      // Fallback - מחזיר ערך קבוע אם אין stored procedure
      return 0.0;
    }
  }

  /// עדכונים שנוספו השבוע
  static Future<int> _getUpdatesThisWeek() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final response = await _client
        .from(SupabaseConfig.updatesTable)
        .select('id')
        .eq('is_active', true)
        .gte('created_at', sevenDaysAgo.toIso8601String())
        .count();
    return response.count;
  }

  /// צפיות בעדכונים
  static Future<int> _getUpdateViews() async {
    final response = await _client
        .from(SupabaseConfig.analyticsTable)
        .select('id')
        .eq('event_type', 'update_view')
        .count();
    return response.count;
  }
}

/// פריט cache פנימי
class _CacheItem {
  final dynamic data;
  final DateTime createdAt;

  _CacheItem(this.data, this.createdAt);

  bool get isExpired =>
      DateTime.now().difference(createdAt) > AdminAnalyticsService._cacheTtl;
}

/// מודלים נוספים לאנליטיקה
/// Additional analytics models

/// מודל אנליטיקת התקן
class DeviceAnalyticsModel {
  final String deviceType;
  final String osVersion;
  final String screenSize;
  final int userCount;
  final double performanceScore;

  const DeviceAnalyticsModel({
    required this.deviceType,
    required this.osVersion,
    required this.screenSize,
    required this.userCount,
    required this.performanceScore,
  });

  factory DeviceAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DeviceAnalyticsModel(
      deviceType: json['device_type'] ?? '',
      osVersion: json['os_version'] ?? '',
      screenSize: json['screen_size'] ?? '',
      userCount: json['user_count'] ?? 0,
      performanceScore: (json['performance_score'] ?? 0.0).toDouble(),
    );
  }
}

/// מודל מעורבות תוכן
class ContentEngagementModel {
  final String contentId;
  final String contentType;
  final String title;
  final int views;
  final int likes;
  final int shares;
  final double engagementRate;
  final DateTime lastEngagement;

  const ContentEngagementModel({
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.views,
    required this.likes,
    required this.shares,
    required this.engagementRate,
    required this.lastEngagement,
  });

  factory ContentEngagementModel.fromJson(Map<String, dynamic> json) {
    return ContentEngagementModel(
      contentId: json['content_id'] ?? '',
      contentType: json['content_type'] ?? '',
      title: json['title'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0.0).toDouble(),
      lastEngagement: DateTime.parse(json['last_engagement'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// מודל נתוני ביצועים
class PerformanceDataModel {
  final double avgLoadTime;
  final double errorRate;
  final double crashRate;
  final Map<String, double> apiResponseTimes;
  final List<String> slowQueries;
  final DateTime measuredAt;

  const PerformanceDataModel({
    required this.avgLoadTime,
    required this.errorRate,
    required this.crashRate,
    required this.apiResponseTimes,
    required this.slowQueries,
    required this.measuredAt,
  });

  factory PerformanceDataModel.fromJson(Map<String, dynamic> json) {
    return PerformanceDataModel(
      avgLoadTime: (json['avg_load_time'] ?? 0.0).toDouble(),
      errorRate: (json['error_rate'] ?? 0.0).toDouble(),
      crashRate: (json['crash_rate'] ?? 0.0).toDouble(),
      apiResponseTimes: Map<String, double>.from(json['api_response_times'] ?? {}),
      slowQueries: List<String>.from(json['slow_queries'] ?? []),
      measuredAt: DateTime.parse(json['measured_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}