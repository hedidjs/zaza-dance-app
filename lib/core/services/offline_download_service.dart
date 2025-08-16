import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/models/tutorial_model.dart';

/// Service for downloading tutorials for offline viewing
/// According to PRD: Download capability for practice without internet
class OfflineDownloadService {
  static final OfflineDownloadService _instance = OfflineDownloadService._internal();
  factory OfflineDownloadService() => _instance;
  OfflineDownloadService._internal();

  static const String _downloadKey = 'tutorial_downloads';
  late final CacheManager _cacheManager;
  bool _isInitialized = false;

  /// Initialize the download service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize custom cache manager for large video files
      _cacheManager = CacheManager(
        Config(
          _downloadKey,
          stalePeriod: const Duration(days: 30), // Keep downloads for 30 days
          maxNrOfCacheObjects: 50, // Max 50 downloaded tutorials
          repo: JsonCacheInfoRepository(databaseName: _downloadKey),
          fileService: HttpFileService(),
        ),
      );

      _isInitialized = true;
      if (kDebugMode) {
        print('OfflineDownloadService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OfflineDownloadService: $e');
      }
    }
  }

  /// Check if storage permission is granted
  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final permission = await Permission.storage.status;
      if (!permission.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  /// Download tutorial for offline viewing
  Future<DownloadResult> downloadTutorial(TutorialModel tutorial) async {
    if (!_isInitialized) await initialize();

    try {
      // Check permissions
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        return DownloadResult.error('Storage permission required');
      }

      // Check if already downloaded
      if (await isTutorialDownloaded(tutorial.id)) {
        return DownloadResult.alreadyExists('Tutorial already downloaded');
      }

      // Start download
      if (kDebugMode) {
        print('Starting download for tutorial: ${tutorial.titleHe}');
      }

      final file = await _cacheManager.downloadFile(
        tutorial.videoUrl,
        key: _getTutorialKey(tutorial.id),
        authHeaders: {}, // Add auth headers if needed
      );

      // Also download thumbnail if available
      if (tutorial.thumbnailUrl != null) {
        await _cacheManager.downloadFile(
          tutorial.thumbnailUrl!,
          key: _getThumbnailKey(tutorial.id),
        );
      }

      // Save tutorial metadata
      await _saveTutorialMetadata(tutorial);

      if (kDebugMode) {
        print('Tutorial downloaded successfully: ${file.file.path}');
      }

      return DownloadResult.success(file.file.path);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading tutorial: $e');
      }
      return DownloadResult.error('Download failed: $e');
    }
  }

  /// Check if tutorial is downloaded
  Future<bool> isTutorialDownloaded(String tutorialId) async {
    if (!_isInitialized) await initialize();

    try {
      final fileInfo = await _cacheManager.getFileFromCache(_getTutorialKey(tutorialId));
      return fileInfo != null && fileInfo.file.existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Get downloaded tutorial file path
  Future<String?> getDownloadedTutorialPath(String tutorialId) async {
    if (!_isInitialized) await initialize();

    try {
      final fileInfo = await _cacheManager.getFileFromCache(_getTutorialKey(tutorialId));
      return fileInfo?.file.path;
    } catch (e) {
      return null;
    }
  }

  /// Get downloaded thumbnail path
  Future<String?> getDownloadedThumbnailPath(String tutorialId) async {
    if (!_isInitialized) await initialize();

    try {
      final fileInfo = await _cacheManager.getFileFromCache(_getThumbnailKey(tutorialId));
      return fileInfo?.file.path;
    } catch (e) {
      return null;
    }
  }

  /// Delete downloaded tutorial
  Future<bool> deleteTutorial(String tutorialId) async {
    if (!_isInitialized) await initialize();

    try {
      // Remove video file
      await _cacheManager.removeFile(_getTutorialKey(tutorialId));
      
      // Remove thumbnail file
      await _cacheManager.removeFile(_getThumbnailKey(tutorialId));
      
      // Remove metadata
      await _removeTutorialMetadata(tutorialId);

      if (kDebugMode) {
        print('Tutorial deleted successfully: $tutorialId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting tutorial: $e');
      }
      return false;
    }
  }

  /// Get all downloaded tutorials
  Future<List<String>> getDownloadedTutorialIds() async {
    if (!_isInitialized) await initialize();

    try {
      // This is a simplified implementation
      // In a real app, you'd store this list in SharedPreferences or local database
      final directory = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${directory.path}/tutorial_metadata');
      
      if (!metadataDir.existsSync()) {
        return [];
      }

      final files = metadataDir.listSync();
      return files
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path.split('/').last.replaceAll('.json', ''))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting downloaded tutorials: $e');
      }
      return [];
    }
  }

  /// Get download progress for a tutorial (0.0 to 1.0)
  Stream<double> getDownloadProgress(String tutorialId) {
    // This would be implemented with a more advanced download manager
    // For now, return a simple stream
    return Stream.periodic(const Duration(milliseconds: 100), (count) {
      return (count * 0.1).clamp(0.0, 1.0);
    }).take(11);
  }

  /// Get total size of downloaded tutorials in bytes
  Future<int> getTotalDownloadSize() async {
    if (!_isInitialized) await initialize();

    try {
      int totalSize = 0;
      final downloadedIds = await getDownloadedTutorialIds();
      
      for (final id in downloadedIds) {
        final filePath = await getDownloadedTutorialPath(id);
        if (filePath != null) {
          final file = File(filePath);
          if (file.existsSync()) {
            totalSize += await file.length();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    if (!_isInitialized) await initialize();

    try {
      await _cacheManager.emptyCache();
      
      // Also clear metadata
      final directory = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${directory.path}/tutorial_metadata');
      if (metadataDir.existsSync()) {
        await metadataDir.delete(recursive: true);
      }

      if (kDebugMode) {
        print('All downloads cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing downloads: $e');
      }
    }
  }

  /// Helper methods
  String _getTutorialKey(String tutorialId) => 'tutorial_$tutorialId';
  String _getThumbnailKey(String tutorialId) => 'thumbnail_$tutorialId';

  /// Save tutorial metadata for offline access
  Future<void> _saveTutorialMetadata(TutorialModel tutorial) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${directory.path}/tutorial_metadata');
      
      if (!metadataDir.existsSync()) {
        await metadataDir.create(recursive: true);
      }

      final file = File('${metadataDir.path}/${tutorial.id}.json');
      await file.writeAsString(tutorial.toJson().toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tutorial metadata: $e');
      }
    }
  }

  /// Remove tutorial metadata
  Future<void> _removeTutorialMetadata(String tutorialId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tutorial_metadata/$tutorialId.json');
      
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing tutorial metadata: $e');
      }
    }
  }
}

/// Result of a download operation
class DownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;

  DownloadResult._(this.isSuccess, this.filePath, this.errorMessage);

  factory DownloadResult.success(String filePath) {
    return DownloadResult._(true, filePath, null);
  }

  factory DownloadResult.error(String errorMessage) {
    return DownloadResult._(false, null, errorMessage);
  }

  factory DownloadResult.alreadyExists(String message) {
    return DownloadResult._(true, null, message);
  }
}

/// Download status for UI
enum DownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  error,
}