import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Advanced cache management service for optimal performance
class CacheService {
  static const String _imageCacheKey = 'zaza_image_cache';
  static const String _videoCacheKey = 'zaza_video_cache';
  static const String _thumbnailCacheKey = 'zaza_thumbnail_cache';
  
  static const Duration _defaultMaxAge = Duration(days: 30);
  static const Duration _thumbnailMaxAge = Duration(days: 7);
  static const int _maxCacheObjects = 200;
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB

  late final CacheManager _imageCache;
  late final CacheManager _videoCache;
  late final CacheManager _thumbnailCache;

  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// Initialize cache managers
  Future<void> initialize() async {
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

      if (kDebugMode) {
        print('CacheService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing CacheService: $e');
      }
    }
  }

  /// Get image cache manager
  CacheManager get imageCache => _imageCache;

  /// Get video cache manager  
  CacheManager get videoCache => _videoCache;

  /// Get thumbnail cache manager
  CacheManager get thumbnailCache => _thumbnailCache;

  /// Preload important images for faster loading
  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      final futures = imageUrls.map((url) => _imageCache.downloadFile(url));
      await Future.wait(futures);
      
      if (kDebugMode) {
        print('Preloaded ${imageUrls.length} images');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading images: $e');
      }
    }
  }

  /// Preload thumbnails for galleries
  Future<void> preloadThumbnails(List<String> thumbnailUrls) async {
    try {
      final futures = thumbnailUrls.map((url) => _thumbnailCache.downloadFile(url));
      await Future.wait(futures);
      
      if (kDebugMode) {
        print('Preloaded ${thumbnailUrls.length} thumbnails');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading thumbnails: $e');
      }
    }
  }

  /// Download video for offline viewing
  Future<File?> downloadVideoForOffline(String videoUrl) async {
    try {
      final fileInfo = await _videoCache.downloadFile(videoUrl);
      
      if (kDebugMode) {
        print('Downloaded video for offline: $videoUrl');
      }
      
      return fileInfo.file;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading video: $e');
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
      final imageInfo = await _getManagerCacheSize(_imageCache);
      final videoInfo = await _getManagerCacheSize(_videoCache);
      final thumbnailInfo = await _getManagerCacheSize(_thumbnailCache);

      return CacheInfo(
        totalSize: imageInfo.size + videoInfo.size + thumbnailInfo.size,
        imageSize: imageInfo.size,
        videoSize: videoInfo.size,
        thumbnailSize: thumbnailInfo.size,
        totalFiles: imageInfo.files + videoInfo.files + thumbnailInfo.files,
        imageFiles: imageInfo.files,
        videoFiles: videoInfo.files,
        thumbnailFiles: thumbnailInfo.files,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cache info: $e');
      }
      return CacheInfo.empty();
    }
  }

  Future<_ManagerCacheInfo> _getManagerCacheSize(CacheManager manager) async {
    try {
      // Get cache directory info
      final cacheDir = await manager.getTemporaryDirectory();
      int totalSize = 0;
      int fileCount = 0;
      
      if (await cacheDir.exists()) {
        final files = await cacheDir.list(recursive: true).toList();
        
        for (final entity in files) {
          if (entity is File) {
            try {
              final size = await entity.length();
              totalSize += size;
              fileCount++;
            } catch (e) {
              // Skip files that can't be read
            }
          }
        }
      }
      
      return _ManagerCacheInfo(size: totalSize, files: fileCount);
    } catch (e) {
      return _ManagerCacheInfo(size: 0, files: 0);
    }
  }

  /// Clear specific cache
  Future<void> clearImageCache() async {
    try {
      await _imageCache.emptyCache();
      if (kDebugMode) {
        print('Image cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing image cache: $e');
      }
    }
  }

  Future<void> clearVideoCache() async {
    try {
      await _videoCache.emptyCache();
      if (kDebugMode) {
        print('Video cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing video cache: $e');
      }
    }
  }

  Future<void> clearThumbnailCache() async {
    try {
      await _thumbnailCache.emptyCache();
      if (kDebugMode) {
        print('Thumbnail cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing thumbnail cache: $e');
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
        print('Old cache entries cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old cache: $e');
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

class _ManagerCacheInfo {
  final int size;
  final int files;

  const _ManagerCacheInfo({
    required this.size,
    required this.files,
  });
}