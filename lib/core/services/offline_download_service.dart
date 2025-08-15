import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/models/tutorial_model.dart';
import 'cache_service.dart';

/// Service for downloading tutorials for offline viewing
class OfflineDownloadService {
  static final OfflineDownloadService _instance = OfflineDownloadService._internal();
  factory OfflineDownloadService() => _instance;
  OfflineDownloadService._internal();

  final Map<String, DownloadProgress> _downloadProgress = {};
  final List<Function(String, DownloadProgress)> _progressListeners = [];

  /// Add progress listener
  void addProgressListener(Function(String, DownloadProgress) listener) {
    _progressListeners.add(listener);
  }

  /// Remove progress listener
  void removeProgressListener(Function(String, DownloadProgress) listener) {
    _progressListeners.remove(listener);
  }

  /// Notify progress listeners
  void _notifyProgressListeners(String tutorialId, DownloadProgress progress) {
    _downloadProgress[tutorialId] = progress;
    for (final listener in _progressListeners) {
      listener(tutorialId, progress);
    }
  }

  /// Check if storage permission is granted
  Future<bool> _checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking storage permission: $e');
      }
      return false;
    }
  }

  /// Download tutorial for offline viewing
  Future<bool> downloadTutorial(TutorialModel tutorial) async {
    if (tutorial.videoUrl.isEmpty) {
      if (kDebugMode) {
        print('Tutorial ${tutorial.id} has no video URL');
      }
      return false;
    }

    // Check if already downloading
    if (_downloadProgress.containsKey(tutorial.id)) {
      final progress = _downloadProgress[tutorial.id]!;
      if (progress.status == DownloadStatus.downloading) {
        if (kDebugMode) {
          print('Tutorial ${tutorial.id} is already downloading');
        }
        return false;
      }
    }

    // Check storage permission
    final hasPermission = await _checkStoragePermission();
    if (!hasPermission) {
      _notifyProgressListeners(tutorial.id, DownloadProgress(
        tutorialId: tutorial.id,
        status: DownloadStatus.failed,
        progress: 0.0,
        error: 'Storage permission denied',
      ));
      return false;
    }

    try {
      // Start download
      _notifyProgressListeners(tutorial.id, DownloadProgress(
        tutorialId: tutorial.id,
        status: DownloadStatus.downloading,
        progress: 0.0,
      ));

      // Download video file
      final videoFile = await _downloadVideoFile(tutorial);
      if (videoFile == null) {
        _notifyProgressListeners(tutorial.id, DownloadProgress(
          tutorialId: tutorial.id,
          status: DownloadStatus.failed,
          progress: 0.0,
          error: 'Failed to download video',
        ));
        return false;
      }

      // Download thumbnail if available
      File? thumbnailFile;
      if (tutorial.thumbnailUrl != null) {
        thumbnailFile = await _downloadThumbnailFile(tutorial);
      }

      // Save tutorial metadata
      await _saveTutorialMetadata(tutorial, videoFile.path, thumbnailFile?.path);

      // Complete download
      _notifyProgressListeners(tutorial.id, DownloadProgress(
        tutorialId: tutorial.id,
        status: DownloadStatus.completed,
        progress: 1.0,
        videoPath: videoFile.path,
        thumbnailPath: thumbnailFile?.path,
      ));

      if (kDebugMode) {
        print('Tutorial ${tutorial.id} downloaded successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading tutorial ${tutorial.id}: $e');
      }

      _notifyProgressListeners(tutorial.id, DownloadProgress(
        tutorialId: tutorial.id,
        status: DownloadStatus.failed,
        progress: 0.0,
        error: e.toString(),
      ));

      return false;
    }
  }

  /// Download video file
  Future<File?> _downloadVideoFile(TutorialModel tutorial) async {
    try {
      if (tutorial.videoUrl.isEmpty) return null;

      final cacheService = CacheService();
      final file = await cacheService.downloadVideoForOffline(tutorial.videoUrl);
      
      // Update progress
      _notifyProgressListeners(tutorial.id, DownloadProgress(
        tutorialId: tutorial.id,
        status: DownloadStatus.downloading,
        progress: 0.8, // Video is 80% of the download
      ));

      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading video file: $e');
      }
      return null;
    }
  }

  /// Download thumbnail file
  Future<File?> _downloadThumbnailFile(TutorialModel tutorial) async {
    try {
      if (tutorial.thumbnailUrl == null) return null;

      final cacheService = CacheService();
      final fileInfo = await cacheService.thumbnailCache.downloadFile(tutorial.thumbnailUrl!);
      
      // Update progress
      _notifyProgressListeners(tutorial.id, DownloadProgress(
        tutorialId: tutorial.id,
        status: DownloadStatus.downloading,
        progress: 0.95, // Thumbnail brings us to 95%
      ));

      return fileInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading thumbnail file: $e');
      }
      return null;
    }
  }

  /// Save tutorial metadata
  Future<void> _saveTutorialMetadata(
    TutorialModel tutorial,
    String videoPath,
    String? thumbnailPath,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${appDir.path}/offline_tutorials');
      
      if (!await metadataDir.exists()) {
        await metadataDir.create(recursive: true);
      }

      final metadataFile = File('${metadataDir.path}/${tutorial.id}.json');
      
      final metadata = OfflineTutorialMetadata(
        tutorial: tutorial,
        videoPath: videoPath,
        thumbnailPath: thumbnailPath,
        downloadedAt: DateTime.now(),
      );

      await metadataFile.writeAsString(metadata.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tutorial metadata: $e');
      }
    }
  }

  /// Check if tutorial is downloaded
  Future<bool> isTutorialDownloaded(String tutorialId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final metadataFile = File('${appDir.path}/offline_tutorials/$tutorialId.json');
      
      if (!await metadataFile.exists()) {
        return false;
      }

      // Check if video file still exists
      final metadata = await _loadTutorialMetadata(tutorialId);
      if (metadata == null) return false;

      final videoFile = File(metadata.videoPath);
      return await videoFile.exists();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if tutorial is downloaded: $e');
      }
      return false;
    }
  }

  /// Load tutorial metadata
  Future<OfflineTutorialMetadata?> _loadTutorialMetadata(String tutorialId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final metadataFile = File('${appDir.path}/offline_tutorials/$tutorialId.json');
      
      if (!await metadataFile.exists()) {
        return null;
      }

      final jsonString = await metadataFile.readAsString();
      return OfflineTutorialMetadata.fromJson(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tutorial metadata: $e');
      }
      return null;
    }
  }

  /// Get downloaded tutorials
  Future<List<OfflineTutorialMetadata>> getDownloadedTutorials() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${appDir.path}/offline_tutorials');
      
      if (!await metadataDir.exists()) {
        return [];
      }

      final files = await metadataDir.list().toList();
      final tutorials = <OfflineTutorialMetadata>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final jsonString = await file.readAsString();
            final metadata = OfflineTutorialMetadata.fromJson(jsonString);
            
            // Verify video file still exists
            final videoFile = File(metadata.videoPath);
            if (await videoFile.exists()) {
              tutorials.add(metadata);
            } else {
              // Clean up orphaned metadata
              await file.delete();
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error reading metadata file ${file.path}: $e');
            }
          }
        }
      }

      return tutorials;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting downloaded tutorials: $e');
      }
      return [];
    }
  }

  /// Delete downloaded tutorial
  Future<bool> deleteTutorial(String tutorialId) async {
    try {
      final metadata = await _loadTutorialMetadata(tutorialId);
      if (metadata == null) return true; // Already deleted

      // Delete video file
      final videoFile = File(metadata.videoPath);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }

      // Delete thumbnail file
      if (metadata.thumbnailPath != null) {
        final thumbnailFile = File(metadata.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }

      // Delete metadata file
      final appDir = await getApplicationDocumentsDirectory();
      final metadataFile = File('${appDir.path}/offline_tutorials/$tutorialId.json');
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      // Remove from progress tracking
      _downloadProgress.remove(tutorialId);

      if (kDebugMode) {
        print('Tutorial $tutorialId deleted successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting tutorial $tutorialId: $e');
      }
      return false;
    }
  }

  /// Get download progress
  DownloadProgress? getDownloadProgress(String tutorialId) {
    return _downloadProgress[tutorialId];
  }

  /// Get total size of downloaded tutorials
  Future<int> getTotalDownloadSize() async {
    try {
      final tutorials = await getDownloadedTutorials();
      int totalSize = 0;

      for (final tutorial in tutorials) {
        final videoFile = File(tutorial.videoPath);
        if (await videoFile.exists()) {
          totalSize += await videoFile.length();
        }

        if (tutorial.thumbnailPath != null) {
          final thumbnailFile = File(tutorial.thumbnailPath!);
          if (await thumbnailFile.exists()) {
            totalSize += await thumbnailFile.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating total download size: $e');
      }
      return 0;
    }
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${appDir.path}/offline_tutorials');
      
      if (await metadataDir.exists()) {
        await metadataDir.delete(recursive: true);
      }

      _downloadProgress.clear();

      if (kDebugMode) {
        print('All downloads cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all downloads: $e');
      }
    }
  }
}

/// Download progress data class
class DownloadProgress {
  final String tutorialId;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final String? videoPath;
  final String? thumbnailPath;

  const DownloadProgress({
    required this.tutorialId,
    required this.status,
    required this.progress,
    this.error,
    this.videoPath,
    this.thumbnailPath,
  });
}

/// Download status enum
enum DownloadStatus {
  downloading,
  completed,
  failed,
  paused,
}

/// Offline tutorial metadata
class OfflineTutorialMetadata {
  final TutorialModel tutorial;
  final String videoPath;
  final String? thumbnailPath;
  final DateTime downloadedAt;

  const OfflineTutorialMetadata({
    required this.tutorial,
    required this.videoPath,
    this.thumbnailPath,
    required this.downloadedAt,
  });

  factory OfflineTutorialMetadata.fromJson(String jsonString) {
    final json = Map<String, dynamic>.from(
      Map<String, dynamic>.from(jsonDecode(jsonString) as Map)
    );
    
    return OfflineTutorialMetadata(
      tutorial: TutorialModel.fromJson(json['tutorial'] as Map<String, dynamic>),
      videoPath: json['videoPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
    );
  }

  String toJson() {
    return jsonEncode({
      'tutorial': tutorial.toJson(),
      'videoPath': videoPath,
      'thumbnailPath': thumbnailPath,
      'downloadedAt': downloadedAt.toIso8601String(),
    });
  }
}