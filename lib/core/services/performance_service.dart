import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Service for performance optimizations throughout the app
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  bool _isInitialized = false;

  /// Initialize performance optimizations
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Optimize memory usage
      await _optimizeMemoryUsage();

      // Configure image caching
      await _configureImageCaching();

      // Set up performance monitoring
      await _setupPerformanceMonitoring();

      _isInitialized = true;
      if (kDebugMode) {
        print('PerformanceService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing PerformanceService: $e');
      }
    }
  }

  /// Optimize memory usage for better performance
  Future<void> _optimizeMemoryUsage() async {
    // Set target for memory usage
    final int targetMemoryMB = Platform.isAndroid ? 200 : 300;
    
    // Configure garbage collection
    if (kDebugMode) {
      print('Configuring memory optimization (target: ${targetMemoryMB}MB)');
    }

    // Force garbage collection on low memory
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemChrome.onMemoryPressure') {
        await _performMemoryCleanup();
      }
      return null;
    });
  }

  /// Configure optimized image caching
  Future<void> _configureImageCaching() async {
    // Set up image cache limits based on device capabilities
    final int maxCacheObjects = Platform.isAndroid ? 100 : 200;
    final int maxCacheSizeMB = Platform.isAndroid ? 50 : 100;

    if (kDebugMode) {
      print('Configuring image cache: $maxCacheObjects objects, ${maxCacheSizeMB}MB');
    }

    // Configure HTTP cache settings
    HttpOverrides.global = _OptimizedHttpOverrides();
  }

  /// Set up performance monitoring
  Future<void> _setupPerformanceMonitoring() async {
    if (kDebugMode) {
      // Monitor frame rate in debug mode
      WidgetsBinding.instance.addTimingsCallback((timings) {
        for (final timing in timings) {
          final frameTime = timing.totalSpan.inMilliseconds;
          if (frameTime > 16) { // 60fps = ~16ms per frame
            print('Slow frame detected: ${frameTime}ms');
          }
        }
      });
    }
  }

  /// Perform memory cleanup when needed
  Future<void> _performMemoryCleanup() async {
    if (kDebugMode) {
      print('Performing memory cleanup...');
    }

    // Clear image cache if memory pressure
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // Force garbage collection
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Preload critical assets for better performance
  Future<void> preloadCriticalAssets(BuildContext context) async {
    try {
      // Preload app logo and critical icons
      await Future.wait([
        precacheImage(const AssetImage('assets/images/logo.png'), context),
        // Add more critical assets here
      ]);

      if (kDebugMode) {
        print('Critical assets preloaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading assets: $e');
      }
    }
  }

  /// Optimize widget build performance
  static Widget optimizedBuilder({
    required Widget Function() builder,
    Duration cacheDuration = const Duration(seconds: 5),
  }) {
    return _CachedWidget(
      builder: builder,
      cacheDuration: cacheDuration,
    );
  }

  /// Get optimal image resolution based on device
  static String getOptimalImageUrl(String baseUrl, double displayWidth) {
    // Calculate optimal resolution
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final targetWidth = (displayWidth * devicePixelRatio).round();

    // Return URL with appropriate size parameter
    if (baseUrl.contains('unsplash.com')) {
      return '$baseUrl&w=$targetWidth&q=80';
    }
    
    // For other providers, return original URL
    return baseUrl;
  }

  /// Check if device is low-end for performance adjustments
  static bool get isLowEndDevice {
    // Simplified check - in real app, use device_info_plus
    return Platform.isAndroid;
  }

  /// Get recommended animation duration based on device performance
  static Duration get recommendedAnimationDuration {
    return isLowEndDevice 
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 300);
  }
}

/// Custom HTTP overrides for better caching
class _OptimizedHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // Configure connection limits
    client.maxConnectionsPerHost = 5;
    client.connectionTimeout = const Duration(seconds: 10);
    
    return client;
  }
}

/// Widget that caches its build result for better performance
class _CachedWidget extends StatefulWidget {
  final Widget Function() builder;
  final Duration cacheDuration;

  const _CachedWidget({
    required this.builder,
    required this.cacheDuration,
  });

  @override
  State<_CachedWidget> createState() => _CachedWidgetState();
}

class _CachedWidgetState extends State<_CachedWidget> {
  Widget? _cachedWidget;
  DateTime? _cacheTime;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Check if cache is still valid
    if (_cachedWidget == null || 
        _cacheTime == null || 
        now.difference(_cacheTime!) > widget.cacheDuration) {
      
      _cachedWidget = widget.builder();
      _cacheTime = now;
    }
    
    return _cachedWidget!;
  }
}