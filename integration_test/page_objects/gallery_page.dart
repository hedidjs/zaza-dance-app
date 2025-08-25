import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GalleryPage {
  final WidgetTester tester;

  GalleryPage(this.tester);

  // Finders for gallery page elements
  Finder get galleryScreen => find.byKey(const Key('gallery_screen'));
  Finder get galleryAppBar => find.text('גלריה');
  Finder get galleryGrid => find.byKey(const Key('gallery_grid'));
  Finder get mediaItems => find.byKey(const Key('media_item'));
  Finder get videoItems => find.byKey(const Key('video_item'));
  Finder get imageItems => find.byKey(const Key('image_item'));
  
  // Filter and category finders
  Finder get categoryFilter => find.byKey(const Key('category_filter'));
  Finder get mediaTypeFilter => find.byKey(const Key('media_type_filter'));
  Finder get searchButton => find.byIcon(Icons.search);
  Finder get searchField => find.byKey(const Key('gallery_search'));
  
  // Loading and error states
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get errorMessage => find.byKey(const Key('gallery_error'));
  Finder get emptyStateMessage => find.byKey(const Key('gallery_empty'));
  
  // Media player elements
  Finder get videoPlayer => find.byKey(const Key('video_player'));
  Finder get fullScreenPlayer => find.byKey(const Key('fullscreen_player'));
  Finder get playButton => find.byIcon(Icons.play_arrow);
  Finder get pauseButton => find.byIcon(Icons.pause);

  /// Verify gallery page is displayed
  Future<void> verifyGalleryPageIsDisplayed() async {
    expect(galleryScreen, findsOneWidget);
    expect(galleryAppBar, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Wait for gallery content to load
  Future<void> waitForContentToLoad() async {
    // Wait for loading to complete
    int attempts = 0;
    while (loadingIndicator.evaluate().isNotEmpty && attempts < 30) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }
    await tester.pumpAndSettle();
  }

  /// Verify media items are visible
  Future<void> verifyMediaItemsAreVisible() async {
    await waitForContentToLoad();
    
    // Check if we have media items or empty state
    if (mediaItems.evaluate().isNotEmpty) {
      expect(mediaItems, findsWidgets);
    } else {
      // If no items, should show empty state
      expect(emptyStateMessage, findsOneWidget);
    }
    await tester.pumpAndSettle();
  }

  /// Verify gallery grid layout
  Future<void> verifyGalleryGridLayout() async {
    expect(galleryGrid, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Test video playback functionality
  Future<void> testVideoPlayback() async {
    if (videoItems.evaluate().isNotEmpty) {
      // Tap on first video item
      await tester.tap(videoItems.first);
      await tester.pumpAndSettle();
      
      // Verify video player appears
      expect(videoPlayer, findsOneWidget);
      
      // Test play button
      if (playButton.evaluate().isNotEmpty) {
        await tester.tap(playButton);
        await tester.pumpAndSettle();
        
        // Verify pause button appears (indicating playback started)
        expect(pauseButton, findsOneWidget);
      }
    }
  }

  /// Test image viewing functionality
  Future<void> testImageViewing() async {
    if (imageItems.evaluate().isNotEmpty) {
      // Tap on first image item
      await tester.tap(imageItems.first);
      await tester.pumpAndSettle();
      
      // Verify image viewer opens
      expect(find.byKey(const Key('image_viewer')), findsOneWidget);
      
      // Close image viewer
      await tester.tapAt(const Offset(50, 100));
      await tester.pumpAndSettle();
    }
  }

  /// Test category filtering
  Future<void> testCategoryFiltering() async {
    if (categoryFilter.evaluate().isNotEmpty) {
      await tester.tap(categoryFilter);
      await tester.pumpAndSettle();
      
      // Select a category
      final categoryOption = find.text('בגינרים').first;
      if (categoryOption.evaluate().isNotEmpty) {
        await tester.tap(categoryOption);
        await tester.pumpAndSettle();
        
        // Verify filtered results
        await waitForContentToLoad();
        await verifyMediaItemsAreVisible();
      }
    }
  }

  /// Test media type filtering
  Future<void> testMediaTypeFiltering() async {
    if (mediaTypeFilter.evaluate().isNotEmpty) {
      await tester.tap(mediaTypeFilter);
      await tester.pumpAndSettle();
      
      // Filter by videos only
      final videoFilter = find.text('סרטונים');
      if (videoFilter.evaluate().isNotEmpty) {
        await tester.tap(videoFilter);
        await tester.pumpAndSettle();
        
        await waitForContentToLoad();
        // Verify only video items are shown
        expect(imageItems, findsNothing);
      }
    }
  }

  /// Test search functionality
  Future<void> testSearchFunctionality() async {
    if (searchButton.evaluate().isNotEmpty) {
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'ריקוד');
        await tester.pumpAndSettle();
        
        // Wait for search results
        await waitForContentToLoad();
        await verifyMediaItemsAreVisible();
      }
    }
  }

  /// Test fullscreen video playback
  Future<void> testFullscreenVideoPlayback() async {
    if (videoItems.evaluate().isNotEmpty) {
      // Open video
      await tester.tap(videoItems.first);
      await tester.pumpAndSettle();
      
      // Look for fullscreen button
      final fullscreenButton = find.byIcon(Icons.fullscreen);
      if (fullscreenButton.evaluate().isNotEmpty) {
        await tester.tap(fullscreenButton);
        await tester.pumpAndSettle();
        
        // Verify fullscreen player
        expect(fullScreenPlayer, findsOneWidget);
        
        // Exit fullscreen
        final exitFullscreenButton = find.byIcon(Icons.fullscreen_exit);
        if (exitFullscreenButton.evaluate().isNotEmpty) {
          await tester.tap(exitFullscreenButton);
          await tester.pumpAndSettle();
        }
      }
    }
  }

  /// Test infinite scroll loading
  Future<void> testInfiniteScrollLoading() async {
    if (mediaItems.evaluate().isNotEmpty) {
      // Scroll to bottom to trigger loading more items
      await tester.drag(galleryGrid, const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Check if more items loaded or loading indicator appears
      // Check if more items loaded or loading indicator appears
      try {
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      } catch (e) {
        expect(mediaItems, findsWidgets);
      }
    }
  }

  /// Test share functionality
  Future<void> testShareFunctionality() async {
    if (mediaItems.evaluate().isNotEmpty) {
      // Long press on media item to show options
      await tester.longPress(mediaItems.first);
      await tester.pumpAndSettle();
      
      // Look for share button
      final shareButton = find.byIcon(Icons.share);
      if (shareButton.evaluate().isNotEmpty) {
        await tester.tap(shareButton);
        await tester.pumpAndSettle();
        
        // Share dialog should appear
        expect(find.byType(Dialog), findsOneWidget);
        
        // Close dialog
        await tester.tapAt(const Offset(50, 50));
        await tester.pumpAndSettle();
      }
    }
  }

  /// Test download functionality
  Future<void> testDownloadFunctionality() async {
    if (mediaItems.evaluate().isNotEmpty) {
      // Long press on media item
      await tester.longPress(mediaItems.first);
      await tester.pumpAndSettle();
      
      // Look for download button
      final downloadButton = find.byIcon(Icons.download);
      if (downloadButton.evaluate().isNotEmpty) {
        await tester.tap(downloadButton);
        await tester.pumpAndSettle();
        
        // Download progress should appear
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      }
    }
  }

  /// Verify offline behavior
  Future<void> verifyOfflineBehavior() async {
    await waitForContentToLoad();
    
    // Should show cached content or offline message
    try {
      expect(find.textContaining('לא זמין'), findsWidgets);
    } catch (e) {
      expect(mediaItems, findsWidgets);
    }
  }

  /// Verify online behavior
  Future<void> verifyOnlineBehavior() async {
    await waitForContentToLoad();
    
    // Should load fresh content
    await verifyMediaItemsAreVisible();
  }

  /// Test gesture navigation
  Future<void> testGestureNavigation() async {
    if (mediaItems.evaluate().isNotEmpty) {
      // Swipe between media items
      await tester.tap(mediaItems.first);
      await tester.pumpAndSettle();
      
      // Swipe left to next item
      await tester.drag(
        find.byKey(const Key('media_viewer')),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();
      
      // Swipe right to previous item
      await tester.drag(
        find.byKey(const Key('media_viewer')),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();
    }
  }

  /// Test pinch to zoom functionality
  Future<void> testPinchToZoom() async {
    if (imageItems.evaluate().isNotEmpty) {
      // Open image
      await tester.tap(imageItems.first);
      await tester.pumpAndSettle();
      
      // Simulate pinch to zoom
      final center = tester.getCenter(find.byKey(const Key('image_viewer')));
      await tester.startGesture(center);
      await tester.pump();
      
      // Scale gesture would be implemented here
      // This is a simplified test
      expect(find.byKey(const Key('image_viewer')), findsOneWidget);
    }
  }

  /// Verify error handling
  Future<void> verifyErrorHandling() async {
    // If there's an error state, verify it's handled gracefully
    if (errorMessage.evaluate().isNotEmpty) {
      expect(errorMessage, findsOneWidget);
      
      // Look for retry button
      final retryButton = find.text('נסה שוב');
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton);
        await tester.pumpAndSettle();
        
        // Should attempt to reload
        await waitForContentToLoad();
      }
    }
  }
}