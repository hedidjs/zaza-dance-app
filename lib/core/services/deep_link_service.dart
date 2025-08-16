import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

/// שירות לטיפול ב-Deep Links ו-URL schemes
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  /// אתחול השירות
  Future<void> initialize(GoRouter router) async {
    _router = router;
    
    // טיפול ב-Deep Link הראשוני (כאשר האפליקציה נפתחת מ-link)
    await _handleInitialLink();
    
    // האזנה ל-Deep Links נוספים (כאשר האפליקציה כבר פתוחה)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (err) {
        debugPrint('Deep Link Error: $err');
      },
    );
    
    debugPrint('Deep Link Service initialized');
  }

  /// טיפול ב-link הראשוני שפתח את האפליקציה
  Future<void> _handleInitialLink() async {
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('Initial Link: $initialLink');
        await _processLink(initialLink);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get initial link: ${e.message}');
    }
  }

  /// טיפול ב-link שהתקבל כאשר האפליקציה פתוחה
  void _handleIncomingLink(Uri uri) {
    debugPrint('Incoming Link: $uri');
    _processLink(uri);
  }

  /// עיבוד הלינק והכוונה למקום המתאים באפליקציה
  Future<void> _processLink(Uri uri) async {
    try {
      debugPrint('Processing link: $uri');
      
      // בדיקה אם זה link של אותנטיקציה
      if (_isAuthLink(uri)) {
        await _handleAuthLink(uri);
        return;
      }
      
      // בדיקה אם זה link כללי לאפליקציה
      if (_isAppLink(uri)) {
        _handleAppLink(uri);
        return;
      }
      
      debugPrint('Unknown link type: $uri');
    } catch (e) {
      debugPrint('Error processing link: $e');
    }
  }

  /// בדיקה אם זה link של אותנטיקציה
  bool _isAuthLink(Uri uri) {
    return uri.path.contains('/auth/') || 
           uri.queryParameters.containsKey('code') ||
           uri.queryParameters.containsKey('token') ||
           uri.queryParameters.containsKey('access_token') ||
           uri.queryParameters.containsKey('refresh_token');
  }

  /// בדיקה אם זה link כללי לאפליקציה  
  bool _isAppLink(Uri uri) {
    return uri.scheme == 'com.zazadance.zazaDance' ||
           uri.host == 'zazadance.com' ||
           uri.host == 'www.zazadance.com';
  }

  /// טיפול ב-link של אותנטיקציה
  Future<void> _handleAuthLink(Uri uri) async {
    try {
      debugPrint('Handling auth link: $uri');
      
      final String? code = uri.queryParameters['code'];
      final String? accessToken = uri.queryParameters['access_token'];
      final String? refreshToken = uri.queryParameters['refresh_token'];
      final String? type = uri.queryParameters['type'];
      
      if (code != null) {
        // טיפול ב-authorization code flow
        debugPrint('Processing authorization code: $code');
        
        // Supabase יטפל בזה אוטומטית אם הוגדר נכון
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        
        // ניווט לעמוד הבית לאחר אותנטיקציה מוצלחת
        _router?.go('/');
        
      } else if (accessToken != null && refreshToken != null) {
        // טיפול ב-direct tokens
        debugPrint('Processing tokens directly');
        
        await Supabase.instance.client.auth.setSession(refreshToken);
        _router?.go('/');
        
      } else if (type == 'email_confirmation') {
        // אישור מייל - כבר טופל, פשוט ניווט לעמוד הבית
        debugPrint('Email confirmation handled');
        _router?.go('/');
        
      } else {
        debugPrint('Unknown auth link format');
      }
      
    } catch (e) {
      debugPrint('Error handling auth link: $e');
      // ניווט לעמוד התחברות במקרה של שגיאה
      _router?.go('/login');
    }
  }

  /// טיפול ב-link כללי לאפליקציה
  void _handleAppLink(Uri uri) {
    debugPrint('Handling app link: $uri');
    
    // מיפוי paths שונים לנתיבים באפליקציה
    String route = '/';
    
    switch (uri.path) {
      case '/':
      case '/home':
        route = '/';
        break;
      case '/tutorials':
        route = '/tutorials';
        break;
      case '/gallery':
        route = '/gallery';
        break;
      case '/updates':
        route = '/updates';
        break;
      case '/profile':
        route = '/profile';
        break;
      case '/settings':
        route = '/settings';
        break;
      default:
        // ניווט לעמוד הבית עבור paths לא מוכרים
        route = '/';
        break;
    }
    
    _router?.go(route);
  }

  /// יצירת Deep Link לשיתוף
  String createDeepLink(String path, {Map<String, String>? parameters}) {
    final Uri uri = Uri(
      scheme: 'com.zazadance.zazaDance',
      path: path,
      queryParameters: parameters,
    );
    return uri.toString();
  }

  /// יצירת Web Link לשיתוף
  String createWebLink(String path, {Map<String, String>? parameters}) {
    final Uri uri = Uri(
      scheme: 'https',
      host: 'zazadance.com',
      path: path,
      queryParameters: parameters,
    );
    return uri.toString();
  }

  /// שיתוף תוכן עם Deep Link
  String shareContent(String contentType, String contentId) {
    return createDeepLink('/$contentType/$contentId');
  }

  /// ניקוי משאבים
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}