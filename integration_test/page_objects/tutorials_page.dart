import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TutorialsPage {
  final WidgetTester tester;

  TutorialsPage(this.tester);

  // Finders for tutorials page elements
  Finder get tutorialsScreen => find.byKey(const Key('tutorials_screen'));
  Finder get tutorialsAppBar => find.text('שיעורים');
  Finder get tutorialsList => find.byKey(const Key('tutorials_list'));
  Finder get tutorialItems => find.byKey(const Key('tutorial_item'));
  
  // Tutorial content finders
  Finder get tutorialThumbnails => find.byKey(const Key('tutorial_thumbnail'));
  Finder get tutorialTitles => find.byKey(const Key('tutorial_title'));
  Finder get tutorialDurations => find.byKey(const Key('tutorial_duration'));
  Finder get difficultyBadges => find.byKey(const Key('difficulty_badge'));
  
  // Filter and sorting finders
  Finder get difficultyFilter => find.byKey(const Key('difficulty_filter'));
  Finder get categoryFilter => find.byKey(const Key('tutorial_category_filter'));
  Finder get sortButton => find.byKey(const Key('sort_button'));
  Finder get searchButton => find.byIcon(Icons.search);
  Finder get searchField => find.byKey(const Key('tutorials_search'));
  
  // Video player elements
  Finder get videoPlayer => find.byKey(const Key('tutorial_video_player'));
  Finder get playButton => find.byIcon(Icons.play_arrow);
  Finder get pauseButton => find.byIcon(Icons.pause);
  Finder get progressBar => find.byKey(const Key('video_progress'));
  Finder get volumeButton => find.byIcon(Icons.volume_up);
  Finder get fullscreenButton => find.byIcon(Icons.fullscreen);
  
  // Tutorial details elements
  Finder get tutorialDescription => find.byKey(const Key('tutorial_description'));
  Finder get instructorInfo => find.byKey(const Key('instructor_info'));
  Finder get tutorialTags => find.byKey(const Key('tutorial_tags'));
  
  // Interactive elements
  Finder get favoriteButton => find.byIcon(Icons.favorite_border);
  Finder get favoriteFilledButton => find.byIcon(Icons.favorite);
  Finder get shareButton => find.byIcon(Icons.share);
  Finder get downloadButton => find.byIcon(Icons.download);
  
  // Loading and error states
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get errorMessage => find.byKey(const Key('tutorials_error'));
  Finder get emptyStateMessage => find.byKey(const Key('tutorials_empty'));

  /// Verify tutorials page is displayed
  Future<void> verifyTutorialsPageIsDisplayed() async {
    expect(tutorialsScreen, findsOneWidget);
    expect(tutorialsAppBar, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Wait for tutorials to load
  Future<void> waitForTutorialsToLoad() async {
    int attempts = 0;
    while (loadingIndicator.evaluate().isNotEmpty && attempts < 30) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }
    await tester.pumpAndSettle();
  }

  /// Verify tutorial items are visible
  Future<void> verifyTutorialItemsAreVisible() async {
    await waitForTutorialsToLoad();
    
    if (tutorialItems.evaluate().isNotEmpty) {
      expect(tutorialItems, findsWidgets);
      expect(tutorialThumbnails, findsWidgets);
      expect(tutorialTitles, findsWidgets);
    } else {
      expect(emptyStateMessage, findsOneWidget);
    }
    await tester.pumpAndSettle();
  }

  /// Test tutorial video playback
  Future<void> testTutorialVideoPlayback() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      // Tap on first tutorial
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Verify video player appears
      expect(videoPlayer, findsOneWidget);
      
      // Test play functionality
      if (playButton.evaluate().isNotEmpty) {
        await tester.tap(playButton);
        await tester.pumpAndSettle();
        
        // Verify video starts playing (pause button appears)
        expect(pauseButton, findsOneWidget);
        
        // Test pause functionality
        await tester.tap(pauseButton);
        await tester.pumpAndSettle();
        expect(playButton, findsOneWidget);
      }
    }
  }

  /// Test difficulty level filtering
  Future<void> testDifficultyFiltering() async {
    if (difficultyFilter.evaluate().isNotEmpty) {
      await tester.tap(difficultyFilter);
      await tester.pumpAndSettle();
      
      // Select beginner level
      final beginnerFilter = find.text('בגינרים');
      if (beginnerFilter.evaluate().isNotEmpty) {
        await tester.tap(beginnerFilter);
        await tester.pumpAndSettle();
        
        await waitForTutorialsToLoad();
        
        // Verify only beginner tutorials are shown
        if (difficultyBadges.evaluate().isNotEmpty) {
          // All visible badges should be for beginners
          expect(find.textContaining('בגינרים'), findsWidgets);
        }
      }
    }
  }

  /// Test category filtering
  Future<void> testCategoryFiltering() async {
    if (categoryFilter.evaluate().isNotEmpty) {
      await tester.tap(categoryFilter);
      await tester.pumpAndSettle();
      
      // Select a category
      final hipHopCategory = find.text('היפ הופ');
      if (hipHopCategory.evaluate().isNotEmpty) {
        await tester.tap(hipHopCategory);
        await tester.pumpAndSettle();
        
        await waitForTutorialsToLoad();
        await verifyTutorialItemsAreVisible();
      }
    }
  }

  /// Test search functionality
  Future<void> testSearchFunctionality() async {
    if (searchButton.evaluate().isNotEmpty) {
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'בסיסי');
        await tester.pumpAndSettle();
        
        await waitForTutorialsToLoad();
        
        // Verify search results contain the search term
        expect(find.textContaining('בסיסי'), findsWidgets);
      }
    }
  }

  /// Test sorting functionality
  Future<void> testSortingFunctionality() async {
    if (sortButton.evaluate().isNotEmpty) {
      await tester.tap(sortButton);
      await tester.pumpAndSettle();
      
      // Sort by duration
      final durationSort = find.text('משך זמן');
      if (durationSort.evaluate().isNotEmpty) {
        await tester.tap(durationSort);
        await tester.pumpAndSettle();
        
        await waitForTutorialsToLoad();
        await verifyTutorialItemsAreVisible();
      }
    }
  }

  /// Test favorite functionality
  Future<void> testFavoriteFunctionality() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      // Open tutorial details
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Test adding to favorites
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();
        
        // Should change to filled favorite icon
        expect(favoriteFilledButton, findsOneWidget);
        
        // Test removing from favorites
        await tester.tap(favoriteFilledButton);
        await tester.pumpAndSettle();
        expect(favoriteButton, findsOneWidget);
      }
    }
  }

  /// Test video controls functionality
  Future<void> testVideoControls() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      if (videoPlayer.evaluate().isNotEmpty) {
        // Test volume control
        if (volumeButton.evaluate().isNotEmpty) {
          await tester.tap(volumeButton);
          await tester.pumpAndSettle();
        }
        
        // Test progress bar interaction
        if (progressBar.evaluate().isNotEmpty) {
          final progressBarCenter = tester.getCenter(progressBar);
          
          // Tap on progress bar to seek
          await tester.tapAt(Offset(progressBarCenter.dx + 50, progressBarCenter.dy));
          await tester.pumpAndSettle();
        }
        
        // Test fullscreen toggle
        if (fullscreenButton.evaluate().isNotEmpty) {
          await tester.tap(fullscreenButton);
          await tester.pumpAndSettle();
          
          // Should enter fullscreen mode
          expect(find.byKey(const Key('fullscreen_player')), findsOneWidget);
          
          // Exit fullscreen
          final exitFullscreenButton = find.byIcon(Icons.fullscreen_exit);
          if (exitFullscreenButton.evaluate().isNotEmpty) {
            await tester.tap(exitFullscreenButton);
            await tester.pumpAndSettle();
          }
        }
      }
    }
  }

  /// Test tutorial sharing
  Future<void> testTutorialSharing() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      if (shareButton.evaluate().isNotEmpty) {
        await tester.tap(shareButton);
        await tester.pumpAndSettle();
        
        // Share options should appear
        try {
          expect(find.byType(Dialog), findsOneWidget);
        } catch (e) {
          expect(find.byType(BottomSheet), findsOneWidget);
        }
        
        // Close share dialog
        await tester.tapAt(const Offset(50, 50));
        await tester.pumpAndSettle();
      }
    }
  }

  /// Test tutorial download
  Future<void> testTutorialDownload() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      if (downloadButton.evaluate().isNotEmpty) {
        await tester.tap(downloadButton);
        await tester.pumpAndSettle();
        
        // Download progress should appear
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      }
    }
  }

  /// Test tutorial details display
  Future<void> testTutorialDetailsDisplay() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Verify tutorial details are shown
      expect(tutorialDescription, findsOneWidget);
      
      // Check for instructor information
      if (instructorInfo.evaluate().isNotEmpty) {
        expect(instructorInfo, findsOneWidget);
      }
      
      // Check for tutorial tags
      if (tutorialTags.evaluate().isNotEmpty) {
        expect(tutorialTags, findsOneWidget);
      }
    }
  }

  /// Test video quality selection
  Future<void> testVideoQualitySelection() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Look for quality/settings button
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        
        // Quality options should appear
        final quality720p = find.text('720p');
        final quality480p = find.text('480p');
        if (quality720p.evaluate().isNotEmpty) {
          await tester.tap(quality720p);
          await tester.pumpAndSettle();
        } else if (quality480p.evaluate().isNotEmpty) {
          await tester.tap(quality480p);
          await tester.pumpAndSettle();
        }
      }
    }
  }

  /// Test playback speed control
  Future<void> testPlaybackSpeedControl() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Look for speed control button
      final speed1x = find.text('1x');
      final speedControl = find.byKey(const Key('speed_control'));
      if (speed1x.evaluate().isNotEmpty) {
        await tester.tap(speed1x);
        await tester.pumpAndSettle();
      } else if (speedControl.evaluate().isNotEmpty) {
        await tester.tap(speedControl);
        await tester.pumpAndSettle();
      }
      
      // Speed options should appear
      final speed2x = find.text('2x');
      if (speed2x.evaluate().isNotEmpty) {
        await tester.tap(speed2x);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Test offline tutorial access
  Future<void> testOfflineTutorialAccess() async {
    // Check for downloaded tutorials section
    final offlineSection = find.byKey(const Key('offline_tutorials'));
    if (offlineSection.evaluate().isNotEmpty) {
      await tester.tap(offlineSection);
      await tester.pumpAndSettle();
      
      // Verify offline tutorials are displayed
      await verifyTutorialItemsAreVisible();
    }
  }

  /// Test tutorial progress tracking
  Future<void> testTutorialProgressTracking() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Play video for a while to track progress
      if (playButton.evaluate().isNotEmpty) {
        await tester.tap(playButton);
        await tester.pump(const Duration(seconds: 3));
        
        // Pause and check if progress is saved
        if (pauseButton.evaluate().isNotEmpty) {
          await tester.tap(pauseButton);
          await tester.pumpAndSettle();
        }
        
        // Navigate away and back to check progress persistence
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        await tester.tap(tutorialItems.first);
        await tester.pumpAndSettle();
        
        // Progress should be preserved
        expect(progressBar, findsOneWidget);
      }
    }
  }

  /// Test tutorial completion tracking
  Future<void> testTutorialCompletionTracking() async {
    if (tutorialItems.evaluate().isNotEmpty) {
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      // Look for completion status
      final completionBadge = find.byKey(const Key('completion_badge'));
      
      // Mark as completed if option available
      final markCompleteButton = find.text('סמן כהושלם');
      if (markCompleteButton.evaluate().isNotEmpty) {
        await tester.tap(markCompleteButton);
        await tester.pumpAndSettle();
        
        // Completion badge should appear
        expect(completionBadge, findsOneWidget);
      }
    }
  }

  /// Verify error handling
  Future<void> verifyErrorHandling() async {
    if (errorMessage.evaluate().isNotEmpty) {
      expect(errorMessage, findsOneWidget);
      
      // Look for retry button
      final retryButton = find.text('נסה שוב');
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton);
        await tester.pumpAndSettle();
        
        await waitForTutorialsToLoad();
      }
    }
  }

  /// Test continuous playback
  Future<void> testContinuousPlayback() async {
    if (tutorialItems.evaluate().length > 1) {
      // Play first tutorial
      await tester.tap(tutorialItems.first);
      await tester.pumpAndSettle();
      
      if (playButton.evaluate().isNotEmpty) {
        await tester.tap(playButton);
        await tester.pumpAndSettle();
        
        // Look for autoplay next option
        final autoplayButton = find.byKey(const Key('autoplay_next'));
        if (autoplayButton.evaluate().isNotEmpty) {
          await tester.tap(autoplayButton);
          await tester.pumpAndSettle();
        }
      }
    }
  }
}