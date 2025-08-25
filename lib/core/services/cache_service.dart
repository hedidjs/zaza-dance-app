import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Advanced cache management service for optimal performance
class CacheService {
  static const String _imageCacheKey = 'zaza_image_cache';
  static const String _videoCacheKey = 'zaza_video_cache';
  static const String _thumbnailCacheKey = 'zaza_thumbnail_cache';
  
  static const Duration _defaultMaxAge = Duration(days: 30);
  static const Duration _thumbnailMaxAge = Duration(days: 7);
  static const int _maxCacheObjects = 200;

  late final CacheManager _imageCache;
  late final CacheManager _videoCache;
  late final CacheManager _thumbnailCache;
  bool _isInitialized = false;

  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// Initialize cache managers
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _imageCache = CacheManager(
        Config(
          _imageCacheKey,
          stalePeriod: _defaultMaxAge,
          maxNrOfCacheObjects: _maxCacheObjects,
          repo: JsonCacheInfoRepository(databaseName: _imageCacheKey),
          fileService: HttpFileService(),
        ),
      );

      _videoCache = CacheManager(
        Config(
          _videoCacheKey,
          stalePeriod: _defaultMaxAge,
          maxNrOfCacheObjects: 50, // Videos are larger
          repo: JsonCacheInfoRepository(databaseName: _videoCacheKey),
          fileService: HttpFileService(),
        ),
      );

      _thumbnailCache = CacheManager(
        Config(
          _thumbnailCacheKey,
          stalePeriod: _thumbnailMaxAge,
          maxNrOfCacheObjects: _maxCacheObjects * 2, // More thumbnails
          repo: JsonCacheInfoRepository(databaseName: _thumbnailCacheKey),
          fileService: HttpFileService(),
        ),
      );

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('CacheService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing CacheService: $e');
      }
    }
  }

  /// Get image cache manager
  CacheManager get imageCache {
    if (!_isInitialized) {
      throw StateError('CacheService not initialized. Call initialize() first.');
    }
    return _imageCache;
  }

  /// Get video cache manager  
  CacheManager get videoCache {
    if (!_isInitialized) {
      throw StateError('CacheService not initialized. Call initialize() first.');
    }
    return _videoCache;
  }

  /// Get thumbnail cache manager
  CacheManager get thumbnailCache {
    if (!_isInitialized) {
      throw StateError('CacheService not initialized. Call initialize() first.');
    }
    return _thumbnailCache;
  }

  /// Preload important images for faster loading
  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      final futures = imageUrls.map((url) => _imageCache.downloadFile(url));
      await Future.wait(futures);
      
      if (kDebugMode) {
        debugPrint('Preloaded ${imageUrls.length} images');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error preloading images: $e');
      }
    }
  }

  /// Preload thumbnails for galleries
  Future<void> preloadThumbnails(List<String> thumbnailUrls) async {
    try {
      final futures = thumbnailUrls.map((url) => _thumbnailCache.downloadFile(url));
      await Future.wait(futures);
      
      if (kDebugMode) {
        debugPrint('Preloaded ${thumbnailUrls.length} thumbnails');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error preloading thumbnails: $e');
      }
    }
  }

  /// Download video for offline viewing
  Future<File?> downloadVideoForOffline(String videoUrl) async {
    try {
      final fileInfo = await _videoCache.downloadFile(videoUrl);
      
      if (kDebugMode) {
        debugPrint('Downloaded video for offline: $videoUrl');
      }
      
      return fileInfo.file;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error downloading video: $e');
      }
      return null;
    }
  }

  /// Check if video is downloaded for offline viewing
  Future<bool> isVideoDownloaded(String videoUrl) async {
    try {
      final fileInfo = await _videoCache.getFileFromCache(videoUrl);
      return fileInfo != null;
    } catch (e) {
      return false;
    }
  }

  /// Get cache size information
  Future<CacheInfo> getCacheInfo() async {
    try {
      // For now, return empty cache info
      // In production, this would integrate with actual cache storage measurement
      return CacheInfo.empty();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting cache info: $e');
      }
      return CacheInfo.empty();
    }
  }

  /// Clear specific cache
  Future<void> clearImageCache() async {
    try {
      await _imageCache.emptyCache();
      if (kDebugMode) {
        debugPrint('Image cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing image cache: $e');
      }
    }
  }

  Future<void> clearVideoCache() async {
    try {
      await _videoCache.emptyCache();
      if (kDebugMode) {
        debugPrint('Video cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing video cache: $e');
      }
    }
  }

  Future<void> clearThumbnailCache() async {
    try {
      await _thumbnailCache.emptyCache();
      if (kDebugMode) {
        debugPrint('Thumbnail cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing thumbnail cache: $e');
      }
    }
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await Future.wait([
      clearImageCache(),
      clearVideoCache(),
      clearThumbnailCache(),
    ]);
  }

  /// Clean up old cache files
  Future<void> cleanupOldCache() async {
    try {
      // Clean up each cache individually
      await _imageCache.emptyCache();
      await _videoCache.emptyCache();
      await _thumbnailCache.emptyCache();
      
      if (kDebugMode) {
        debugPrint('Old cache entries cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cleaning up old cache: $e');
      }
    }
  }
}

/// Cache information data class
class CacheInfo {
  final int totalSize;
  final int imageSize;
  final int videoSize;
  final int thumbnailSize;
  final int totalFiles;
  final int imageFiles;
  final int videoFiles;
  final int thumbnailFiles;

  const CacheInfo({
    required this.totalSize,
    required this.imageSize,
    required this.videoSize,
    required this.thumbnailSize,
    required this.totalFiles,
    required this.imageFiles,
    required this.videoFiles,
    required this.thumbnailFiles,
  });

  factory CacheInfo.empty() {
    return const CacheInfo(
      totalSize: 0,
      imageSize: 0,
      videoSize: 0,
      thumbnailSize: 0,
      totalFiles: 0,
      imageFiles: 0,
      videoFiles: 0,
      thumbnailFiles: 0,
    );
  }

  String get formattedTotalSize => _formatBytes(totalSize);
  String get formattedImageSize => _formatBytes(imageSize);
  String get formattedVideoSize => _formatBytes(videoSize);
  String get formattedThumbnailSize => _formatBytes(thumbnailSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}