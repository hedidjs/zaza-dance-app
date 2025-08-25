import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Advanced performance optimization service for Zaza Dance app
class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = 
      PerformanceOptimizationService._internal();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._internal();

  bool _isInitialized = false;
  
  // Performance metrics
  final Map<String, Duration> _loadTimes = {};
  final Map<String, int> _memoryUsage = {};
  
  // Cache configuration
  static const int _maxImageCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB
  
  /// Initialize all performance optimizations
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configure image cache
      PaintingBinding.instance.imageCache
        ..maximumSize = 200
        ..maximumSizeBytes = _maxImageCacheSize;
      
      // Set up performance monitoring
      _setupPerformanceMonitoring();
      
      // Configure HTTP optimizations
      _configureHttpOptimizations();
      
      // Set up memory management
      _setupMemoryManagement();
      
      // Configure animation optimizations
      _configureAnimationOptimizations();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('🚀 Performance optimizations initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing performance optimizations: $e');
      }
    }
  }
  
  /// Monitor app performance metrics
  void _setupPerformanceMonitoring() {
    if (kDebugMode) {
      // Monitor frame performance
      WidgetsBinding.instance.addTimingsCallback((timings) {
        for (final timing in timings) {
          final frameTime = timing.totalSpan.inMilliseconds;
          if (frameTime > 16) { // Target 60fps
            debugPrint('⚠️ Slow frame: ${frameTime}ms');
          }
        }
      });
    }
  }
  
  /// Configure HTTP optimizations for Supabase
  void _configureHttpOptimizations() {
    // Set up connection pooling and timeouts
    HttpOverrides.global = _OptimizedHttpOverrides();
  }
  
  /// Set up memory management
  void _setupMemoryManagement() {
    // Schedule periodic memory cleanup
    Timer.periodic(const Duration(minutes: 5), (_) {
      _performMemoryCleanup();
    });
  }
  
  /// Configure animation optimizations
  void _configureAnimationOptimizations() {
    // Reduce animation duration in release mode for better performance
    if (kReleaseMode) {
      timeDilation = 0.8; // Slightly faster animations
    }
  }
  
  /// Perform memory cleanup
  void _performMemoryCleanup() {
    if (kDebugMode) {
      final before = PaintingBinding.instance.imageCache.currentSizeBytes;
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      final after = PaintingBinding.instance.imageCache.currentSizeBytes;
      final cleared = (before - after) / 1024 / 1024;
      debugPrint('🧹 Memory cleanup: ${cleared.toStringAsFixed(2)}MB cleared');
    } else {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }
  }
  
  /// Track page load time
  void startTrackingPageLoad(String pageName) {
    _loadTimes[pageName] = DateTime.now().difference(DateTime.now());
  }
  
  /// End tracking page load time
  void endTrackingPageLoad(String pageName) {
    if (_loadTimes.containsKey(pageName)) {
      final loadTime = DateTime.now().difference(
        DateTime.now().subtract(_loadTimes[pageName]!)
      );
      
      if (kDebugMode) {
        debugPrint('📊 $pageName loaded in ${loadTime.inMilliseconds}ms');
      }
      
      // Alert if page load is too slow
      if (loadTime.inMilliseconds > 1000) {
        if (kDebugMode) {
          debugPrint('⚠️ Slow page load detected for $pageName');
        }
      }
    }
  }
  
  /// Optimize list view performance
  Widget optimizeListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 100.0,
      physics: const BouncingScrollPhysics(),
    );
  }
  
  /// Optimize grid view performance
  Widget optimizeGridView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required int crossAxisCount,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    double? childAspectRatio,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 200.0,
      physics: const BouncingScrollPhysics(),
    );
  }
  
  /// Preload critical assets
  Future<void> preloadAssets(BuildContext context) async {
    try {
      // Preload fonts
      await _preloadFonts();
      
      // Preload critical images
      await _preloadCriticalImages(context);
      
      if (kDebugMode) {
        debugPrint('✅ Critical assets preloaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error preloading assets: $e');
      }
    }
  }
  
  Future<void> _preloadFonts() async {
    // Fonts are loaded automatically via GoogleFonts
  }
  
  Future<void> _preloadCriticalImages(BuildContext context) async {
    // Preload app logo and critical UI images
    final images = [
      'assets/images/logo.png',
      'assets/images/splash_background.png',
    ];
    
    for (final image in images) {
      try {
        await precacheImage(AssetImage(image), context);
      } catch (_) {
        // Image might not exist, continue
      }
    }
  }
  
  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    return {
      'imageCacheSize': '${(imageCache.currentSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB',
      'imageCacheCount': imageCache.currentSize,
      'maxImageCacheSize': '${(_maxImageCacheSize / 1024 / 1024)}MB',
      'maxImageCacheCount': imageCache.maximumSize,
      'loadTimes': _loadTimes.map((k, v) => MapEntry(k, '${v.inMilliseconds}ms')),
    };
  }
}

/// Optimized HTTP overrides for better network performance
class _OptimizedHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // Configure connection settings
    client.connectionTimeout = const Duration(seconds: 30);
    client.idleTimeout = const Duration(seconds: 15);
    client.maxConnectionsPerHost = 10;
    
    // Enable compression
    client.autoUncompress = true;
    
    // Configure certificate validation for development
    if (kDebugMode) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    
    return client;
  }
}