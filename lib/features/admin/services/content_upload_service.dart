import 'package:flutter/foundation.dart';

/// Simple content upload service placeholder
class ContentUploadService {
  
  ContentUploadService();
  
  // Placeholder methods
  Future<void> initialize() async {
    debugPrint('ContentUploadService initialized');
  }
  
  Future<String?> uploadImage(String filePath) async {
    // Placeholder implementation
    debugPrint('Uploading image: $filePath');
    return null;
  }
  
  Future<String?> uploadVideo(String filePath) async {
    // Placeholder implementation  
    debugPrint('Uploading video: $filePath');
    return null;
  }
}

enum UploadFileType {
  image,
  video,
  audio,
  document,
  thumbnail,
  avatar,
  gallery,
  tutorial,
  galleryImage,
  galleryVideo,
  tutorialImage,
  tutorialVideo,
  tutorialThumbnail,
  updateImage,
  profileImage,
  general;
  
  // Max file size in bytes
  int get maxSizeBytes {
    switch (this) {
      case UploadFileType.profileImage:
      case UploadFileType.thumbnail:
      case UploadFileType.tutorialThumbnail:
        return 5 * 1024 * 1024; // 5MB
      case UploadFileType.galleryImage:
      case UploadFileType.tutorialImage:
      case UploadFileType.updateImage:
      case UploadFileType.image:
        return 10 * 1024 * 1024; // 10MB
      case UploadFileType.galleryVideo:
      case UploadFileType.tutorialVideo:
      case UploadFileType.video:
        return 100 * 1024 * 1024; // 100MB
      default:
        return 50 * 1024 * 1024; // 50MB
    }
  }
  
  // Allowed file extensions
  List<String> get allowedExtensions {
    switch (this) {
      case UploadFileType.profileImage:
      case UploadFileType.galleryImage:
      case UploadFileType.tutorialImage:
      case UploadFileType.tutorialThumbnail:
      case UploadFileType.updateImage:
      case UploadFileType.thumbnail:
      case UploadFileType.image:
        return ['jpg', 'jpeg', 'png', 'webp'];
      case UploadFileType.galleryVideo:
      case UploadFileType.tutorialVideo:
      case UploadFileType.video:
        return ['mp4', 'mov', 'avi', 'mkv'];
      case UploadFileType.audio:
        return ['mp3', 'wav', 'aac', 'm4a'];
      case UploadFileType.document:
        return ['pdf', 'doc', 'docx', 'txt'];
      default:
        return ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov'];
    }
  }
}